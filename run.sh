#!/usr/bin/env bash
#
./scripts/install.sh
./scripts/git.sh
./scripts/brew-stuff.sh
./scripts/sdk.sh
./scripts/os-defaults.sh

echo ""
echo "-------------------------------copying dotfiles to home directory of user----------------------------------"
cp -R dotfiles/ ~
echo "--------------------------------------------------------------------------------------------------------------"

echo ""
echo "-------------------------------if you need to update bash to latest version-----------------------------------"
echo "run	echo "/usr/local/bin/bash" >> /etc/shells"
echo "run 	chsh -s /usr/local/bin/bash"
echo "--------------------------------------------------------------------------------------------------------------"

echo "Note that some of these changes require a logout/restart to take effect."
