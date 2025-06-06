#!/usr/bin/env bash
#
echo ""
echo "---------------------------installing developer tools and xcode------------------------------"
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>> xcode-select --install"
xcode-select --install
sudo xcodebuild -license
echo ""

echo ""
echo "---------------------------checking latest updates for operationg system------------------------------"
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>> sudo softwareupdate -i -a"
sudo softwareupdate -i -a
echo ""

echo ""
echo "--------------------------installing homebrew latest version-------------------------------"
echo ">>>>>>>>>>>>>>>>>>>>>>>>>> /bin/bash -c install.sh"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo ""