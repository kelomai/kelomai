#!/bin/bash

# Exit on error
set -e

# Install Homebrew if not installed
if ! command -v brew &>/dev/null; then
	echo "Installing Homebrew..."
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	# Add Homebrew to PATH for Apple Silicon and Intel
	if [[ $(uname -m) == 'arm64' ]]; then
		echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
		eval "$(/opt/homebrew/bin/brew shellenv)"
	else
		echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
		eval "$(/usr/local/bin/brew shellenv)"
	fi
else
	echo "Homebrew already installed."
fi

# Update Homebrew
brew update

# List of Homebrew cask packages to install
apps=(
	1password-cli
	adobe-acrobat-pro
	beyond-compare
	firefox
	github
	gitkraken
	google-chrome
	microsoft-edge
	powershell
	visual-studio-code
	font-fira-code-nerd-font
	font-meslo-lg-nerd-font
)

# List of Homebrew formulae to install
tools=(
	terraform
	terraform-docs
	packer
	kubelogin
	kubectl
	sqlcmd
	msodbcsql18
	mssql-tools18
	unbound
	tcping
	dotnet
	dotnet-sdk
	python@3.13
	node
	openjdk@21
	azcopy
	azd
	azure-cli
	curl
	git
	gh
	wget
	jq
	htop
	ncurses
	tree
	watch
	xz
	zstd
	oh-my-zsh
	oh-my-posh
)

echo "Installing applications..."
for app in "${apps[@]}"; do
	brew install --cask "$app" || echo "Failed to install $app"
done

echo "Installing tools..."
for tool in "${tools[@]}"; do
	brew install "$tool" || echo "Failed to install $tool"
done

echo "All done!"