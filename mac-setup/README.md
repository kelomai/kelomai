# Mac Development Workstation Setup

Automated setup script for a Mac development workstation optimized for **software development** and **local LLM inference**.

Target machine: **Mac Studio Ultra with 96GB unified memory**

## Quick Start

```bash
# Make executable and run
chmod +x setup.sh
./setup.sh

# Or run remotely
curl -fsSL https://raw.githubusercontent.com/kelomai/kelomai/main/mac-setup/setup.sh | bash
```

---

## What Gets Installed

### 1. Package Manager
| Tool | Purpose |
|------|---------|
| **Homebrew** | macOS package manager (auto-detects Apple Silicon vs Intel) |

### 2. GUI Applications (Casks)

| Category | Apps |
|----------|------|
| **Browsers** | Firefox, Google Chrome, Microsoft Edge |
| **Code Editors** | VS Code |
| **Git Tools** | GitHub Desktop, GitKraken, GitKraken CLI |
| **Terminals** | Warp |
| **Containers** | Docker Desktop |
| **LLM/AI Tools** | LM Studio, Jan, ChatGPT, Claude |
| **Communication** | Slack, Signal, Telegram, WhatsApp |
| **Microsoft/Azure** | PowerShell, Azure Storage Explorer, Office 365 (includes OneDrive) |
| **Productivity** | 1Password CLI, Adobe Acrobat Pro, Spotify, Snagit, Raycast, Notion |
| **Hardware** | DisplayLink drivers, Elgato Stream Deck |
| **Fonts** | Fira Code Nerd Font, Meslo LG Nerd Font, JetBrains Mono Nerd Font |

### 3. Mac App Store Apps (via `mas`)

| App | Purpose |
|-----|---------|
| **Xcode** | Apple development tools |
| **WireGuard** | VPN client |
| **Magnet** | Window manager |
| **Amphetamine** | Prevent Mac from sleeping |
| **Vimari** | Vim keybindings for Safari |
| **CleanMyMac X** | System cleanup & optimization |
| **Paste** | Clipboard manager |
| **CapCut** | Video editor |

### 4. CLI Tools (Formulae)

| Category | Tools |
|----------|-------|
| **Core Dev** | git, gh, curl, wget, jq, tree, watch, htop |
| **Languages** | Python 3.13, Node.js, Go, .NET SDK, OpenJDK 21 |
| **Version Managers** | pyenv, nvm |
| **Python** | pipx, poetry (via pipx) |
| **IaC** | Terraform, Terraform-docs, Packer |
| **Kubernetes** | kubectl, kubelogin |
| **Azure** | azure-cli, azcopy, azd |
| **Database** | PostgreSQL 16, sqlcmd, msodbcsql18 |
| **Network** | tcping, unbound |
| **Shell** | oh-my-posh |

---

## Local LLM Stack

The script installs a complete local LLM stack optimized for the 96GB Mac Studio Ultra:

### LLM Tools Comparison

| Tool | Type | Best For | Speed on Mac |
|------|------|----------|--------------|
| **Ollama** | CLI + API | Easy model management, OpenAI-compatible API | Fast |
| **MLX** | Python lib | Native Apple Silicon, maximum performance | **Fastest** |
| **llama.cpp** | CLI | Custom GGUF models, fine-tuned control | Fast |
| **LM Studio** | GUI | Browsing/downloading models, visual interface | Fast |
| **Jan** | GUI | Privacy-focused, offline chat | Fast |
| **Open WebUI** | Web UI | ChatGPT-like interface (connects to Ollama) | Via Ollama |

### When to Use Each Tool

```
Need something quick?          → ollama run llama3.2:3b
Need maximum performance?      → MLX with mlx_lm.server
Want a ChatGPT-like UI?        → Open WebUI (localhost:3000)
Exploring new models?          → LM Studio
Want offline privacy?          → Jan
Building custom pipelines?     → llama.cpp
```

### Recommended Models for 96GB RAM

#### Ollama Models
```bash
# Coding (Best)
ollama pull qwen2.5-coder:32b          # 18GB - Best local coding model
ollama pull deepseek-coder-v2:16b      # 9GB  - Fast code completion
ollama pull codellama:34b              # 19GB - Meta's code model

# General Purpose
ollama pull llama3.3:70b-instruct-q4_K_M  # 40GB - Most capable
ollama pull qwen2.5:32b                   # 18GB - Excellent all-around
ollama pull mixtral:8x7b                  # 26GB - Fast MoE model

# Fast/Small (instant responses)
ollama pull llama3.2:3b                # 2GB  - Very fast
ollama pull qwen2.5-coder:7b           # 4GB  - Good balance

# Specialized
ollama pull nomic-embed-text           # 274MB - Embeddings for RAG
ollama pull llava:34b                  # 19GB  - Vision model
```

#### MLX Models (Apple Silicon Native)
```bash
# Download from Hugging Face
huggingface-cli download mlx-community/Qwen2.5-Coder-32B-Instruct-4bit
huggingface-cli download mlx-community/Meta-Llama-3.1-70B-Instruct-4bit
huggingface-cli download mlx-community/deepseek-coder-33b-instruct-4bit

# Run interactively
mlx_lm.generate --model mlx-community/Qwen2.5-Coder-32B-Instruct-4bit --prompt "Hello"

# Start OpenAI-compatible server
mlx_lm.server --model mlx-community/Qwen2.5-Coder-32B-Instruct-4bit --port 8080
```

---

## API Endpoints (After Setup)

| Service | URL | Protocol |
|---------|-----|----------|
| **Ollama** | http://localhost:11434 | OpenAI-compatible |
| **MLX Server** | http://localhost:8080 | OpenAI-compatible |
| **Open WebUI** | http://localhost:3000 | Web interface |

### Example: Using Ollama API
```bash
curl http://localhost:11434/api/generate -d '{
  "model": "qwen2.5-coder:32b",
  "prompt": "Write a Python function to reverse a string",
  "stream": false
}'
```

---

## Post-Install Configuration

The script optionally configures:

### macOS Developer Settings
- Show hidden files in Finder
- Show path bar and status bar in Finder
- Fast key repeat rate
- Enable Safari developer menu

### VS Code Extensions
- Python, Pylance
- Docker
- Terraform
- GitHub Copilot + Chat
- Continue (local LLM integration)
- C#, Go
- Prettier, GitLens

### Python Environment
- pyenv for version management
- pipx for isolated CLI tools
- poetry, httpie, litellm via pipx

---

## Directory Structure

```
mac-setup/
├── README.md       # This file
├── setup.sh        # Main setup script
└── home-brew.sh    # (Reserved for future use)
```

---

## Useful Commands After Setup

```bash
# Ollama
ollama list                      # Show downloaded models
ollama run qwen2.5-coder:32b     # Chat with coding model
ollama ps                        # Show running models
ollama serve                     # Start Ollama server

# MLX
mlx_lm.generate --model <model> --prompt "Hello"
mlx_lm.server --model <model> --port 8080

# Open WebUI
docker start open-webui          # Start the container
docker stop open-webui           # Stop the container

# Python
pyenv install 3.13               # Install Python version
pyenv global 3.13                # Set global version
poetry new myproject             # Create new project

# System
brew update && brew upgrade      # Update all packages
brew cleanup                     # Remove old versions
```

---

## Memory Usage Guide (96GB)

With 96GB unified memory, you can run:

| Configuration | Memory Used | Remaining |
|---------------|-------------|-----------|
| qwen2.5-coder:32b | ~18GB | 78GB |
| llama3.3:70b (Q4) | ~40GB | 56GB |
| qwen2.5-coder:32b + llama3.2:3b | ~20GB | 76GB |
| Multiple 7B models | ~4GB each | Lots |

**Tip**: You can run multiple models simultaneously. Ollama keeps recently used models in memory for fast switching.

---

## Shell Configuration

The setup configures both **Zsh** and **PowerShell** with a consistent experience:

### oh-my-zsh + oh-my-posh (Zsh)

The script installs:
- **oh-my-zsh** - Framework for managing Zsh configuration
- **oh-my-posh** - Cross-platform prompt theme engine
- **Kelomai theme** - Custom theme with git, kubernetes, azure, battery status

**Plugins enabled:**
```
git, docker, docker-compose, kubectl, terraform, azure, brew,
node, python, pip, golang, dotnet, vscode, gh,
zsh-autosuggestions, zsh-syntax-highlighting, zsh-completions
```

**Features:**
- Fish-like autosuggestions as you type
- Syntax highlighting for commands
- Extensive completions for all dev tools
- Git status in prompt
- Kubernetes context display
- Azure subscription display

### PowerShell with oh-my-posh

PowerShell gets:
- Same Kelomai theme as Zsh
- PSReadLine with history-based predictions
- Aliases: `k` (kubectl), `tf` (terraform), `g` (git)

### Theme Files

The oh-my-posh theme is downloaded from:
```
https://raw.githubusercontent.com/kelomai/kelomai/main/oh-my-posh/kelomai.omp.json
```

Stored locally at: `~/.config/oh-my-posh/kelomai.omp.json`

---

## Troubleshooting

### Homebrew not found after install
```bash
# Apple Silicon
eval "$(/opt/homebrew/bin/brew shellenv)"

# Intel
eval "$(/usr/local/bin/brew shellenv)"
```

### Ollama not starting
```bash
ollama serve  # Start manually in foreground to see errors
```

### MLX import error
```bash
/opt/homebrew/bin/python3 -m pip install --upgrade mlx mlx-lm
```

### Open WebUI not connecting to Ollama
```bash
# Ensure Ollama is running
ollama serve

# Restart Open WebUI container
docker restart open-webui
```
