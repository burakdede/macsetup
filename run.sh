#!/usr/bin/env bash
set -euo pipefail

echo "-------------------------------starting the setup process---------------------------------------------------"
echo "This script will install the necessary tools and configurations for your development environment."
./scripts/install.sh
./scripts/git.sh
./scripts/brew-stuff.sh
./scripts/sdk.sh
./scripts/os-defaults.sh

echo ""
echo "-------------------------------creating symlinks for dotfiles and configs-------------------------------------"
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

echo "Symlinking files from dotfiles/ directory..."
for dotfile in "$SCRIPT_DIR"/dotfiles/.[!.]*; do
    filename=$(basename "$dotfile")
    ln -sfn "$dotfile" "$HOME/$filename"
    echo "  Linked $filename"
done

echo "Symlinking configs/.config directory..."
ln -sfn "$SCRIPT_DIR/configs/.config" "$HOME/.config"
echo "  Linked .config directory"
echo "--------------------------------------------------------------------------------------------------------------"

echo ""
echo "-------------------------------if you need to update bash to latest version-----------------------------------"
echo "run	echo "/usr/local/bin/bash" >> /etc/shells"
echo "run 	chsh -s /usr/local/bin/bash"
echo "--------------------------------------------------------------------------------------------------------------"

echo "Note that some of these changes require a logout/restart to take effect."
