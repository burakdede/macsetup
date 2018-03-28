# MacOS Setup Guide

Guide for setting up my machine.


## Clean MacOS Installation

Use this section if I am installing the OS from scratch and don't need anything from the disk. 
Most of my stuff backed up and stored in remote anyway so this option should be the one 

- RTFM [offical guide](https://support.apple.com/en-us/HT204904)
- this needs active internet connection!
- restart machine with `CMD + R` to start recovery installation
- wipe out disk entirely
	- select `APFS` as file system
	- leave name and others as default
- install macOS from scratch


## Prerequisite Apps

These are the tools and apps needed for later stages of the installation.

### install developer tools along with Xcode
- `xcode-select --install` this includes stuff like gcc and developer toolchain needed by most program/apps
- install Xcode but it is optional (takes ages on slow connection)
- `sudo xcodebuild -license` even though you don't need xcode you need to agree!

### install homebrew
- `/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"`

### install cask (like brew but for apps)
- `brew tap caskroom/cask`

### install git & configure
- `brew install git`
- `git config --global user.email 'me@example.com'`
- `git config --global user.name 'Burak Dede'`
- symlink `.gitconfig` and `.gitignore_global`

### add sshkey for github and others
- [creating new ssh key](https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/)
- [adding ssh key to github](https://help.github.com/articles/adding-a-new-ssh-key-to-your-github-account/)

## MacOS System Settings

### Dock
- auto hide to bottom
- make size smaller
- add `Applications` folder to shortcuts
- add `Home` folder to shortcuts

### Keyboard & Mouse
- `System Settings -> Keyboard -> Key Repeat & Delay` All the way to the right
- Show emoji bar in menu bar (I am terrible at those)
- `System Settings -> Trackpad` Enable almost all touch features (eg. tap to click)

### Screen Saver & Sleep
- `Desktop & Screen Saver -> Hot corners` Enable hot corners for quick lock
- Left down corner seems like a habit for me, use it

### Spaces
- Enable spaces (press F3 and add as much as space 4 optimum)
- Change default shortcut for switch
	- default is `Ctrl - Right/Left Arrow`
	- `System Settings -> Keyboard -> Shortcut -> Mission Control -> Switch to Desktop` 
	- make it `Ctrl - 1/2/3/4`

### Security
- Turn off guest account
- Turn on firewall

### Finder
- `Finder -> Pref -> New Finder Show Home`
- `Finder -> Pref -> Sidebard do not show Recents, Music, Recent Tags`
- `Finder -> Pref -> Advanced`
	- show all filename extensions
	- keep folders on top when sorting by name
- remove tags everywhere they are annoying
- move `Home` folder and `Dropbox` to sidebar


## Programming Language SDK & Setups

### Java & JDK

Current default version is `9` so beware of that!

```sh
brew tap caskroom/versions
brew cask install java8
```

Set the JAVA_HOME env. variable and check installed JDKs

```sh
/usr/libexec/java_home -V
echo 'export JAVA_HOME=$(/usr/libexec/java_home -v 1.8)' >> ~/.bash_profile
source ~/.bash_profile
java -version
echo $JAVA_HOME
```












