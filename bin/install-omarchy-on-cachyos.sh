#!/bin/bash

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo "Error: git is not installed. Please install git before running this script."
    exit 1
fi

# Clone omarchy repository
echo "Cloning omarchy repository..."
if ! git clone https://github.com/basecamp/omarchy.git; then
    echo "Error: Failed to clone omarchy repository."
    exit 1
fi

echo "Successfully cloned omarchy repository."

# Check if yay is installed
if ! command -v yay &> /dev/null; then
    echo "yay is not installed. Installing yay..."

    # Install dependencies for building yay
    sudo pacman -S --needed --noconfirm git base-devel

    # Clone and build yay
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay
    makepkg -si --noconfirm
    cd -

    # Clean up
    rm -rf /tmp/yay

    if ! command -v yay &> /dev/null; then
        echo "Error: Failed to install yay."
        exit 1
    fi

    echo "yay has been successfully installed."
else
    echo "yay is already installed."
fi

# Make adjustments to Omarchy install scripts to support CachyOS
echo "Making adjustments to Omarchy install scripts to support CachyOS..."

# Navigate to Omarchy install scripts
cd omarchy/install

# Remove tldr installation to prevent conflict with tealdeer install.
sed -i '/^  tldr \\$/d' packages.sh

