#!/usr/bin/env bash
set -euo pipefail

echo ""
echo "-------------------------------install sdks and language runtimes-----------------------------------"
if [ ! -d "$HOME/.sdkman" ]; then
  curl -s "https://get.sdkman.io" | bash
else
  echo "SDKMAN already installed, skipping installation."
fi

if [ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]; then
  source "$HOME/.sdkman/bin/sdkman-init.sh"
else
  echo "SDKMAN init script not found, aborting." >&2
  exit 1
fi
echo ""

echo "-------------------------------update sdkman and packages-----------------------------------"
sdk selfupdate || echo "SDKMAN selfupdate failed."
sdk update || echo "SDKMAN update failed."
echo ""

echo "-------------------------------install language, runtimes and frameworks-----------------------------------"
for candidate in java groovy scala kotlin springboot grails visualvm sbt spark; do
  if ! sdk list "$candidate" | grep -q '\*'; then
    sdk install "$candidate" || echo "Failed to install $candidate."
  else
    echo "$candidate already installed, skipping."
  fi
done
echo ""