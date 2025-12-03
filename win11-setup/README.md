# Windows 11 Development Workstation Setup

Scripts for setting up a Windows 11 development workstation optimized for **software development** and **local LLM inference**.

## Scripts

| Script | Purpose |
|--------|---------|
| `setup.ps1` | Install development tools, languages, and LLM stack |
| `Debloat-Windows.ps1` | Debloat Windows 11 (remove bloatware, telemetry, consumer features) |

---

## Quick Start

### Development Setup

```powershell
# Run as Administrator
.\setup.ps1

# Preview without making changes
.\setup.ps1 -DryRun

# Remote execution
irm https://raw.githubusercontent.com/kelomai/kelomai/main/win11-setup/setup.ps1 | iex
```

### Windows Debloat (for clean templates)

```powershell
# Run as Administrator
.\Debloat-Windows.ps1

# Remote execution
irm https://raw.githubusercontent.com/kelomai/kelomai/main/win11-setup/Debloat-Windows.ps1 | iex
```

---

## What Gets Installed (setup.ps1)

### GUI Applications

| Category | Apps |
|----------|------|
| **Browsers** | Firefox, Google Chrome, Microsoft Edge |
| **Code Editors** | VS Code |
| **Git Tools** | GitHub Desktop, GitKraken |
| **Terminals** | Windows Terminal, Warp |
| **Containers** | Docker Desktop |
| **LLM/AI Tools** | LM Studio, Ollama, ChatGPT, Claude |
| **Communication** | Slack, Signal, Telegram, WhatsApp |
| **Microsoft/Azure** | PowerShell 7, Azure Storage Explorer, Office, OneDrive |
| **Productivity** | 1Password, Notion, Spotify, Snagit, Raycast |
| **Fonts** | Fira Code Nerd Font, JetBrains Mono Nerd Font |

### CLI Tools

| Category | Tools |
|----------|-------|
| **Core Dev** | git, gh (GitHub CLI), curl, jq |
| **Languages** | Python 3.13, Node.js, Go, .NET SDK 8, OpenJDK 21 |
| **IaC** | Terraform, Packer |
| **Kubernetes** | kubectl, Helm |
| **Azure** | azure-cli, azd |
| **Database** | PostgreSQL, SQL Server Management Studio |
| **Shell** | oh-my-posh |

### VS Code Extensions

- Python, Pylance
- Docker
- Terraform
- GitHub Copilot + Chat
- Continue (local LLM integration)
- C#, Go
- Prettier, GitLens

---

## Local LLM Stack

### Recommended Models

```powershell
# Coding (Best)
ollama pull qwen2.5-coder:32b      # 18GB - Best coding model
ollama pull deepseek-coder-v2:16b  # 9GB - Fast code completion

# General Purpose
ollama pull llama3.3:70b           # 40GB - Most capable
ollama pull qwen2.5:32b            # 18GB - Excellent all-around

# Fast/Small
ollama pull llama3.2:3b            # 2GB - Very fast
```

### Usage

```powershell
# Start Ollama server
ollama serve

# Chat with a model
ollama run qwen2.5-coder:32b

# API endpoint
# http://localhost:11434
```

---

## Shell Configuration (oh-my-posh)

The setup script configures PowerShell with:

- **oh-my-posh** prompt theme (Kelomai theme)
- PSReadLine with history-based predictions
- Aliases: `k` (kubectl), `tf` (terraform), `g` (git)

Theme file: `~\.config\oh-my-posh\kelomai.omp.json`

---

## Windows Debloat (Debloat-Windows.ps1)

Use this script to prepare a clean Windows 11 image for development or corporate use.

### What It Removes

- **Bloatware**: Bing apps, Xbox, Solitaire, Teams, Clipchamp, etc.
- **OneDrive**: Complete removal including Explorer integration
- **Telemetry**: Data collection, activity history, diagnostics
- **Consumer Features**: Automatic app installs, suggestions, tips
- **Cortana**: Disabled along with web search in Start Menu
- **Unnecessary Services**: Xbox services, retail demo, telemetry services

### What It Disables

- Advertising ID
- Location tracking
- Feedback notifications
- Windows Spotlight
- Game DVR

### For Sysprep Templates

The script applies settings to the default user profile, so new users will have the same clean experience.

---

## Requirements

- Windows 11
- PowerShell 5.1+ (or PowerShell 7)
- Administrator privileges
- winget (App Installer from Microsoft Store)

---

## Troubleshooting

### winget not found

Install "App Installer" from the Microsoft Store, or run:

```powershell
Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe
```

### oh-my-posh not rendering correctly

Install a Nerd Font and configure your terminal to use it:

```powershell
# The setup script installs these fonts:
# - Fira Code Nerd Font
# - JetBrains Mono Nerd Font
```

Then set the font in Windows Terminal settings.

### Ollama not starting

Run manually to see errors:

```powershell
ollama serve
```

---

## Post-Install Checklist

- [ ] Restart PowerShell to load oh-my-posh
- [ ] Set terminal font to a Nerd Font
- [ ] Start Docker Desktop
- [ ] Run `ollama serve` and pull models
- [ ] Sign into VS Code and sync settings
- [ ] Configure git: `git config --global user.name` / `user.email`
