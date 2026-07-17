#!/bin/bash
set -euo pipefail

echo "=== Setting up repositories ==="
# RPM Fusion
if ! rpm -q rpmfusion-free-release >/dev/null 2>&1 || ! rpm -q rpmfusion-nonfree-release >/dev/null 2>&1; then
    echo "Installing RPM Fusion..."
    sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
fi

# DNF setup and plugins-core (needed for config-manager)
sudo dnf -y install dnf-plugins-core

# Enable Fedora Workstation repositories & Google Chrome
#sudo dnf install -y fedora-workstation-repositories
#sudo dnf config-manager setopt google-chrome.enabled=1

# Visual Studio Code repository
if [ ! -f /etc/yum.repos.d/vscode.repo ]; then
    echo "Adding VS Code repository..."
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    cat <<EOF | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
autorefresh=1
type=rpm-md
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF
fi


# jdxcode/mise
if ! dnf copr list | grep -q "jdxcode/mise"; then
    echo "Enabling jdxcode/mise COPR..."
    sudo dnf copr enable -y jdxcode/mise
fi

# atim/starship
if ! dnf copr list | grep -q "atim/starship"; then
    echo "Enabling atim/starship COPR..."
    sudo dnf copr enable -y atim/starship
fi

# 1Password repository
#if [ ! -f /etc/yum.repos.d/1password.repo ]; then
#    echo "Adding 1Password repository..."
#    sudo rpm --import https://downloads.1password.com/linux/keys/1password.asc
#    sudo sh -c 'echo -e "[1password]\nname=1Password\nbaseurl=https://downloads.1password.com/linux/rpm/stable/\$basearch\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=\"https://downloads.1password.com/linux/keys/1password.asc\"" > /etc/yum.repos.d/1password.repo'
#fi

echo "=== Repositories setup complete ==="
