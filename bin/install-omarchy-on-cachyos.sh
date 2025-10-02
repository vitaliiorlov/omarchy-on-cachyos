#!/bin/bash

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo "Error: git is not installed. Please install git before running this script."
    exit 1
fi

# Clone omarhcy from repo
echo "Clone Omarhcy from repo..."
if ! git clone https://www.github.com/basecamp/omarchy ../omarchy; then
    echo "Error: Failed to clone Omarchy repo."
    exit 1
fi

echo "Successfully extracted omarchy archive."

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
echo ""
echo "Please enter your username:"
read -r OMARCHY_USER_NAME
export OMARCHY_USER_NAME

# Prompt user for email address
echo ""
echo "Please enter your email address:"
read -r OMARCHY_USER_EMAIL
export OMARCHY_USER_EMAIL

# Make adjustments to Omarchy install scripts to support CachyOS
echo ""
echo "Making adjustments to Omarchy install scripts to support CachyOS..."

# Navigate to Omarchy install scripts
cd ../omarchy

# Remove tldr installation to prevent conflict with tealdeer install.
sed -i '/tldr/d' install/omarchy-base.packages

# Remove pacman.sh from preflight/all.sh to prevent conflict with cachyos packages
sed -i '/run_logged \$OMARCHY_INSTALL\/preflight\/pacman\.sh/d' install/preflight/all.sh

# Remove nvidia.sh source line from install.sh
sed -i '/source \$OMARCHY_INSTALL\/config\/hardware\/nvidia\.sh/d' install/config/all.sh

# Remove plymouth.sh source line from install.sh
sed -i '/source \$OMARCHY_INSTALL\/login\/plymouth\.sh/d' install/login/all.sh

# Remove limine-snapper.sh source line from install.sh
sed -i '/source \$OMARCHY_INSTALL\/login\/limine-snapper\.sh/d' install/login/all.sh

# Remove alt-bootloaders.sh source line from install.sh
sed -i '/source \$OMARCHY_INSTALL\/login\/alt-bootloaders\.sh/d' install/login/all.sh

# Remove pacman.sh from post-install/all.sh to prevent conflict with cachyos packages
sed -i '/run_logged \$OMARCHY_INSTALL\/preflight\/pacman\.sh/d' install/post-install/all.sh

# Add shell environment check to mise conditional in config/uwsm/env
sed -i 's/if command -v mise &> \/dev\/null; then/if [ "$SHELL" = "\/bin\/bash" ] \&\& command -v mise \&> \/dev\/null; then/' config/uwsm/env

# Add fish shell support to mise activation in config/uwsm/env
sed -i '/eval "\$(mise activate bash)"/a\
elif [ "$SHELL" = "\/bin\/fish" ] && command -v mise &> /dev/null; then\
  mise activate fish | source' config/uwsm/env

# Copy omarchy installation files to ~/.local/share/omarchy
mkdir ~/.local/share/omarchy
cp -r * ~/.local/share/omarchy
cd ~/.local/share/omarchy

# Pause and prompt for acknowledgment to begin installation
echo ""
echo "The following adjustments have been completed."
echo " 1. Removed tldr from packages.sh to avoid conflict with tealdeer on CachyOS."
echo " 2. Disabled Omarchy changes to pacman.conf, preserving CachyOS settings."
echo " 3. Removed nvidia.sh from install.sh to avoid conflict with CachyOS graphics driver installation."
echo " 4. Removed intel.sh from install.sh to avoid conflict with CachyOS graphics driver installation."
echo " 5. Removed plymouth.sh from install.sh to avoid conflict with CachyOS login display manager installation."
echo " 6. Removed limine-snapper.sh from install.sh to avoid conflict with CachyOS boot loader installation."
echo " 7. Removed alt-bootloaders.sh from install.sh to avoid conflict with CachyOS boot loader installation."
echo ""
echo "IMPORTANT: This script prevents Omarchy's install.sh from modifying your boot or login environment." 
echo "If you setup your CachyOS system to match Omarchy's default boot and login configuration, then please"
echo "run the following commands after this installation script is complete:"
echo " 1.) ~/.local/share/omarchy/install/login/plymouth.sh"  
echo " 2.) ~/.local/share/omarchy/install/login/limine-snapper.sh"
echo " 3.) ~/.local/share/omarchy/install/login/alt-bootloaders.sh"
echo ""
echo "NOTE: The above commands assume CachyOS has been setup with"
echo " A.) No login display manager installed."
echo " B.) BTRFS as the file system and Snapper as the snapshot manager."
echo " C.) Limine as the boot loader."
echo " D.) LUKS full disk encryption."
echo "The script will then modify the boot environment and boot screen to Omarchy defaults."
echo ""
echo "Press Enter to begin the installation of Omarchy..."
read -r

# Run the modified install.sh script 
chmod +x install.sh
./install.sh

echo ""
echo "Omarchy has been successfully installed."
echo "As a reminder:"
echo ""
echo "IMPORTANT: This script prevented Omarchy's install.sh from modifying your boot or login environment." 
echo "If you setup your CachyOS system to match Omarchy's default boot and login configuration, then please"
echo "run the following commands after this installation script is complete:"
echo " 1.) ~/.local/share/omarchy/install/login/plymouth.sh"  
echo " 2.) ~/.local/share/omarchy/install/login/limine-snapper.sh"
echo " 3.) ~/.local/share/omarchy/install/login/alt-bootloaders.sh"
echo ""
echo "NOTE: The above commands assume CachyOS has been setup with"
echo " A.) No login display manager installed."
echo " B.) BTRFS as the file system and Snapper as the snapshot manager."
echo " C.) Limine as the boot loader."
echo " D.) LUKS full disk encryption."
echo "The script will then modify the boot environment and boot screen to Omarchy defaults."
echo ""
echo "If you have nothing else to do, please reboot your system before proceeding."
echo ""
echo "Thank you for using the omarchy-on-cachyos automatic installation script."
echo "Press Enter to exit this script."
read -r
