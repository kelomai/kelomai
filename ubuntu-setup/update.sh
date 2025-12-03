#!/bin/bash
# Ubuntu Development Environment Update Script
#
# Run remotely:
#   wget -qO- https://raw.githubusercontent.com/kelomai/kelomai/main/ubuntu-setup/update.sh | bash
#
# Updates all packages installed by setup.sh

set -e

echo "=== Ubuntu Development Environment Update ==="
echo ""
echo "Started at: $(date)"
echo ""

# 1. APT packages
echo "=== Updating APT packages ==="
sudo apt update
sudo apt upgrade -y
sudo apt autoremove -y
sudo apt autoclean
echo "APT packages updated"

# 2. Snap packages
echo ""
echo "=== Updating Snap packages ==="
sudo snap refresh
echo "Snap packages updated"

# 3. NPM global packages (Claude Code, etc.)
echo ""
echo "=== Updating NPM global packages ==="
if command -v npm &> /dev/null; then
    sudo npm update -g
    echo "NPM packages updated"
else
    echo "NPM not found, skipping"
fi

# 4. Azure PowerShell module
echo ""
echo "=== Updating Azure PowerShell module ==="
if command -v pwsh &> /dev/null; then
    pwsh -Command "Update-Module Az -Force -ErrorAction SilentlyContinue" 2>/dev/null || echo "Az module update skipped (may not be installed)"
    echo "Azure PowerShell module updated"
else
    echo "PowerShell not found, skipping"
fi

# 5. Helm plugins (if any)
echo ""
echo "=== Updating Helm ==="
if command -v helm &> /dev/null; then
    # Update helm via the official script
    curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    echo "Helm updated"
else
    echo "Helm not found, skipping"
fi

# 6. k9s
echo ""
echo "=== Updating k9s ==="
if command -v k9s &> /dev/null || [ -f "$HOME/.local/bin/k9s" ]; then
    curl -sS https://webinstall.dev/k9s | bash
    echo "k9s updated"
else
    echo "k9s not found, skipping"
fi

echo ""
echo "=== Update Complete ==="
echo "Finished at: $(date)"
echo ""

# Show current versions
echo "Current versions:"
echo "  - Git: $(git --version 2>/dev/null || echo 'not installed')"
echo "  - Docker: $(docker --version 2>/dev/null || echo 'not installed')"
echo "  - Go: $(go version 2>/dev/null || echo 'not installed')"
echo "  - Node.js: $(node --version 2>/dev/null || echo 'not installed')"
echo "  - Python: $(python3 --version 2>/dev/null || echo 'not installed')"
echo "  - Terraform: $(terraform --version 2>/dev/null | head -n1 || echo 'not installed')"
echo "  - kubectl: $(kubectl version --client --short 2>/dev/null || kubectl version --client 2>/dev/null | head -n1 || echo 'not installed')"
echo "  - Helm: $(helm version --short 2>/dev/null || echo 'not installed')"
echo "  - Azure CLI: $(az --version 2>/dev/null | head -n1 || echo 'not installed')"
echo "  - PowerShell: $(pwsh --version 2>/dev/null || echo 'not installed')"
echo ""
echo "NOTE: You may need to restart your terminal for some updates to take effect."
