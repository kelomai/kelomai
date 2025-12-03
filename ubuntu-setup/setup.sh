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

set -e

echo "=== Ubuntu Development Environment Setup ==="
echo ""

# Update package lists
echo "Updating package lists..."
sudo apt update

# Install prerequisites
echo "Installing prerequisites..."
sudo apt install -y curl wget apt-transport-https ca-certificates gnupg lsb-release software-properties-common unzip

# 1. Git
echo ""
echo "=== Installing Git ==="
sudo apt install -y git
git --version

# 2. Microsoft Edge
echo ""
echo "=== Installing Microsoft Edge ==="
curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /usr/share/keyrings/microsoft-edge.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-edge.gpg] https://packages.microsoft.com/repos/edge stable main" | sudo tee /etc/apt/sources.list.d/microsoft-edge.list > /dev/null
sudo apt update
sudo apt install -y microsoft-edge-stable
echo "Microsoft Edge installed"

# 3. GitKraken (snap for auto-updates)
echo ""
echo "=== Installing GitKraken ==="
sudo snap install gitkraken --classic
echo "GitKraken installed"

# 4. PowerShell (pwsh) + Azure PowerShell Module
echo ""
echo "=== Installing PowerShell ==="
sudo snap install powershell --classic
pwsh --version

# Install Azure PowerShell module
echo "Installing Azure PowerShell module..."
pwsh -Command "Install-Module -Name Az -Repository PSGallery -Force -Scope CurrentUser"
echo "Azure PowerShell module installed"

# 5. Terraform
echo ""
echo "=== Installing Terraform ==="
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update
sudo apt install -y terraform
terraform --version

# 6. PostgreSQL client (psql)
echo ""
echo "=== Installing PostgreSQL Client ==="
sudo apt install -y postgresql-client
psql --version

# 7. Go (snap for auto-updates)
echo ""
echo "=== Installing Go ==="
sudo snap install go --classic
go version

# 8. Claude Code
echo ""
echo "=== Installing Claude Code ==="
# Claude Code requires Node.js - install via NodeSource
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt install -y nodejs
npm --version

# Install Claude Code globally
sudo npm install -g @anthropic-ai/claude-code
echo "Claude Code installed"

# 9. Docker
echo ""
echo "=== Installing Docker ==="
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker $USER
docker --version
echo "Docker installed (log out and back in for group membership to take effect)"

# 10. VS Code
echo ""
echo "=== Installing VS Code ==="
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /usr/share/keyrings/vscode-archive-keyring.gpg > /dev/null
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/vscode-archive-keyring.gpg] https://packages.microsoft.com/repos/vscode stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
sudo apt update
sudo apt install -y code
echo "VS Code installed"

# 11. Azure CLI
echo ""
echo "=== Installing Azure CLI ==="
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
az --version | head -n1

# 12. Utilities (jq, htop, build-essential, tree, ripgrep)
echo ""
echo "=== Installing Utilities ==="
sudo apt install -y jq htop build-essential tree ripgrep openssh-server
sudo systemctl enable ssh
echo "Utilities installed"

# 13. Networking Tools
echo ""
echo "=== Installing Networking Tools ==="
sudo apt install -y dnsutils whois traceroute mtr-tiny nmap netcat-openbsd tcpdump iftop net-tools
echo "Networking tools installed (dig, nslookup, host, whois, traceroute, mtr, nmap, nc, tcpdump, iftop)"

# 14. Proxmox VM Tools
echo ""
echo "=== Installing Proxmox VM Tools ==="
sudo apt install -y qemu-guest-agent spice-vdagent
sudo systemctl enable qemu-guest-agent
echo "Proxmox VM tools installed"

# 14. Python
echo ""
echo "=== Installing Python ==="
sudo apt install -y python3 python3-pip python3-venv
python3 --version

# 15. .NET SDK
echo ""
echo "=== Installing .NET SDK ==="
sudo apt install -y dotnet-sdk-8.0
dotnet --version

# 16. kubectl
echo ""
echo "=== Installing kubectl ==="
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /usr/share/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update
sudo apt install -y kubectl
kubectl version --client

# 17. Helm
echo ""
echo "=== Installing Helm ==="
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm version

# 18. k9s
echo ""
echo "=== Installing k9s ==="
curl -sS https://webinstall.dev/k9s | bash
echo "k9s installed"

# 19. 1Password CLI
echo ""
echo "=== Installing 1Password CLI ==="
curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor -o /usr/share/keyrings/1password-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/amd64 stable main" | sudo tee /etc/apt/sources.list.d/1password.list
sudo apt update
sudo apt install -y 1password-cli
op --version

# 20. xrdp (Remote Desktop)
echo ""
echo "=== Installing xrdp ==="
sudo apt install -y xrdp
sudo systemctl enable xrdp
sudo adduser xrdp ssl-cert
echo "xrdp installed (RDP on port 3389)"

# 21. Postman
echo ""
echo "=== Installing Postman ==="
sudo snap install postman
echo "Postman installed"

# 22. Azure Storage Explorer
echo ""
echo "=== Installing Azure Storage Explorer ==="
sudo snap install storage-explorer
echo "Azure Storage Explorer installed"

# 23. GitHub CLI
echo ""
echo "=== Installing GitHub CLI ==="
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install -y gh
gh --version

# 24. AWS CLI
echo ""
echo "=== Installing AWS CLI ==="
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
unzip -q /tmp/awscliv2.zip -d /tmp
sudo /tmp/aws/install --update
rm -rf /tmp/awscliv2.zip /tmp/aws
aws --version

# 25. Google Cloud CLI
echo ""
echo "=== Installing Google Cloud CLI ==="
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list
sudo apt update
sudo apt install -y google-cloud-cli
gcloud --version | head -n1

# 26. DBeaver (Database GUI)
echo ""
echo "=== Installing DBeaver ==="
sudo snap install dbeaver-ce
echo "DBeaver Community Edition installed"

# 27. Zsh + Oh My Zsh
echo ""
echo "=== Installing Zsh + Oh My Zsh ==="
sudo apt install -y zsh
# Install Oh My Zsh (unattended)
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
# Set zsh as default shell
sudo chsh -s $(which zsh) $USER
echo "Zsh + Oh My Zsh installed (will be default shell after re-login)"

# 28. Nerd Fonts (FiraCode)
echo ""
echo "=== Installing Nerd Fonts ==="
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts
curl -fLo "FiraCode Nerd Font Regular.ttf" https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/FiraCode/Regular/FiraCodeNerdFont-Regular.ttf
curl -fLo "FiraCode Nerd Font Bold.ttf" https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/FiraCode/Bold/FiraCodeNerdFont-Bold.ttf
fc-cache -fv
cd -
echo "Nerd Fonts (FiraCode) installed"

# 29. Oh My Posh (for PowerShell)
echo ""
echo "=== Installing Oh My Posh ==="
curl -s https://ohmyposh.dev/install.sh | bash -s
# Configure Oh My Posh for PowerShell with Azure theme
mkdir -p ~/.config/powershell
cat > ~/.config/powershell/Microsoft.PowerShell_profile.ps1 << 'PWSH_PROFILE'
# Oh My Posh with Azure theme
oh-my-posh init pwsh --config ~/.cache/oh-my-posh/themes/cloud-native-azure.omp.json | Invoke-Expression
PWSH_PROFILE
echo "Oh My Posh installed with Azure theme for PowerShell"

echo ""
echo "=== Installation Complete ==="
echo ""
echo "Installed software:"
echo "  - Git: $(git --version)"
echo "  - Microsoft Edge"
echo "  - GitKraken (snap)"
echo "  - PowerShell: $(pwsh --version)"
echo "  - Azure PowerShell module (Az)"
echo "  - Oh My Posh (Azure theme)"
echo "  - Terraform: $(terraform --version | head -n1)"
echo "  - PostgreSQL client: $(psql --version)"
echo "  - Go: $(go version) (snap)"
echo "  - Node.js: $(node --version)"
echo "  - Claude Code"
echo "  - Docker: $(docker --version)"
echo "  - VS Code"
echo "  - Azure CLI: $(az --version | head -n1)"
echo "  - AWS CLI: $(aws --version)"
echo "  - Google Cloud CLI: $(gcloud --version | head -n1)"
echo "  - Azure Storage Explorer (snap)"
echo "  - Utilities: jq, htop, build-essential, tree, ripgrep, openssh-server"
echo "  - Networking: dig, nslookup, whois, traceroute, mtr, nmap, nc, tcpdump, iftop"
echo "  - Proxmox: qemu-guest-agent, spice-vdagent"
echo "  - Python: $(python3 --version)"
echo "  - .NET SDK: $(dotnet --version)"
echo "  - kubectl: $(kubectl version --client --short 2>/dev/null || kubectl version --client)"
echo "  - Helm: $(helm version --short)"
echo "  - k9s"
echo "  - GitHub CLI: $(gh --version | head -n1)"
echo "  - 1Password CLI: $(op --version)"
echo "  - DBeaver (snap)"
echo "  - Zsh + Oh My Zsh"
echo "  - Nerd Fonts (FiraCode)"
echo "  - xrdp (RDP on port 3389)"
echo "  - Postman (snap)"
echo ""
echo "NOTES:"
echo "  - Log out and back in for Docker group and Zsh shell to take effect"
echo "  - RDP available on port 3389"
echo "  - Configure terminal font to 'FiraCode Nerd Font' for icons"
echo "  - Install 1Password browser extension in Edge manually"
echo ""
echo "TO UPDATE ALL PACKAGES:"
echo "  wget -qO- https://raw.githubusercontent.com/kelomai/kelomai/main/ubuntu-setup/update.sh | bash"
