#!/bin/bash
# Ubuntu Development Environment Setup for Proxmox VMs
#
# Run remotely (wget is available by default on Ubuntu):
#   wget -qO- https://raw.githubusercontent.com/kelomai/kelomai/main/ubuntu-setup/setup.sh | bash
#
# Installs:
#   Core: Git, MS Edge, GitKraken*, VS Code, Postman*, DBeaver*
#   Languages: Go*, Node.js, Python, .NET SDK, PowerShell*
#   Shell: Zsh, Oh My Zsh, Oh My Posh (Azure theme), Nerd Fonts
#   Cloud CLIs: Azure CLI, AWS CLI, Google Cloud CLI, GitHub CLI
#   Azure: Azure PowerShell (Az), Storage Explorer*
#   DevOps: Docker, Terraform, kubectl, Helm, k9s
#   Database: psql, DBeaver*
#   Utilities: jq, htop, tree, ripgrep, build-essential
#   Networking: dig, nslookup, whois, traceroute, mtr, nmap, nc, tcpdump, iftop
#   Proxmox: qemu-guest-agent, spice-vdagent
#   Remote: xrdp, openssh-server
#   Other: Claude Code, 1Password CLI
#
#   * = snap (auto-updates)
#
# Log file: ~/ubuntu-setup-<timestamp>.log

# Setup logging and error tracking
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="$HOME/ubuntu-setup-${TIMESTAMP}.log"
FAILED_INSTALLS=()
SUCCESSFUL_INSTALLS=()

# Logging function - shows on screen and logs to file
log() {
    echo "$1" | tee -a "$LOG_FILE"
}

# Install wrapper - runs commands in subshell, tracks success/failure
install_package() {
    local name="$1"
    shift
    log ""
    log "=== Installing $name ==="

    # Run all commands in subshell, capture output
    if (
        set -e
        "$@"
    ) >> "$LOG_FILE" 2>&1; then
        SUCCESSFUL_INSTALLS+=("$name")
        log "✓ $name installed successfully"
        return 0
    else
        FAILED_INSTALLS+=("$name")
        log "✗ $name FAILED - see log for details"
        return 1
    fi
}

# For multi-command installs, use this pattern
install_with_commands() {
    local name="$1"
    log ""
    log "=== Installing $name ==="

    if (
        set -e
        eval "$2"
    ) >> "$LOG_FILE" 2>&1; then
        SUCCESSFUL_INSTALLS+=("$name")
        log "✓ $name installed successfully"
        return 0
    else
        FAILED_INSTALLS+=("$name")
        log "✗ $name FAILED - see log for details"
        return 1
    fi
}

# Start
echo "=== Ubuntu Development Environment Setup ===" | tee "$LOG_FILE"
echo "Started at: $(date)" | tee -a "$LOG_FILE"
echo "Log file: $LOG_FILE" | tee -a "$LOG_FILE"
echo ""

# Update package lists
log "Updating package lists..."
sudo apt update >> "$LOG_FILE" 2>&1

# Install prerequisites
log "Installing prerequisites..."
sudo apt install -y curl wget apt-transport-https ca-certificates gnupg lsb-release software-properties-common unzip >> "$LOG_FILE" 2>&1

# 1. Git
install_package "Git" sudo apt install -y git

# 2. Microsoft Edge
install_with_commands "Microsoft Edge" '
curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /usr/share/keyrings/microsoft-edge.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-edge.gpg] https://packages.microsoft.com/repos/edge stable main" | sudo tee /etc/apt/sources.list.d/microsoft-edge.list > /dev/null
sudo apt update
sudo apt install -y microsoft-edge-stable
'

# 3. GitKraken
install_package "GitKraken" sudo snap install gitkraken --classic

# 4. PowerShell
install_package "PowerShell" sudo snap install powershell --classic

# 4b. Azure PowerShell Module
install_with_commands "Azure PowerShell Module" '
pwsh -Command "Install-Module -Name Az -Repository PSGallery -Force -Scope CurrentUser -AcceptLicense"
'

# 5. Terraform
install_with_commands "Terraform" '
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update
sudo apt install -y terraform
'

# 6. PostgreSQL client
install_package "PostgreSQL Client" sudo apt install -y postgresql-client

# 7. Go
install_package "Go" sudo snap install go --classic

# 8. Node.js + Claude Code
install_with_commands "Node.js + Claude Code" '
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt install -y nodejs
sudo npm install -g @anthropic-ai/claude-code
'

# 9. Docker
install_with_commands "Docker" '
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker $USER
'

# 10. VS Code
install_with_commands "VS Code" '
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /usr/share/keyrings/vscode-archive-keyring.gpg > /dev/null
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/vscode-archive-keyring.gpg] https://packages.microsoft.com/repos/vscode stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
sudo apt update
sudo apt install -y code
'

# 11. Azure CLI
install_with_commands "Azure CLI" '
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
'

# 12. Utilities
install_with_commands "Utilities" '
sudo apt install -y jq htop build-essential tree ripgrep openssh-server
sudo systemctl enable ssh
'

# 13. Networking Tools
install_package "Networking Tools" sudo apt install -y dnsutils whois traceroute mtr-tiny nmap netcat-openbsd tcpdump iftop net-tools

# 14. Proxmox VM Tools
install_with_commands "Proxmox VM Tools" '
sudo apt install -y qemu-guest-agent spice-vdagent
sudo systemctl enable qemu-guest-agent
'

# 15. Python
install_package "Python" sudo apt install -y python3 python3-pip python3-venv

# 16. .NET SDK
install_package ".NET SDK" sudo apt install -y dotnet-sdk-8.0

# 17. kubectl
install_with_commands "kubectl" '
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /usr/share/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update
sudo apt install -y kubectl
'

# 18. Helm
install_with_commands "Helm" '
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
'

# 19. k9s
install_with_commands "k9s" '
curl -sS https://webinstall.dev/k9s | bash
'

# 20. 1Password CLI
install_with_commands "1Password CLI" '
curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor -o /usr/share/keyrings/1password-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/amd64 stable main" | sudo tee /etc/apt/sources.list.d/1password.list
sudo apt update
sudo apt install -y 1password-cli
'

# 21. xrdp
install_with_commands "xrdp" '
sudo apt install -y xrdp
sudo systemctl enable xrdp
sudo adduser xrdp ssl-cert 2>/dev/null || true
'

# 22. Postman
install_package "Postman" sudo snap install postman

# 23. Azure Storage Explorer
install_package "Azure Storage Explorer" sudo snap install storage-explorer

# 24. GitHub CLI
install_with_commands "GitHub CLI" '
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install -y gh
'

# 25. AWS CLI
install_with_commands "AWS CLI" '
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
unzip -q /tmp/awscliv2.zip -d /tmp
sudo /tmp/aws/install --update
rm -rf /tmp/awscliv2.zip /tmp/aws
'

# 26. Google Cloud CLI
install_with_commands "Google Cloud CLI" '
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list
sudo apt update
sudo apt install -y google-cloud-cli
'

# 27. DBeaver
install_package "DBeaver" sudo snap install dbeaver-ce

# 28. Zsh + Oh My Zsh
install_with_commands "Zsh + Oh My Zsh" '
sudo apt install -y zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
sudo chsh -s $(which zsh) $USER
'

# 29. Nerd Fonts
install_with_commands "Nerd Fonts" '
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts
curl -fLo "FiraCode Nerd Font Regular.ttf" https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/FiraCode/Regular/FiraCodeNerdFont-Regular.ttf
curl -fLo "FiraCode Nerd Font Bold.ttf" https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/FiraCode/Bold/FiraCodeNerdFont-Bold.ttf
fc-cache -fv
'

# 30. Oh My Posh
install_with_commands "Oh My Posh" '
curl -s https://ohmyposh.dev/install.sh | bash -s
mkdir -p ~/.config/powershell
cat > ~/.config/powershell/Microsoft.PowerShell_profile.ps1 << PWSH_PROFILE
# Oh My Posh with Azure theme
oh-my-posh init pwsh --config ~/.cache/oh-my-posh/themes/cloud-native-azure.omp.json | Invoke-Expression
PWSH_PROFILE
'

# ============================================
# SUMMARY
# ============================================
log ""
log "============================================"
log "=== Installation Complete ==="
log "============================================"
log ""
log "Finished at: $(date)"
log ""

# Show successful installs
log "✓ SUCCESSFUL INSTALLS (${#SUCCESSFUL_INSTALLS[@]}):"
for item in "${SUCCESSFUL_INSTALLS[@]}"; do
    log "  ✓ $item"
done

# Show failed installs
if [ ${#FAILED_INSTALLS[@]} -gt 0 ]; then
    log ""
    log "✗ FAILED INSTALLS (${#FAILED_INSTALLS[@]}):"
    for item in "${FAILED_INSTALLS[@]}"; do
        log "  ✗ $item"
    done
    log ""
    log "Review the log file for error details:"
    log "  $LOG_FILE"
    log ""
    log "To search for errors: grep -i 'error\|failed' $LOG_FILE"
else
    log ""
    log "All installations completed successfully!"
fi

log ""
log "NOTES:"
log "  - Log out and back in for Docker group and Zsh shell to take effect"
log "  - RDP available on port 3389"
log "  - Configure terminal font to 'FiraCode Nerd Font' for icons"
log "  - Install 1Password browser extension in Edge manually"
log ""
log "TO UPDATE ALL PACKAGES:"
log "  wget -qO- https://raw.githubusercontent.com/kelomai/kelomai/main/ubuntu-setup/update.sh | bash"
log ""
log "Log file saved to: $LOG_FILE"
