#!/usr/bin/env bash
set -euo pipefail

echo ""
echo "--------------------------linking new vim version installed with brew-------------------------------"
if brew list vim &>/dev/null; then
  brew unlink vim || echo "vim was not linked."
  brew link vim || echo "Failed to link vim."
else
  echo "vim is not installed via brew, skipping link."
fi
echo ""

echo "--------------------------updating brew and doing cleanup-------------------------------"
if ! brew doctor; then
  echo "brew doctor found issues. Please review the output above." >&2
fi

brew update
brew cleanup -s

if [ -f "$(dirname "$0")/../Brewfile" ]; then
  brew bundle --file="$(dirname "$0")/../Brewfile"
else
  echo "Brewfile not found, skipping brew bundle." >&2
fi
echo ""