# MacOS Machine Setup Guide

> TL;DR just run `run.sh` and it will take care of the rest. I explained what each script does in the following sections if there is a need to run them individually.

## 1. Install OS
- Here is the offical apple guide on how to do [it](https://support.apple.com/en-us/HT204904)
- in short
	- Restart machine and press `Cmd+R` to go into recovery mode
	- Wipe out disk entirely using Disk Utility
	- Reinstall OS using the option

## 2. Install Updates & Brew Package Manager
- Run `install.sh`
	- First it will install developer tools (includes stuff like gcc, gdb...)
	- Tries to install pending updates if there are any
	- Last step is to install `brew` package manager

## 3. Git & Github
- Run `git.sh`
	- It will generate new ssh key for github and put into your clipboard
	- Launches ssh agent and will ask it to cache the new key
	- Opens github settings to enter the new ssh key for the new machine
	- Test new ssh key against github
- Official docs of github on how to add new ssh key
	- [adding new ssh key](https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/)
	- [adding new ssh key to github](https://help.github.com/articles/adding-a-new-ssh-key-to-your-github-account/)
	- [caching github password](https://help.github.com/en/github/using-git/caching-your-github-password-in-git)
	- [create personal access token](https://help.github.com/en/github/authenticating-to-github/creating-a-personal-access-token-for-the-command-line)

## 4. Command Line and Native Applications
- Run `brew-stuff.sh` this will update and install all software required
- It uses the `Brewfile` in the project root directory

## 5. Mac App Store Applications
- Run `macappstore.sh` to install mac app store apps
	- Xcode, Amphetamine...

## 6. Installing SDKs & Frameworks
- Run `sdk.sh` to install latest versions of jvm languages and some of the web frameworks...

## 7. Change the MacOS Defaults
- Run `os-defaults.sh` to set defaults to sensible alternatives
	- eg. change hot corner settings, change how finder behaves, remove dock and animations...
    - [enable spaces](https://support.apple.com/guide/mac-help/work-in-multiple-spaces-mh14112/mac) with keyboard shortcut
