#!/usr/bin/env bash
#
echo ""
echo "---------------------------generating ssh key for github------------------------------"
ssh-keygen -t rsa -b 4096 -C "burak@burakdede.com"
echo ""

echo ""
echo "---------------------------copy ssh key to clipboard------------------------------"
pbcopy < ~/.ssh/id_rsa.pub
echo ""

echo ""
echo "---------------------------start ssh agent------------------------------"
eval "$(ssh-agent -s)"
echo ""

echo ""
echo "---------------------------use keychain to cache the key & add ssh key------------------------------"
echo "Host *" >> ~/.ssh/config
echo "  AddKeysToAgent yes" >> ~/.ssh/config
echo "  UseKeychain yes" >> ~/.ssh/config
echo "  IdentityFile ~/.ssh/id_rsa" >> ~/.ssh/config
echo "updated the ~/.ssh/config file to cache the key"

echo ""
echo "---------------------------add new key to ssh agent------------------------------"
ssh-add --apple-use-keychain ~/.ssh/id_rsa
echo ""

echo ""
echo "---------------------------open github ui and add the ssh key------------------------------"
echo "opening github settings to add ssh key."
open https://github.com/settings/keys
echo "waiting for 30 seconds to test the new ssh key with github"
sleep 30
echo ""

echo ""
echo "---------------------------test the new ssh key with github------------------------------"
ssh -T git@github.com
echo ""

echo ""
echo "---------------------------use osxkeychain for git---------------------------"
git config --global credential.helper osxkeychain
git config --list
echo ""
