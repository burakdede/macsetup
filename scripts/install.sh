#!/usr/bin/env bash
set -euo pipefail

echo ""
echo "--------------------------- Installing developer tools and Xcode ------------------------------"
if ! xcode-select -p &>/dev/null; then
  echo ">>>>>>>>>>>>>>>>>>>>>>>>>>> xcode-select --install"
  xcode-select --install || true  # May prompt if already installed
  # Wait for user to finish install if needed
  until xcode-select -p &>/dev/null; do
    sleep 5
  done
else
  echo "Xcode Command Line Tools already installed."
fi

if ! sudo xcodebuild -checkFirstLaunchStatus &>/dev/null; then
  echo ">>>>>>>>>>>>>>>>>>>>>>>>>>> Accepting Xcode license"
  sudo xcodebuild -license accept
else
  echo "Xcode license already accepted."
fi
echo ""

echo "--------------------------- Checking latest updates for operating system ------------------------------"
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>> sudo softwareupdate -i -a"
sudo softwareupdate -i -a || true
echo ""

echo "-------------------------- Installing Homebrew latest version -------------------------------"
if ! command -v brew &>/dev/null; then
  echo ">>>>>>>>>>>>>>>>>>>>>>>>>> Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo "Homebrew already installed. Updating..."
  brew update
fi
echo ""