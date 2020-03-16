#!/usr/bin/env bash
#
echo ""
echo "---------------------------mac app store login------------------------------"
# login for mac app store to install apps from there eg. Xcode
mas signin --dialog burak@burakdede.com
echo ""

echo ""
echo "---------------------------install mac apps------------------------------"
# agree on xcode license
sudo xcodebuild -license accept

# install mac store apps
mas install 497799835 # Xcode
mas install 937984704 # Amphetamine
echo ""
