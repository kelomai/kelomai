#!/bin/bash
# Ubuntu Development Environment Setup
#
# Run remotely:
#   curl -fsSL https://raw.githubusercontent.com/kelomai/kelomai/main/ubuntu-setup/setup.sh | bash
#
# Installs: Git, MS Edge, GitKraken, Claude Code, PowerShell, Terraform, psql, Go

set -e

echo "=== Ubuntu Development Environment Setup ==="
echo ""

# Update package lists
echo "Updating package lists..."
sudo apt update

# Install prerequisites
echo "Installing prerequisites..."
sudo apt install -y curl wget apt-transport-https ca-certificates gnupg lsb-release software-properties-common

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

# 3. GitKraken
echo ""
echo "=== Installing GitKraken ==="
wget -O /tmp/gitkraken.deb https://release.gitkraken.com/linux/gitkraken-amd64.deb
sudo apt install -y /tmp/gitkraken.deb
rm /tmp/gitkraken.deb
echo "GitKraken installed"

# 4. PowerShell (pwsh)
echo ""
echo "=== Installing PowerShell ==="
source /etc/os-release
wget -q "https://packages.microsoft.com/config/ubuntu/$VERSION_ID/packages-microsoft-prod.deb" -O /tmp/packages-microsoft-prod.deb
sudo dpkg -i /tmp/packages-microsoft-prod.deb
rm /tmp/packages-microsoft-prod.deb
sudo apt update
sudo apt install -y powershell
pwsh --version

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

# 7. Go
echo ""
echo "=== Installing Go ==="
GO_VERSION="1.23.3"
wget -O /tmp/go.tar.gz "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf /tmp/go.tar.gz
rm /tmp/go.tar.gz

# Add Go to PATH if not already present
if ! grep -q '/usr/local/go/bin' ~/.bashrc; then
    echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
fi
export PATH=$PATH:/usr/local/go/bin
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

echo ""
echo "=== Installation Complete ==="
echo ""
echo "Installed software:"
echo "  - Git: $(git --version)"
echo "  - Microsoft Edge: installed"
echo "  - GitKraken: installed"
echo "  - PowerShell: $(pwsh --version)"
echo "  - Terraform: $(terraform --version | head -n1)"
echo "  - PostgreSQL client: $(psql --version)"
echo "  - Go: $(go version)"
echo "  - Node.js: $(node --version)"
echo "  - Claude Code: installed"
echo ""
echo "NOTE: You may need to restart your terminal or run 'source ~/.bashrc' for Go PATH changes to take effect."
