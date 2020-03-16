#!/usr/bin/env bash
#
echo ""
echo "-------------------------------signin to mac app store and install app store apps-----------------------------------"
mas signin --dialog burak@burakdede.com
sudo xcodebuild -license accept # agree on xcode license
mas install 497799835 # Xcode
mas install 937984704 # Amphetamine
echo ""

echo ""
echo "--------------------------linking new vim version installed with brew-------------------------------"
brew unlink vim && brew link vim
echo ""

echo ""
echo "--------------------------updating brew and doing cleanup-------------------------------"
brew doctor && brew update && brew cleanup -s 
brew bundle