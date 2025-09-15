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

# Prompt user for username
echo "Please enter your username:"
read -r OMARCHY_USER_NAME
export OMARCHY_USER_NAME

# Prompt user for email address
echo "Please enter your email address:"
read -r OMARCHY_USER_EMAIL
export OMARCHY_USER_EMAIL

# Make adjustments to Omarchy install scripts to support CachyOS
echo "Making adjustments to Omarchy install scripts to support CachyOS..."

# Navigate to Omarchy install scripts
cd omarchy

# Remove tldr installation to prevent conflict with tealdeer install.
sed -i '/^  tldr \\$/d' install/packages.sh

# Remove guard.sh source line from install.sh
sed -i '/source \$OMARCHY_INSTALL\/preflight\/guard\.sh/d' install.sh

# Remove nvidia.sh source line from install.sh
sed -i '/source \$OMARCHY_INSTALL\/config\/hardware\/nvidia\.sh/d' install.sh

# Remove intel.sh source line from install.sh
sed -i '/source \$OMARCHY_INSTALL\/config\/hardware\/intel\.sh/d' install.sh

# Remove plymouth.sh source line from install.sh
sed -i '/source \$OMARCHY_INSTALL\/login\/plymouth\.sh/d' install.sh

# Remove limine-snapper.sh source line from install.sh
sed -i '/source \$OMARCHY_INSTALL\/login\/limine-snapper\.sh/d' install.sh

# Remove alt-bootloaders.sh source line from install.sh
sed -i '/source \$OMARCHY_INSTALL\/login\/alt-bootloaders\.sh/d' install.sh

# Remove reboot.sh source line from install.sh
sed -i '/source \$OMARCHY_INSTALL\/reboot\.sh/d' install.sh

# Add shell environment check to mise conditional in config/uwsm/env
sed -i 's/if command -v mise &> \/dev\/null; then/if [ "$SHELL" = "\/bin\/bash" ] \&\& command -v mise \&> \/dev\/null; then/' config/uwsm/env

# Add fish shell support to mise activation in config/uwsm/env
sed -i '/eval "\$(mise activate bash)"/a\
elif [ "$SHELL" = "/usr/bin/fish" ] && command -v mise &> /dev/null; then\
  mise activate fish | source' config/uwsm/env

# Pause and prompt for acknowledgment to begin installation
echo ""
echo "The following adjustments have been completed."
echo " 1. Removed tldr from packages.sh to avoid conflict with tealdeer on CachyOS."
echo " 2. Removed nvidia.sh from install.sh to avoid conflict with CachyOS graphics driver installation."
echo " 3. Removed intel.sh from install.sh to avoid conflict with CachyOS graphics driver installation."
echo " 4. Removed plymouth.sh from install.sh to avoid conflict with CachyOS login display manager installation."
echo " 5. Removed limine-snapper.sh from install.sh to avoid conflict with CachyOS boot loader installation."
echo " 6. Removed alt-bootloaders.sh from install.sh to avoid conflict with CachyOS boot loader installation."
echo ""
echo "IMPORTANT: This script prevents Omarchy's install.sh from modifying your boot or login environment." 
ehco "If you setup your CachyOS system to match Omarchy's default boot and login configuration, then"
echo "please manually run the following commands from this directory after this installation script is complete:"
echo " 1.) omarchy/install/login/plymouth.sh"  
echo " 2.) omarchy/install/login/limine-snapper.sh"
echo " 3.) omarchy/install/login/alt-bootloaders.sh"
echo ""
echo "NOTE: The above commands assume CachyOS has been setup with"
echo " A.) No login display manager installed."
echo " B.) BTRFS as the file system and Snapper as the snapshot manager."
echo " E.) Limine as the boot loader."
echo " F.) LUKS full disk encryption."
echo "The script will then modify the boot environment and boot screen to Omarchy defaults."
echo ""
echo "Press Enter to begin instalation of Omarchy..."
read -r

# Run the modified install.sh script
./install.sh

echo ""
echo "Omarchy has been successfully installed. Note that automatic reboot has been turned off."
echo "As a reminder:"
echo ""
echo "IMPORTANT: This script prevented Omarchy's install.sh from modifying your boot or login environment." 
echo "If you setup your CachyOS system to match Omarchy's default boot and login configuration, then"
echo "please manually run the following commands from this directory after this installation script is complete:"
echo " 1.) omarchy/install/login/plymouth.sh"  
echo " 2.) omarchy/install/login/limine-snapper.sh"
echo " 3.) omarchy/install/login/alt-bootloaders.sh"
echo ""
echo "NOTE: The above commands assume CachyOS has been setup with"
echo " A.) No login display manager installed."
echo " B.) BTRFS as the file system and Snapper as the snapshot manager."
echo " E.) Limine as the boot loader."
echo " F.) LUKS full disk encryption."
echo "The script will then modify the boot environment and boot screen to Omarchy defaults."
echo ""
echo "If you have nothing else to do, please reboot your system before proceeding."
echo ""
echo "Thank you for using the omarchy-on-cachyos automatic installation script."
echo "Press Enter to exit this script."
read -r