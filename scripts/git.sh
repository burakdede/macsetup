#!/usr/bin/env bash
set -euo pipefail

echo ""
echo "---------------------------generating ssh key for github------------------------------"
if [ ! -f ~/.ssh/id_rsa ]; then
  ssh-keygen -t rsa -b 4096 -C "burak@burakdede.com"
  echo "SSH key generated."
else
  echo "SSH key already exists at ~/.ssh/id_rsa, skipping generation."
fi
echo ""

echo "---------------------------copy ssh key to clipboard------------------------------"
if [ -f ~/.ssh/id_rsa.pub ]; then
  pbcopy < ~/.ssh/id_rsa.pub
  echo "SSH public key copied to clipboard."
else
  echo "No public key found to copy!" >&2
  exit 1
fi
echo ""

echo "---------------------------start ssh agent------------------------------"
eval "$(ssh-agent -s)"
echo ""

echo "---------------------------use keychain to cache the key & add ssh key------------------------------"
CONFIG_LINE="  IdentityFile ~/.ssh/id_rsa"
if [ ! -f ~/.ssh/config ] || ! grep -q "$CONFIG_LINE" ~/.ssh/config; then
  {
    echo "Host *"
    echo "  AddKeysToAgent yes"
    echo "  UseKeychain yes"
    echo "  IdentityFile ~/.ssh/id_rsa"
  } >> ~/.ssh/config
  echo "Updated the ~/.ssh/config file to cache the key."
else
  echo "~/.ssh/config already configured for keychain."
fi
echo ""

echo "---------------------------add new key to ssh agent------------------------------"
if ! ssh-add --apple-use-keychain ~/.ssh/id_rsa 2>/dev/null; then
  echo "Key may already be added or there was an error adding it."
fi
echo ""

echo "---------------------------open github ui and add the ssh key------------------------------"
echo "Opening GitHub settings to add SSH key."
open https://github.com/settings/keys
echo "Waiting for 30 seconds to test the new ssh key with GitHub."
sleep 30
echo ""

echo "---------------------------test the new ssh key with github------------------------------"
if ! ssh -T git@github.com; then
  echo "SSH test failed. Please check your key setup." >&2
else
  echo "SSH key works with GitHub."
fi
echo ""

echo "---------------------------use osxkeychain for git---------------------------"
git config --global credential.helper osxkeychain
git config --list
echo ""
