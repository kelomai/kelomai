#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Windows 11 Development Workstation Setup Script
.DESCRIPTION
    Installs development tools, languages, and local LLM stack
    Optimized for software development + local LLMs
.PARAMETER DryRun
    Preview what would be installed without making changes
.EXAMPLE
    .\setup.ps1
    .\setup.ps1 -DryRun
.NOTES
    Remote execution:
    irm https://raw.githubusercontent.com/kelomai/kelomai/main/win11-setup/setup.ps1 | iex
#>

param(
    [switch]$DryRun
)

# =============================================================================
# CONFIGURATION
# =============================================================================
$ErrorActionPreference = "Continue"

if ($DryRun) {
    Write-Host "=============================================" -ForegroundColor Cyan
    Write-Host "  DRY RUN MODE - No changes will be made" -ForegroundColor Cyan
    Write-Host "=============================================" -ForegroundColor Cyan
    Write-Host ""
}

Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "  Windows 11 Dev Workstation Setup" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

# =============================================================================
# WINGET PACKAGES
# =============================================================================

# GUI Applications
$wingetApps = @(
    # --- Browsers ---
    @{id = "Mozilla.Firefox"; name = "Firefox" }
    @{id = "Google.Chrome"; name = "Chrome" }
    @{id = "Microsoft.Edge"; name = "Edge" }

    # --- Development Tools ---
    @{id = "Microsoft.VisualStudioCode"; name = "VS Code" }
    @{id = "GitHub.GitHubDesktop"; name = "GitHub Desktop" }
    @{id = "Axosoft.GitKraken"; name = "GitKraken" }
    @{id = "Docker.DockerDesktop"; name = "Docker Desktop" }
    @{id = "ScooterSoftware.BeyondCompare4"; name = "Beyond Compare" }
    @{id = "Warp.Warp"; name = "Warp Terminal" }
    @{id = "Microsoft.WindowsTerminal"; name = "Windows Terminal" }

    # --- AI/LLM Tools ---
    @{id = "LMStudio.LMStudio"; name = "LM Studio" }
    @{id = "Ollama.Ollama"; name = "Ollama" }
    @{id = "OpenAI.ChatGPT"; name = "ChatGPT" }
    @{id = "Anthropic.Claude"; name = "Claude" }

    # --- Communication ---
    @{id = "SlackTechnologies.Slack"; name = "Slack" }
    @{id = "OpenWhisperSystems.Signal"; name = "Signal" }
    @{id = "Telegram.TelegramDesktop"; name = "Telegram" }
    @{id = "WhatsApp.WhatsApp"; name = "WhatsApp" }

    # --- Microsoft/Azure ---
    @{id = "Microsoft.PowerShell"; name = "PowerShell 7" }
    @{id = "Microsoft.AzureStorageExplorer"; name = "Azure Storage Explorer" }
    @{id = "Microsoft.Office"; name = "Microsoft Office" }
    @{id = "Microsoft.OneDrive"; name = "OneDrive" }

    # --- Productivity ---
    @{id = "AgileBits.1Password"; name = "1Password" }
    @{id = "Notion.Notion"; name = "Notion" }
    @{id = "Spotify.Spotify"; name = "Spotify" }
    @{id = "TechSmith.Snagit"; name = "Snagit" }
    @{id = "Raycast.Raycast"; name = "Raycast" }

    # --- Fonts ---
    @{id = "NerdFonts.FiraCode"; name = "Fira Code Nerd Font" }
    @{id = "NerdFonts.JetBrainsMono"; name = "JetBrains Mono Nerd Font" }
)

# CLI Tools
$wingetCLI = @(
    # --- Core Development ---
    @{id = "Git.Git"; name = "Git" }
    @{id = "GitHub.cli"; name = "GitHub CLI" }
    @{id = "cURL.cURL"; name = "cURL" }
    @{id = "stedolan.jq"; name = "jq" }

    # --- Languages & Runtimes ---
    @{id = "Python.Python.3.13"; name = "Python 3.13" }
    @{id = "OpenJS.NodeJS"; name = "Node.js" }
    @{id = "GoLang.Go"; name = "Go" }
    @{id = "Microsoft.DotNet.SDK.8"; name = ".NET SDK 8" }
    @{id = "EclipseAdoptium.Temurin.21.JDK"; name = "OpenJDK 21" }

    # --- Infrastructure as Code ---
    @{id = "Hashicorp.Terraform"; name = "Terraform" }
    @{id = "Hashicorp.Packer"; name = "Packer" }

    # --- Kubernetes & Containers ---
    @{id = "Kubernetes.kubectl"; name = "kubectl" }
    @{id = "Helm.Helm"; name = "Helm" }

    # --- Azure ---
    @{id = "Microsoft.AzureCLI"; name = "Azure CLI" }
    @{id = "Microsoft.Azd"; name = "Azure Developer CLI" }

    # --- Database ---
    @{id = "PostgreSQL.PostgreSQL"; name = "PostgreSQL" }
    @{id = "Microsoft.SQLServerManagementStudio"; name = "SQL Server Management Studio" }

    # --- Shell ---
    @{id = "JanDeDobbeleer.OhMyPosh"; name = "oh-my-posh" }
)

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

function Write-Step {
    param([string]$Message)
    Write-Host "`n$Message" -ForegroundColor Yellow
}

function Write-Success {
    param([string]$Message)
    Write-Host "  [OK] $Message" -ForegroundColor Green
}

function Write-Info {
    param([string]$Message)
    Write-Host "  $Message" -ForegroundColor Gray
}

function Write-Warn {
    param([string]$Message)
    Write-Host "  [WARN] $Message" -ForegroundColor Yellow
}

function Install-WingetPackage {
    param(
        [string]$Id,
        [string]$Name
    )

    if ($DryRun) {
        Write-Info "[DRY RUN] Would install: $Name ($Id)"
        return
    }

    # Check if already installed
    $installed = winget list --id $Id 2>$null | Select-String $Id
    if ($installed) {
        Write-Success "$Name already installed"
    }
    else {
        Write-Info "Installing $Name..."
        winget install --id $Id --accept-package-agreements --accept-source-agreements --silent
        if ($LASTEXITCODE -eq 0) {
            Write-Success "$Name installed"
        }
        else {
            Write-Warn "Failed to install $Name"
        }
    }
}

# =============================================================================
# MAIN INSTALLATION
# =============================================================================

# Check for winget
Write-Step "[1/7] Checking winget..."
if (!(Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "  ERROR: winget not found. Please install App Installer from Microsoft Store." -ForegroundColor Red
    exit 1
}
Write-Success "winget available"

# Install GUI Applications
Write-Step "[2/7] Installing GUI applications ($($wingetApps.Count) apps)..."
foreach ($app in $wingetApps) {
    Install-WingetPackage -Id $app.id -Name $app.name
}

# Install CLI Tools
Write-Step "[3/7] Installing CLI tools ($($wingetCLI.Count) tools)..."
foreach ($tool in $wingetCLI) {
    Install-WingetPackage -Id $tool.id -Name $tool.name
}

# =============================================================================
# LOCAL LLM SETUP
# =============================================================================
Write-Step "[4/7] Setting up Local LLM stack..."

if ($DryRun) {
    Write-Info "[DRY RUN] Would configure Ollama"
    Write-Info "[DRY RUN] Would display model recommendations"
}
else {
    Write-Host ""
    Write-Host "  Recommended Ollama models:" -ForegroundColor Cyan
    Write-Host "    ollama pull qwen2.5-coder:32b     # Best coding model" -ForegroundColor Gray
    Write-Host "    ollama pull llama3.2:3b           # Fast, small model" -ForegroundColor Gray
    Write-Host "    ollama pull llama3.3:70b          # Most capable" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  Start Ollama: ollama serve" -ForegroundColor Gray
    Write-Host "  API endpoint: http://localhost:11434" -ForegroundColor Gray
}

# =============================================================================
# PYTHON SETUP
# =============================================================================
Write-Step "[5/7] Configuring Python environment..."

if ($DryRun) {
    Write-Info "[DRY RUN] Would install pipx and poetry"
}
else {
    # Install pipx
    if (Get-Command pipx -ErrorAction SilentlyContinue) {
        Write-Success "pipx already installed"
    }
    else {
        Write-Info "Installing pipx..."
        python -m pip install --user pipx
        python -m pipx ensurepath
    }

    # Install poetry via pipx
    $poetryInstalled = pipx list 2>$null | Select-String "poetry"
    if ($poetryInstalled) {
        Write-Success "poetry already installed"
    }
    else {
        Write-Info "Installing poetry..."
        pipx install poetry
    }
}

# =============================================================================
# SHELL CONFIGURATION (oh-my-posh)
# =============================================================================
Write-Step "[6/7] Configuring PowerShell with oh-my-posh..."

$ompConfigDir = "$env:USERPROFILE\.config\oh-my-posh"
$ompConfig = "$ompConfigDir\kelomai.omp.json"
$profilePath = $PROFILE.CurrentUserAllHosts

if ($DryRun) {
    Write-Info "[DRY RUN] Would download oh-my-posh theme"
    Write-Info "[DRY RUN] Would configure PowerShell profile"
}
else {
    # Create config directory
    if (!(Test-Path $ompConfigDir)) {
        New-Item -ItemType Directory -Path $ompConfigDir -Force | Out-Null
    }

    # Download theme
    Write-Info "Downloading oh-my-posh theme..."
    $themeUrl = "https://raw.githubusercontent.com/kelomai/kelomai/main/oh-my-posh/kelomai.omp.json"
    try {
        Invoke-WebRequest -Uri $themeUrl -OutFile $ompConfig -UseBasicParsing
        Write-Success "Theme downloaded to $ompConfig"
    }
    catch {
        Write-Warn "Failed to download theme: $_"
    }

    # Create/update PowerShell profile
    $profileDir = Split-Path $profilePath -Parent
    if (!(Test-Path $profileDir)) {
        New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
    }

    $ompInit = @"

# oh-my-posh prompt (Kelomai theme)
oh-my-posh init pwsh --config "`$env:USERPROFILE\.config\oh-my-posh\kelomai.omp.json" | Invoke-Expression

# Aliases
Set-Alias -Name k -Value kubectl
Set-Alias -Name tf -Value terraform
Set-Alias -Name g -Value git

# PSReadLine configuration
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
"@

    if (Test-Path $profilePath) {
        $existingProfile = Get-Content $profilePath -Raw
        if ($existingProfile -notmatch "oh-my-posh init pwsh") {
            Add-Content -Path $profilePath -Value $ompInit
            Write-Success "Added oh-my-posh to PowerShell profile"
        }
        else {
            Write-Success "PowerShell profile already configured"
        }
    }
    else {
        Set-Content -Path $profilePath -Value $ompInit
        Write-Success "Created PowerShell profile with oh-my-posh"
    }
}

# =============================================================================
# VS CODE EXTENSIONS
# =============================================================================
Write-Step "[7/7] Installing VS Code extensions..."

$vscodeExtensions = @(
    "ms-python.python"
    "ms-python.vscode-pylance"
    "ms-azuretools.vscode-docker"
    "hashicorp.terraform"
    "github.copilot"
    "github.copilot-chat"
    "continue.continue"
    "ms-dotnettools.csharp"
    "golang.go"
    "esbenp.prettier-vscode"
    "eamodio.gitlens"
)

if ($DryRun) {
    foreach ($ext in $vscodeExtensions) {
        Write-Info "[DRY RUN] Would install extension: $ext"
    }
}
else {
    if (Get-Command code -ErrorAction SilentlyContinue) {
        foreach ($ext in $vscodeExtensions) {
            Write-Info "Installing $ext..."
            code --install-extension $ext --force 2>$null
        }
        Write-Success "VS Code extensions installed"
    }
    else {
        Write-Warn "VS Code CLI not found, skipping extensions"
    }
}

# =============================================================================
# COMPLETE
# =============================================================================
Write-Host ""
Write-Host "=============================================" -ForegroundColor Green
Write-Host "  Setup Complete!" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Restart PowerShell to load oh-my-posh" -ForegroundColor White
Write-Host "  2. Start Ollama: ollama serve" -ForegroundColor White
Write-Host "  3. Pull a model: ollama pull qwen2.5-coder:32b" -ForegroundColor White
Write-Host ""
Write-Host "Useful commands:" -ForegroundColor Cyan
Write-Host "  ollama list              # Show downloaded models" -ForegroundColor Gray
Write-Host "  ollama run <model>       # Chat with a model" -ForegroundColor Gray
Write-Host "  winget upgrade --all     # Update all packages" -ForegroundColor Gray
Write-Host ""
