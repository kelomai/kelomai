#!/bin/bash
# =============================================================================
# Mac Development Workstation Setup Script
# Optimized for: Software Development + Local LLMs on Apple Silicon
#
# Usage:
#   ./setup.sh              # Run full setup
#   ./setup.sh --dry-run    # Preview what would be installed (no changes)
#   ./setup.sh -n           # Same as --dry-run
#   ./setup.sh --skip-mas   # Skip Mac App Store apps (useful for VMs)
#   ./setup.sh --shells-only # Only configure shells (zsh + pwsh with oh-my-posh)
#
# Remote:
#   curl -fsSL https://raw.githubusercontent.com/kelomai/kelomai/main/mac-setup/setup.sh | bash
#   curl -fsSL https://raw.githubusercontent.com/kelomai/kelomai/main/mac-setup/setup.sh | bash -s -- --dry-run
#   curl -fsSL https://raw.githubusercontent.com/kelomai/kelomai/main/mac-setup/setup.sh | bash -s -- --skip-mas
# =============================================================================

set -e

# =============================================================================
# COMMAND LINE FLAGS
# =============================================================================
DRY_RUN=false
SKIP_MAS=false
SHELLS_ONLY=false

for arg in "$@"; do
    case $arg in
        --dry-run|-n)
            DRY_RUN=true
            ;;
        --skip-mas)
            SKIP_MAS=true
            ;;
        --shells-only)
            SHELLS_ONLY=true
            ;;
    esac
done

if $DRY_RUN; then
    echo "============================================="
    echo "  DRY RUN MODE - No changes will be made"
    echo "============================================="
    echo ""
fi

if $SKIP_MAS; then
    echo "[INFO] Skipping Mac App Store apps (--skip-mas)"
    echo ""
fi

# =============================================================================
# SUDO CREDENTIAL CACHING
# =============================================================================
# Ask for sudo password upfront and keep it alive
if ! $DRY_RUN; then
    echo "This script requires administrator privileges for some operations."
    sudo -v

    # Keep sudo alive in the background
    while true; do
        sudo -n true
        sleep 60
        kill -0 "$$" || exit
    done 2>/dev/null &
fi

# Helper function to run or simulate commands
run_cmd() {
    if $DRY_RUN; then
        echo "[DRY RUN] Would execute: $*"
    else
        "$@"
    fi
}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

log_info "Starting Mac Development Workstation Setup..."
log_info "Architecture: $(uname -m)"

# =============================================================================
# PACKAGE MANIFEST
# =============================================================================
GITHUB_RAW_BASE="https://raw.githubusercontent.com/kelomai/kelomai/main"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd 2>/dev/null || pwd)"
PACKAGES_JSON=""

# Bootstrap jq - must be installed before we can parse the manifest
bootstrap_jq() {
    if command -v jq &>/dev/null; then
        log_success "jq already installed"
        return 0
    fi

    if $DRY_RUN; then
        log_info "[DRY RUN] Would install jq for JSON parsing"
        return 0
    fi

    log_info "Installing jq (required for package manifest)..."
    brew install jq || {
        log_error "Failed to install jq - cannot parse package manifest"
        exit 1
    }
    log_success "jq installed"
}

# Load package manifest from local file or GitHub
load_packages() {
    # Try local file first (for local execution)
    if [[ -f "$SCRIPT_DIR/packages.json" ]]; then
        PACKAGES_JSON=$(cat "$SCRIPT_DIR/packages.json")
        log_success "Loaded packages.json from local file"
        return 0
    fi

    # Try current directory
    if [[ -f "./packages.json" ]]; then
        PACKAGES_JSON=$(cat "./packages.json")
        log_success "Loaded packages.json from current directory"
        return 0
    fi

    if $DRY_RUN; then
        log_info "[DRY RUN] Would download packages.json from GitHub"
        return 0
    fi

    # Download from GitHub
    log_info "Downloading packages.json from GitHub..."
    PACKAGES_JSON=$(curl -fsSL "$GITHUB_RAW_BASE/mac-setup/packages.json") || {
        log_error "Failed to download packages.json"
        exit 1
    }
    log_success "Downloaded packages.json from GitHub"
}

# Helper to get flat array of packages from nested JSON categories
get_packages() {
    local section="$1"
    if [[ -z "$PACKAGES_JSON" ]]; then
        echo ""
        return
    fi
    # Flatten nested objects into a simple array
    echo "$PACKAGES_JSON" | jq -r "
        .$section |
        if type == \"object\" then
            [.[] | if type == \"array\" then .[] else . end] | .[]
        elif type == \"array\" then
            .[]
        else
            empty
        end
    " 2>/dev/null
}

# Helper to get key-value pairs (for mas_apps, edge_extensions)
get_package_map() {
    local section="$1"
    if [[ -z "$PACKAGES_JSON" ]]; then
        echo ""
        return
    fi
    echo "$PACKAGES_JSON" | jq -r ".$section | to_entries | .[] | \"\(.key)|\(.value)\"" 2>/dev/null
}

# =============================================================================
# HOMEBREW INSTALLATION
# =============================================================================
install_homebrew() {
    # Determine Homebrew path based on architecture
    local brew_bin
    if [[ $(uname -m) == 'arm64' ]]; then
        brew_bin="/opt/homebrew/bin/brew"
    else
        brew_bin="/usr/local/bin/brew"
    fi

    # Check if Homebrew binary exists (may not be in PATH yet)
    if [[ -x "$brew_bin" ]]; then
        # Homebrew exists but may not be in PATH - add it for this session
        if ! command -v brew &>/dev/null; then
            log_info "Homebrew found at $brew_bin, adding to PATH..."
            eval "$($brew_bin shellenv)"
        fi
        log_success "Homebrew already installed at $brew_bin"
    elif ! command -v brew &>/dev/null; then
        # Homebrew not installed
        if $DRY_RUN; then
            log_info "[DRY RUN] Would install Homebrew"
            return
        fi
        log_info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Add Homebrew to PATH based on architecture
        if [[ $(uname -m) == 'arm64' ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
            log_success "Homebrew installed at /opt/homebrew (Apple Silicon)"
        else
            echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/usr/local/bin/brew shellenv)"
            log_success "Homebrew installed at /usr/local (Intel)"
        fi
        return  # Fresh install, no need to update
    else
        log_success "Homebrew already installed at $(which brew)"
    fi

    if $DRY_RUN; then
        log_info "[DRY RUN] Would check if Homebrew needs updating"
        return
    fi

    # Check when Homebrew was last updated (look at .git FETCH_HEAD timestamp)
    local brew_repo
    if [[ $(uname -m) == 'arm64' ]]; then
        brew_repo="/opt/homebrew"
    else
        brew_repo="/usr/local/Homebrew"
    fi

    local last_update=0
    local fetch_head="$brew_repo/.git/FETCH_HEAD"
    if [[ -f "$fetch_head" ]]; then
        last_update=$(stat -f %m "$fetch_head" 2>/dev/null || echo 0)
    fi

    local now
    now=$(date +%s)
    local age_hours=$(( (now - last_update) / 3600 ))

    if [[ $age_hours -gt 24 ]]; then
        log_info "Homebrew last updated ${age_hours} hours ago, updating..."
        brew update
    else
        log_success "Homebrew updated recently (${age_hours} hours ago), skipping update"
    fi
}

# =============================================================================
# MAC APP STORE INSTALLATION
# =============================================================================
install_mas_apps() {
    if ! command -v mas &>/dev/null; then
        log_warn "mas CLI not installed, skipping App Store apps"
        return
    fi

    # Check if signed into App Store
    if ! mas account &>/dev/null; then
        log_warn "Not signed into App Store. Please sign in manually first."
        log_info "Open App Store app and sign in, then re-run this script."
        return
    fi

    log_info "Installing Mac App Store apps..."
    while IFS='|' read -r app_id app_name; do
        [[ -z "$app_id" ]] && continue
        if mas list | grep -q "^$app_id"; then
            log_success "$app_name ($app_id) already installed"
        else
            log_info "Installing $app_name ($app_id)..."
            mas install "$app_id" || log_warn "Failed to install $app_name"
        fi
    done < <(get_package_map "mas_apps")
}

# =============================================================================
# EDGE EXTENSIONS INSTALLATION (via managed preferences)
# =============================================================================
install_edge_extensions() {
    log_info "Configuring Microsoft Edge extensions..."

    local edge_plist_dir="$HOME/Library/Managed Preferences"
    local edge_plist="$edge_plist_dir/com.microsoft.Edge.plist"

    # Create directory if needed
    mkdir -p "$edge_plist_dir"

    # Build plist content from manifest
    local plist_entries=""
    while IFS='|' read -r ext_id ext_name; do
        [[ -z "$ext_id" ]] && continue
        plist_entries+="        <string>${ext_id}</string>\n"
    done < <(get_package_map "edge_extensions")

    # Create/update Edge preferences plist
    cat > "/tmp/edge_extensions.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>ExtensionInstallForcelist</key>
    <array>
$(echo -e "$plist_entries")    </array>
</dict>
</plist>
EOF

    # Copy to managed preferences (may need sudo for system-wide)
    if [ -w "$edge_plist_dir" ]; then
        cp "/tmp/edge_extensions.plist" "$edge_plist"
        log_success "Edge extensions configured"
    else
        log_info "To install Edge extensions system-wide, run:"
        echo "  sudo cp /tmp/edge_extensions.plist '$edge_plist'"
    fi

    echo ""
    log_info "Edge extensions will be installed on next Edge launch:"
    while IFS='|' read -r ext_id ext_name; do
        [[ -z "$ext_id" ]] && continue
        echo "  - $ext_name ($ext_id)"
    done < <(get_package_map "edge_extensions")
    echo ""
    log_info "Or install manually from: edge://extensions"
}

# =============================================================================
# LOCAL LLM TOOLS (Optimized for Mac Studio Ultra 96GB)
# =============================================================================

# MLX - Apple's ML framework for Apple Silicon (fastest on Mac)
install_mlx() {
    log_info "Installing MLX (Apple's native ML framework)..."

    # Use pipx to install mlx-lm (includes mlx as dependency)
    # pipx creates isolated environments, avoiding PEP 668 restrictions
    if ! command -v pipx &>/dev/null; then
        log_warn "pipx not installed, skipping MLX"
        return
    fi

    # Ensure pipx bin directory is in PATH for this session
    export PATH="$HOME/.local/bin:$PATH"
    pipx ensurepath &>/dev/null || true

    # Check if mlx_lm is already installed via pipx
    if pipx list | grep -q "mlx-lm"; then
        log_success "mlx-lm already installed via pipx"
    else
        log_info "Installing mlx-lm via pipx (includes MLX framework)..."
        pipx install mlx-lm || log_warn "Failed to install mlx-lm"
    fi

    # Also install huggingface-cli for downloading models
    if ! command -v huggingface-cli &>/dev/null; then
        log_info "Installing huggingface-cli..."
        pipx install huggingface_hub || log_warn "Failed to install huggingface_hub"
    fi

    # Verify installation
    if command -v mlx_lm.generate &>/dev/null; then
        log_success "MLX-LM installed successfully"
    fi
}

setup_mlx_models() {
    echo ""
    echo "============================================="
    echo "  MLX Models (Apple Silicon Optimized)"
    echo "============================================="
    echo ""
    log_info "MLX models run natively on Apple Silicon - often faster than Ollama!"
    echo ""
    echo "MLX models are on Hugging Face under 'mlx-community':"
    echo ""
    echo "  Download models with:"
    echo "    huggingface-cli download mlx-community/Qwen2.5-Coder-32B-Instruct-4bit"
    echo "    huggingface-cli download mlx-community/Meta-Llama-3.1-70B-Instruct-4bit"
    echo "    huggingface-cli download mlx-community/DeepSeek-Coder-V2-Lite-Instruct-4bit"
    echo ""
    echo "  Run models with mlx-lm:"
    echo "    mlx_lm.generate --model mlx-community/Qwen2.5-Coder-32B-Instruct-4bit --prompt 'Hello'"
    echo ""
    echo "  Or start an OpenAI-compatible server:"
    echo "    mlx_lm.server --model mlx-community/Qwen2.5-Coder-32B-Instruct-4bit --port 8080"
    echo ""
    echo "  Popular MLX models for 96GB:"
    echo "    - mlx-community/Qwen2.5-Coder-32B-Instruct-4bit    (18GB)"
    echo "    - mlx-community/Meta-Llama-3.1-70B-Instruct-4bit   (40GB)"
    echo "    - mlx-community/Mixtral-8x7B-Instruct-v0.1-4bit    (26GB)"
    echo "    - mlx-community/deepseek-coder-33b-instruct-4bit   (18GB)"
    echo ""
}

# Ollama - Primary LLM runtime with OpenAI-compatible API
install_ollama() {
    if command -v ollama &>/dev/null; then
        log_success "Ollama already installed: $(ollama --version 2>/dev/null || echo 'version unknown')"
    elif brew list --cask ollama &>/dev/null; then
        log_success "Ollama cask installed (may need to launch app first)"
    else
        log_info "Installing Ollama via Homebrew..."
        brew install --cask ollama
        log_success "Ollama installed"
    fi
}

# llama.cpp - For maximum performance and custom model loading
install_llama_cpp() {
    if brew list llama.cpp &>/dev/null; then
        log_success "llama.cpp already installed"
    else
        log_info "Installing llama.cpp (optimized inference engine)..."
        brew install llama.cpp || log_warn "Failed to install llama.cpp"
    fi
}

# Open WebUI - ChatGPT-like web interface for Ollama
install_open_webui() {
    if ! command -v docker &>/dev/null; then
        log_warn "Docker not available, skipping Open WebUI"
        return
    fi

    if docker ps -a --format '{{.Names}}' | grep -q '^open-webui$'; then
        log_success "Open WebUI container already exists"
    else
        log_info "Installing Open WebUI (ChatGPT-like interface)..."
        docker run -d \
            -p 3000:8080 \
            --add-host=host.docker.internal:host-gateway \
            -v open-webui:/app/backend/data \
            --name open-webui \
            --restart always \
            ghcr.io/open-webui/open-webui:main
        log_success "Open WebUI installed at http://localhost:3000"
    fi
}

# Pull recommended models for 96GB Mac Studio Ultra
setup_ollama_models() {
    if ! command -v ollama &>/dev/null; then
        log_warn "Ollama not installed, skipping model setup"
        return
    fi

    # Start ollama service if not running
    if ! pgrep -x "ollama" > /dev/null; then
        log_info "Starting Ollama service..."
        ollama serve &>/dev/null &
        sleep 3
    fi

    echo ""
    echo "============================================="
    echo "  LLM Models for Mac Studio Ultra (96GB)"
    echo "============================================="
    echo ""
    log_info "With 96GB unified memory, you can run large models!"
    echo ""
    echo "AVAILABLE MODELS (from manifest):"
    echo ""

    # Display models from manifest by category
    for category in coding general fast specialized; do
        echo "  ${category^} Models:"
        echo "$PACKAGES_JSON" | jq -r ".ollama_models.$category[]?" 2>/dev/null | while read -r model; do
            [[ -z "$model" ]] && continue
            echo "    ollama pull $model"
        done
        echo ""
    done

    # Get default models from manifest
    local default_models
    default_models=$(echo "$PACKAGES_JSON" | jq -r '.ollama_models.default[]?' 2>/dev/null | tr '\n' ' ')

    read -p "Pull default models? ($default_models) [y/N]: " -n 1 -r < /dev/tty
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        while IFS= read -r model; do
            [[ -z "$model" ]] && continue
            log_info "Pulling $model..."
            ollama pull "$model" || log_warn "Failed to pull $model"
        done < <(echo "$PACKAGES_JSON" | jq -r '.ollama_models.default[]?' 2>/dev/null)

        log_success "Models ready! Run: ollama run <model>"
    fi
}

# Combined LLM setup
setup_local_llm_stack() {
    log_info "Setting up Local LLM Stack..."

    # Core inference engines
    install_ollama
    install_llama_cpp
    install_mlx

    # Optional: Open WebUI
    read -p "Install Open WebUI (ChatGPT-like web interface)? [y/N]: " -n 1 -r < /dev/tty
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        install_open_webui
    fi

    # Model recommendations
    setup_ollama_models
    setup_mlx_models
}

# =============================================================================
# PYTHON ENVIRONMENT SETUP
# =============================================================================
setup_python() {
    log_info "Setting up Python environment..."

    # Ensure pipx is available
    if command -v pipx &>/dev/null; then
        pipx ensurepath

        # Install Python CLI tools via pipx from manifest
        while IFS= read -r tool; do
            [[ -z "$tool" ]] && continue
            if ! pipx list | grep -q "$tool"; then
                log_info "Installing $tool via pipx..."
                pipx install "$tool" || log_warn "Failed to install $tool"
            else
                log_success "$tool already installed"
            fi
        done < <(get_packages "pipx_packages")
    fi

    # Setup pyenv if installed
    if command -v pyenv &>/dev/null; then
        if ! grep -q 'pyenv init' ~/.zshrc 2>/dev/null; then
            log_info "Configuring pyenv in ~/.zshrc..."
            cat >> ~/.zshrc << 'EOF'

# Pyenv configuration
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
EOF
            log_success "Pyenv configured"
        fi
    fi
}

# =============================================================================
# SHELL CONFIGURATION (oh-my-posh for pwsh and zsh)
# =============================================================================
configure_powershell() {
    log_info "Configuring PowerShell with oh-my-posh..."

    # Get the actual PowerShell profile path from PowerShell itself
    local pwsh_profile
    pwsh_profile=$(pwsh -NoProfile -Command 'Write-Host $PROFILE' 2>/dev/null)

    if [ -z "$pwsh_profile" ]; then
        log_warn "Could not determine PowerShell profile path"
        return
    fi

    local pwsh_profile_dir
    pwsh_profile_dir=$(dirname "$pwsh_profile")
    local omp_config_dir="$HOME/.config/oh-my-posh"
    local omp_config="$omp_config_dir/kelomai.omp.json"

    log_info "PowerShell profile path: $pwsh_profile"

    mkdir -p "$pwsh_profile_dir"
    mkdir -p "$omp_config_dir"

    # Download oh-my-posh theme from GitHub
    log_info "Downloading oh-my-posh theme..."
    curl -fsSL "$GITHUB_RAW_BASE/oh-my-posh/kelomai.omp.json" -o "$omp_config" || {
        log_warn "Failed to download oh-my-posh theme"
        return
    }

    # Create/update PowerShell profile
    if [ -f "$pwsh_profile" ]; then
        # Check if already configured
        if grep -q "oh-my-posh init pwsh" "$pwsh_profile"; then
            log_success "PowerShell already configured with oh-my-posh"
        else
            # Append to existing profile
            cat >> "$pwsh_profile" << 'EOF'

# oh-my-posh prompt (Kelomai theme)
oh-my-posh init pwsh --config "$HOME/.config/oh-my-posh/kelomai.omp.json" | Invoke-Expression
EOF
            log_success "Added oh-my-posh to PowerShell profile"
        fi
    else
        # Create new profile
        cat > "$pwsh_profile" << 'EOF'
# PowerShell Profile - Kelomai Dev Workstation
# ===========================================

# oh-my-posh prompt (Kelomai theme)
oh-my-posh init pwsh --config "$HOME/.config/oh-my-posh/kelomai.omp.json" | Invoke-Expression

# Aliases
Set-Alias -Name k -Value kubectl
Set-Alias -Name tf -Value terraform
Set-Alias -Name g -Value git

# PSReadLine configuration
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
EOF
        log_success "Created PowerShell profile at $pwsh_profile"
    fi
}

install_oh_my_zsh() {
    log_info "Installing oh-my-zsh..."

    if [ -d "$HOME/.oh-my-zsh" ]; then
        log_success "oh-my-zsh already installed"
        return 0
    fi

    # Install oh-my-zsh (unattended)
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || {
        log_warn "Failed to install oh-my-zsh"
        return 1
    }

    log_success "oh-my-zsh installed"
}

install_zsh_plugins() {
    log_info "Installing zsh plugins from manifest..."

    local zsh_custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

    # Install plugins from manifest (format: "owner/repo")
    while IFS= read -r plugin; do
        [[ -z "$plugin" ]] && continue
        local plugin_name="${plugin##*/}"  # Extract repo name from "owner/repo"
        local plugin_dir="$zsh_custom/plugins/$plugin_name"

        if [ ! -d "$plugin_dir" ]; then
            log_info "Installing $plugin_name..."
            git clone "https://github.com/$plugin" "$plugin_dir" 2>/dev/null
            log_success "Installed $plugin_name"
        else
            log_success "$plugin_name already installed"
        fi
    done < <(get_packages "zsh_plugins")
}

configure_zsh() {
    log_info "Configuring Zsh with oh-my-zsh + oh-my-posh..."

    local zshrc="$HOME/.zshrc"
    local omp_config_dir="$HOME/.config/oh-my-posh"
    local omp_config="$omp_config_dir/kelomai.omp.json"

    # Install oh-my-zsh first
    install_oh_my_zsh
    install_zsh_plugins

    mkdir -p "$omp_config_dir"

    # Download oh-my-posh theme
    log_info "Downloading oh-my-posh theme..."
    curl -fsSL "$GITHUB_RAW_BASE/oh-my-posh/kelomai.omp.json" -o "$omp_config" || {
        log_warn "Failed to download oh-my-posh theme"
    }

    # Backup existing .zshrc if it exists
    if [ -f "$zshrc" ]; then
        cp "$zshrc" "$zshrc.backup.$(date +%Y%m%d%H%M%S)"
        log_info "Backed up existing .zshrc"
    fi

    # Create new .zshrc with oh-my-zsh + oh-my-posh
    cat > "$zshrc" << 'EOF'
# =============================================================================
# Zsh Configuration - Kelomai Dev Workstation
# oh-my-zsh + oh-my-posh
# =============================================================================

# Homebrew (must be before oh-my-zsh)
if [[ $(uname -m) == 'arm64' ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    eval "$(/usr/local/bin/brew shellenv)"
fi

# -----------------------------------------------------------------------------
# oh-my-zsh Configuration
# -----------------------------------------------------------------------------
export ZSH="$HOME/.oh-my-zsh"

# Don't use oh-my-zsh theme (we use oh-my-posh instead)
ZSH_THEME=""

# Plugins (order matters for some)
plugins=(
    git                    # Git aliases and completions
    docker                 # Docker completions
    docker-compose         # Docker Compose completions
    kubectl                # Kubectl completions and aliases
    terraform              # Terraform completions
    azure                  # Azure CLI completions
    brew                   # Homebrew completions
    node                   # Node/npm completions
    python                 # Python completions
    pip                    # Pip completions
    golang                 # Go completions
    dotnet                 # .NET completions
    vscode                 # VS Code aliases
    gh                     # GitHub CLI completions
    zsh-autosuggestions    # Fish-like autosuggestions
    zsh-syntax-highlighting # Syntax highlighting
    zsh-completions        # Additional completions
)

# Load oh-my-zsh
source $ZSH/oh-my-zsh.sh

# -----------------------------------------------------------------------------
# oh-my-posh Prompt (Kelomai theme)
# -----------------------------------------------------------------------------
if command -v oh-my-posh &>/dev/null; then
    eval "$(oh-my-posh init zsh --config $HOME/.config/oh-my-posh/kelomai.omp.json)"
fi

# -----------------------------------------------------------------------------
# Aliases
# -----------------------------------------------------------------------------
alias k="kubectl"
alias tf="terraform"
alias g="git"
alias ll="ls -la"
alias la="ls -A"
alias cls="clear"

# Docker aliases
alias dps="docker ps"
alias dpa="docker ps -a"
alias di="docker images"

# Git aliases (in addition to oh-my-zsh git plugin)
alias gst="git status"
alias gco="git checkout"
alias gcm="git commit -m"
alias gp="git push"
alias gl="git pull"

# -----------------------------------------------------------------------------
# History Configuration
# -----------------------------------------------------------------------------
HISTSIZE=50000
SAVEHIST=50000
HISTFILE=~/.zsh_history
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_VERIFY
setopt EXTENDED_HISTORY

# -----------------------------------------------------------------------------
# Key Bindings
# -----------------------------------------------------------------------------
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward
bindkey '^R' history-incremental-search-backward

# -----------------------------------------------------------------------------
# Environment Variables
# -----------------------------------------------------------------------------
export EDITOR="code --wait"
export VISUAL="code --wait"

# pipx (Python CLI tools)
export PATH="$HOME/.local/bin:$PATH"

# Python
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
command -v pyenv &>/dev/null && eval "$(pyenv init -)"

# Node Version Manager
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Go
export GOPATH="$HOME/go"
export PATH="$PATH:$GOPATH/bin"

# -----------------------------------------------------------------------------
# Local customizations (if exists)
# -----------------------------------------------------------------------------
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
EOF

    log_success "Created .zshrc with oh-my-zsh + oh-my-posh"
    echo ""
    echo "oh-my-zsh plugins enabled:"
    echo "  git, docker, kubectl, terraform, azure, brew, node, python, golang, dotnet, gh"
    echo "  + zsh-autosuggestions, zsh-syntax-highlighting, zsh-completions"
}

configure_terminal_font() {
    log_info "Configuring Terminal.app font..."

    # Check if MesloLGS Nerd Font is installed
    if ! fc-list | grep -qi "MesloLG.*Nerd"; then
        log_warn "Nerd Font not found, skipping Terminal.app font configuration"
        return
    fi

    # Create a custom terminal profile with Nerd Font
    # Using MesloLGS NF which is commonly used with oh-my-posh/powerlevel10k
    local font_name="MesloLGS Nerd Font"
    local font_size="14"

    # Set font for the default profile
    osascript <<EOF
tell application "Terminal"
    set font name of settings set "Basic" to "$font_name"
    set font size of settings set "Basic" to $font_size
end tell
EOF

    # Also try to set for current default profile via defaults
    defaults write com.apple.Terminal "Default Window Settings" -string "Basic"
    defaults write com.apple.Terminal "Startup Window Settings" -string "Basic"

    log_success "Terminal.app configured with $font_name ($font_size pt)"
    log_info "Restart Terminal.app for changes to take effect"
}

configure_shells() {
    log_info "Configuring shell prompts..."

    # Check if oh-my-posh is installed
    if ! command -v oh-my-posh &>/dev/null; then
        log_warn "oh-my-posh not installed, skipping shell configuration"
        return
    fi

    configure_zsh

    # Only configure PowerShell if installed
    if command -v pwsh &>/dev/null; then
        configure_powershell
    else
        log_info "PowerShell not installed, skipping pwsh configuration"
    fi

    # Configure terminal font for Nerd Font icons
    configure_terminal_font

    log_success "Shell configuration complete!"
    echo ""
    echo "Theme downloaded to: ~/.config/oh-my-posh/kelomai.omp.json"
    echo "Restart your terminal or run: source ~/.zshrc"
}

# =============================================================================
# MACOS DEVELOPER SETTINGS
# =============================================================================
configure_macos() {
    log_info "Configuring macOS developer settings..."

    # Show hidden files in Finder
    defaults write com.apple.finder AppleShowAllFiles -bool true

    # Show path bar in Finder
    defaults write com.apple.finder ShowPathbar -bool true

    # Show status bar in Finder
    defaults write com.apple.finder ShowStatusBar -bool true

    # Disable press-and-hold for keys in favor of key repeat
    defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

    # Fast key repeat rate
    defaults write NSGlobalDomain KeyRepeat -int 2
    defaults write NSGlobalDomain InitialKeyRepeat -int 15

    # Enable developer menu in Safari
    defaults write com.apple.Safari IncludeDevelopMenu -bool true

    log_success "macOS settings configured (restart Finder to apply)"
}

# =============================================================================
# VSCODE EXTENSIONS
# =============================================================================
install_vscode_extensions() {
    if command -v code &>/dev/null; then
        log_info "Installing VS Code extensions..."

        while IFS= read -r ext; do
            [[ -z "$ext" ]] && continue
            code --install-extension "$ext" --force 2>/dev/null || log_warn "Failed to install $ext"
        done < <(get_packages "vscode_extensions")

        log_success "VS Code extensions installed"
    else
        log_warn "VS Code CLI not found, skipping extensions"
    fi
}

# =============================================================================
# MAIN INSTALLATION
# =============================================================================
main() {
    # Handle --shells-only flag
    if $SHELLS_ONLY; then
        echo ""
        echo "============================================="
        echo "  Shell Configuration Only"
        echo "============================================="
        echo ""
        configure_shells
        echo ""
        log_success "Shell configuration complete!"
        echo "Restart your terminal or run: source ~/.zshrc"
        return
    fi

    echo ""
    echo "============================================="
    echo "  Mac Dev Workstation + Local LLM Setup"
    echo "============================================="
    echo ""

    # Install Homebrew first
    install_homebrew

    # Bootstrap jq (required to parse packages.json)
    bootstrap_jq

    # Load package manifest
    load_packages

    # Add taps from manifest
    log_info "Adding Homebrew taps..."
    while IFS= read -r tap; do
        [[ -z "$tap" ]] && continue
        if $DRY_RUN; then
            log_info "[DRY RUN] Would tap: $tap"
        else
            brew tap "$tap" 2>/dev/null || true
        fi
    done < <(get_packages "taps")

    # Install casks (GUI apps) from manifest
    log_info "Installing GUI applications..."
    while IFS= read -r cask; do
        [[ -z "$cask" ]] && continue
        if $DRY_RUN; then
            log_info "[DRY RUN] Would install cask: $cask"
        elif brew list --cask "$cask" &>/dev/null; then
            log_success "$cask already installed"
        else
            brew install --cask "$cask" || log_warn "Failed to install $cask"
        fi
    done < <(get_packages "casks")

    # Install formulae (CLI tools) from manifest
    # Auto-accept Microsoft EULA for SQL Server tools
    export HOMEBREW_ACCEPT_EULA=Y
    log_info "Installing CLI tools..."

    # Unlink conflicting sqlcmd if present (conflicts with mssql-tools18)
    if brew list sqlcmd &>/dev/null 2>&1; then
        log_info "Unlinking sqlcmd (conflicts with mssql-tools18)..."
        brew unlink sqlcmd 2>/dev/null || true
    fi

    while IFS= read -r formula; do
        [[ -z "$formula" ]] && continue
        if $DRY_RUN; then
            log_info "[DRY RUN] Would install formula: $formula"
        elif brew list "$formula" &>/dev/null; then
            log_success "$formula already installed"
        else
            # Handle mssql-tools18 link conflict
            if [[ "$formula" == *"mssql-tools18"* ]]; then
                brew install "$formula" && brew link --overwrite "$formula" 2>/dev/null || log_warn "Failed to install $formula"
            else
                brew install "$formula" || log_warn "Failed to install $formula"
            fi
        fi
    done < <(get_packages "formulae")

    # Install Mac App Store apps
    if $SKIP_MAS; then
        log_info "Skipping Mac App Store apps (--skip-mas flag)"
    elif $DRY_RUN; then
        log_info "[DRY RUN] Would prompt: Install Mac App Store apps?"
    else
        read -p "Install Mac App Store apps (requires App Store sign-in)? [y/N]: " -n 1 -r < /dev/tty
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            install_mas_apps
        fi
    fi

    # Setup Local LLM Stack (Ollama, llama.cpp, Open WebUI, models)
    if $DRY_RUN; then
        log_info "[DRY RUN] Would install: Ollama, llama.cpp, MLX"
        log_info "[DRY RUN] Would prompt for Open WebUI (Docker)"
        log_info "[DRY RUN] Would prompt for model downloads"
    else
        setup_local_llm_stack
    fi

    # Setup Python environment
    if $DRY_RUN; then
        log_info "[DRY RUN] Would configure Python (pipx, pyenv)"
    else
        setup_python
    fi

    # Configure macOS settings
    if $DRY_RUN; then
        log_info "[DRY RUN] Would prompt: Configure macOS developer settings?"
    else
        read -p "Configure macOS developer settings? [y/N]: " -n 1 -r < /dev/tty
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            configure_macos
        fi
    fi

    # Configure shell prompts (oh-my-posh)
    if $DRY_RUN; then
        log_info "[DRY RUN] Would prompt: Configure shell prompts?"
        log_info "[DRY RUN] Would install oh-my-zsh + plugins"
        log_info "[DRY RUN] Would download oh-my-posh theme from GitHub"
        log_info "[DRY RUN] Would create ~/.zshrc and PowerShell profile"
    else
        read -p "Configure shell prompts (zsh + pwsh with oh-my-posh)? [y/N]: " -n 1 -r < /dev/tty
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            configure_shells
        fi
    fi

    # Install VS Code extensions
    if $DRY_RUN; then
        log_info "[DRY RUN] Would prompt: Install VS Code extensions?"
    else
        read -p "Install VS Code extensions? [y/N]: " -n 1 -r < /dev/tty
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            install_vscode_extensions
        fi
    fi

    # Install Edge extensions
    if $DRY_RUN; then
        log_info "[DRY RUN] Would prompt: Configure Edge extensions?"
    else
        read -p "Configure Microsoft Edge extensions? [y/N]: " -n 1 -r < /dev/tty
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            install_edge_extensions
        fi
    fi

    # Cleanup
    if ! $DRY_RUN; then
        log_info "Cleaning up..."
        brew cleanup
    fi

    echo ""
    echo "============================================="
    log_success "Setup complete!"
    echo "============================================="
    echo ""
    echo "Next steps:"
    echo "  1. Restart your terminal (or run: source ~/.zshrc)"
    echo "  2. Start Ollama: ollama serve"
    echo "  3. Open WebUI: http://localhost:3000 (if installed)"
    echo "  4. Open LM Studio for model management"
    echo ""
    echo "Useful Ollama commands:"
    echo "  ollama list                      # Show downloaded models"
    echo "  ollama run qwen2.5-coder:32b     # Chat with coding model"
    echo "  ollama run llama3.2:3b           # Fast model for quick tasks"
    echo "  ollama ps                        # Show running models"
    echo "  ollama pull <model>              # Download a new model"
    echo ""
    echo "LLM Tools installed:"
    echo "  - Ollama:     CLI + API at http://localhost:11434"
    echo "  - MLX:        Apple Silicon native (fastest on Mac)"
    echo "  - llama.cpp:  Direct GGUF inference (llama-cli)"
    echo "  - LM Studio:  GUI for model management"
    echo "  - Jan:        Privacy-focused chat app"
    echo "  - Open WebUI: ChatGPT-like interface (Docker)"
    echo ""
    echo "MLX Quick Start:"
    echo "  mlx_lm.generate --model mlx-community/Qwen2.5-Coder-32B-Instruct-4bit --prompt 'Hello'"
    echo "  mlx_lm.server --model mlx-community/Qwen2.5-Coder-32B-Instruct-4bit --port 8080"
    echo ""
}

# Run main function
main "$@"
