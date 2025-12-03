# Ubuntu Development Environment Setup

Automated setup script for Ubuntu Desktop development workstations running on Proxmox VMs.

## Quick Start

Run this command on a fresh Ubuntu Desktop installation:

```bash
wget -qO- https://raw.githubusercontent.com/kelomai/kelomai/main/ubuntu-setup/setup.sh | bash
```

## What Gets Installed

### Core Applications
| Tool | Description | Install Method |
|------|-------------|----------------|
| Git | Version control | apt |
| Microsoft Edge | Web browser | apt (Microsoft repo) |
| GitKraken | Git GUI client | snap (auto-updates) |
| VS Code | Code editor | apt (Microsoft repo) |
| Postman | API testing | snap (auto-updates) |

### Programming Languages & Runtimes
| Tool | Description | Install Method |
|------|-------------|----------------|
| Go | Go programming language | snap (auto-updates) |
| Node.js 22 | JavaScript runtime | apt (NodeSource repo) |
| Python 3 | Python + pip + venv | apt |
| .NET SDK 8.0 | .NET development | apt |
| PowerShell | Cross-platform shell | snap (auto-updates) |

### Shell & Terminal
| Tool | Description | Install Method |
|------|-------------|----------------|
| Zsh | Modern shell | apt |
| Oh My Zsh | Zsh framework | install script |
| Oh My Posh | Prompt theme engine | install script |
| Nerd Fonts | FiraCode with icons | direct download |

### Cloud CLIs
| Tool | Description | Install Method |
|------|-------------|----------------|
| Azure CLI | `az` command-line tool | apt (Microsoft repo) |
| AWS CLI | `aws` command-line tool | direct install |
| Google Cloud CLI | `gcloud` command-line tool | apt (Google repo) |
| GitHub CLI | `gh` command-line tool | apt (GitHub repo) |

### Azure Tools
| Tool | Description | Install Method |
|------|-------------|----------------|
| Azure PowerShell | Az module for PowerShell | PowerShell Gallery |
| Azure Storage Explorer | GUI for Azure Storage | snap (auto-updates) |
| Oh My Posh Azure Theme | PowerShell prompt theme | auto-configured |

### DevOps & Containers
| Tool | Description | Install Method |
|------|-------------|----------------|
| Docker | Container runtime + compose | apt (Docker repo) |
| Terraform | Infrastructure as code | apt (HashiCorp repo) |
| kubectl | Kubernetes CLI | apt (Kubernetes repo) |
| Helm | Kubernetes package manager | install script |
| k9s | Kubernetes TUI | webinstall |

### Database
| Tool | Description | Install Method |
|------|-------------|----------------|
| psql | PostgreSQL client | apt |
| DBeaver | Database GUI (multi-DB) | snap (auto-updates) |

### Utilities
| Tool | Description | Install Method |
|------|-------------|----------------|
| jq | JSON processor | apt |
| htop | Process viewer | apt |
| tree | Directory tree viewer | apt |
| ripgrep | Fast search tool (`rg`) | apt |
| build-essential | C/C++ compilers | apt |

### Networking Tools
| Tool | Command | Description |
|------|---------|-------------|
| dig | `dig domain.com` | DNS lookup |
| nslookup | `nslookup domain.com` | DNS lookup |
| host | `host domain.com` | DNS lookup |
| whois | `whois domain.com` | Domain registration info |
| traceroute | `traceroute host` | Trace packet route |
| mtr | `mtr host` | Live traceroute + ping |
| nmap | `nmap -p 22,80 host` | Port scanner |
| netcat | `nc host port` | TCP/UDP connections |
| tcpdump | `tcpdump -i eth0` | Packet capture |
| iftop | `sudo iftop` | Bandwidth monitor |
| ifconfig/netstat | `ifconfig`, `netstat` | Legacy network tools |

### Proxmox VM Integration
| Tool | Description | Install Method |
|------|-------------|----------------|
| qemu-guest-agent | VM management from Proxmox | apt |
| spice-vdagent | Clipboard sharing, display resize | apt |

### Remote Access
| Tool | Port | Description |
|------|------|-------------|
| openssh-server | 22 | SSH access |
| xrdp | 3389 | Remote Desktop (RDP) |

### Other Tools
| Tool | Description | Install Method |
|------|-------------|----------------|
| Claude Code | AI coding assistant | npm |
| 1Password CLI | Password manager CLI (`op`) | apt (1Password repo) |

## Post-Installation Steps

After the script completes:

1. **Log out and back in** - Required for Docker group membership to take effect
2. **Source bashrc** (optional) - `source ~/.bashrc` if you want PATH changes immediately

## Connecting to the VM

### SSH
```bash
ssh user@vm-ip-address
```

### RDP (Remote Desktop)
Connect using any RDP client to port 3389:
- Windows: Built-in Remote Desktop Connection
- macOS: Microsoft Remote Desktop
- Linux: Remmina

## Updating Packages

### One-Command Update (recommended)

Run this to update everything at once:

```bash
wget -qO- https://raw.githubusercontent.com/kelomai/kelomai/main/ubuntu-setup/update.sh | bash
```

This updates:

- APT packages (and cleans up old ones)
- Snap packages
- NPM global packages
- Azure PowerShell module
- Helm
- k9s

### Manual Update (individual package managers)
```bash
# APT packages (most tools)
sudo apt update && sudo apt upgrade -y

# Snap packages (auto-update daily, but can force)
sudo snap refresh

# NPM global packages (Claude Code)
sudo npm update -g

# Azure PowerShell module
pwsh -Command "Update-Module Az"
```

### What Auto-Updates
These tools update automatically via snap (daily):

- GitKraken
- Go
- PowerShell
- Postman
- Azure Storage Explorer
- DBeaver

### What Needs Manual Updates
These update via `apt upgrade`:

- Git, Microsoft Edge, VS Code
- Docker, Terraform, kubectl
- Azure CLI, AWS CLI, Google Cloud CLI, GitHub CLI
- 1Password CLI
- All utilities and networking tools

## Common Commands

### Docker
```bash
docker run hello-world          # Test Docker
docker ps                       # List running containers
docker-compose up -d            # Start compose stack
```

### Kubernetes
```bash
kubectl get pods                # List pods
kubectl get nodes               # List nodes
k9s                            # Launch k9s TUI
helm list                      # List Helm releases
```

### Azure
```bash
az login                       # Login to Azure CLI
az account list                # List subscriptions
pwsh -Command "Connect-AzAccount"  # Login via PowerShell
```

### AWS

```bash
aws configure                  # Configure credentials
aws s3 ls                      # List S3 buckets
aws ec2 describe-instances     # List EC2 instances
aws sts get-caller-identity    # Check current identity
```

### Google Cloud

```bash
gcloud init                    # Initialize and login
gcloud auth login              # Login to GCP
gcloud projects list           # List projects
gcloud config set project ID   # Set active project
```

### GitHub CLI

```bash
gh auth login                  # Login to GitHub
gh repo clone owner/repo       # Clone a repository
gh pr list                     # List pull requests
gh pr create                   # Create pull request
gh issue list                  # List issues
```

### Terraform
```bash
terraform init                 # Initialize
terraform plan                 # Preview changes
terraform apply                # Apply changes
```

### DNS & Networking
```bash
dig google.com                 # DNS lookup
dig +short google.com          # Short DNS answer
nslookup google.com            # Alternative DNS lookup
whois example.com              # Domain info
mtr google.com                 # Live traceroute
nmap -p 22,80,443 host         # Scan specific ports
sudo iftop                     # Monitor bandwidth
sudo tcpdump -i eth0 port 80   # Capture HTTP traffic
```

### 1Password
```bash
op signin                      # Sign in
op item list                   # List items
op item get "Item Name"        # Get item
eval $(op signin)              # Sign in and set session
```

## Troubleshooting

### Docker permission denied
```bash
# Make sure you logged out and back in after install
# Or run:
newgrp docker
```

### Snap apps not found
```bash
# Restart your shell or run:
source /etc/profile.d/apps-bin-path.sh
```

### GPG key errors on apt update
```bash
# Re-run the key import for the failing repo
# Check /etc/apt/sources.list.d/ for repo files
```

### Proxmox clipboard not working
```bash
# Ensure spice-vdagent is running
sudo systemctl status spice-vdagent
sudo systemctl restart spice-vdagent
```

## Customization

To modify what gets installed, edit `setup.sh` and comment out sections you don't need:

```bash
# Comment out tools you don't want
# # 3. GitKraken (snap for auto-updates)
# echo ""
# echo "=== Installing GitKraken ==="
# sudo snap install gitkraken --classic
# echo "GitKraken installed"
```

## Version Info

The script installs these specific versions (where applicable):
- Node.js: 22.x (LTS)
- .NET SDK: 8.0
- kubectl: 1.31.x
- Go: Latest via snap

Other tools install the latest stable version from their respective repositories.
