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

#### install developer tools along with Xcode
- `xcode-select --install` this includes stuff like gcc and developer toolchain needed by most program/apps
- install Xcode but it is optional (takes ages on slow connection)
- `sudo xcodebuild -license` even though you don't need xcode you need to agree!

#### install homebrew
```sh
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"`
brew tap homebrew/versions
brew tap homebrew/bundle
brew tap homebrew/core
brew tap caskroom/cask
brew tap caskroom/fonts
```


#### install cask (like brew but for apps)
- `brew tap caskroom/cask`

#### install git & configure
- `brew install git`
- `git config --global user.email 'me@example.com'`
- `git config --global user.name 'Burak Dede'`
- symlink `.gitconfig` and `.gitignore_global`

#### add sshkey for github and others
- [creating new ssh key](https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/)
- [adding ssh key to github](https://help.github.com/articles/adding-a-new-ssh-key-to-your-github-account/)

## MacOS System Settings

#### Dock
- auto hide to bottom
- make size smaller
- add `Applications` folder to shortcuts
- add `Home` folder to shortcuts

#### Keyboard & Mouse
- `System Settings -> Keyboard -> Key Repeat & Delay` All the way to the right
- Show emoji bar in menu bar (I am terrible at those)
- `System Settings -> Trackpad` Enable almost all touch features (eg. tap to click)

#### Screen Saver & Sleep
- `Desktop & Screen Saver -> Hot corners` Enable hot corners for quick lock
- Left down corner seems like a habit for me, use it

#### Spaces
- Enable spaces (press F3 and add as much as space 4 optimum)
- Change default shortcut for switch
	- default is `Ctrl - Right/Left Arrow`
	- `System Settings -> Keyboard -> Shortcut -> Mission Control -> Switch to Desktop` 
	- make it `Ctrl - 1/2/3/4`

#### Security
- Turn off guest account
- Turn on firewall

#### Finder
- `Finder -> Pref -> New Finder Show Home`
- `Finder -> Pref -> Sidebard do not show Recents, Music, Recent Tags`
- `Finder -> Pref -> Advanced`
	- show all filename extensions
	- keep folders on top when sorting by name
- remove tags everywhere they are annoying
- move `Home` folder and `Dropbox` to sidebar


## Programming Language SDK & Setups

#### Java & JDK

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

#### Python

```sh
brew install python
pip3 install virtualenv
pip3 install virtualenvwrapper
```

> TODO: update with pip packages

#### Ruby

```
brew install ruby
brew install rbenv
```

#### Javascript & Node
```sh
brew install node
```

> TODO: update this section soon

## Brew Packages

```sh
brew intall bash (conf - https://apple.stackexchange.com/questions/193411/update-bash-to-version-4-0-on-osx)
brew install wget --with-iri

brew install mas (conf - https://github.com/mas-cli/mas)
mas signin me@example.com


brew install coreutils
brew install packer

brew install mysql
mysql_secure_installation
brew services start mysql # autostart mysql deamon

brew install imagemagick
brew install cmake

brew install postgresql
brew services start postgresql # autostart postresql deamon

brew install mongodb
brew services start mongodb # autostart mongodb deamon

brew install automake
brew install youtube-dl

brew install awscli
aws configure # configure access and secret key

brew install httpie
brew install gradle

brew install redis
brew services start redis # autostart redis deamon

brew install ffmpeg
brew install maven
brew install watchman
brew install ant
brew install asciinema
brew install heroku
brew install tmux
brew install gcc
brew install htop
brew install jq
brew install irssi
brew install nmap

brew install curl --with-openssl
brew link --force curl

brew install protobuf
brew install unrar
brew install gdb
brew install geoip
brew install tree
brew insatll sqlite
brew install watch
brew install ack
brew install readline
brew install hub
brew install the_silver_searcher
```
 

## Apps to Install

```sh
brew cask install google-chrome (conf)
brew cask install firefox
brew cask install docker
brew cask install iterm2 (conf)
brew cask install evernote
brew cask install skype
brew cask install spectacle (conf)
brew cask install lastpass

brew cask install android-studio
brew cask install android-sdk
brew cask install android-platform-tools
echo 'export ANDROID_SDK_ROOT="/usr/local/share/android-sdk"' >> ~/.bash_profile

brew cask install intellij-idea (conf)
brew cask install intellij-idea-ce
brew cask install xcode
brew cask install the-unarchiver
brew cask install slack
brew cask install sublime-text
brew cask install handbrake
brew cask install appcleaner
brew cask install Macvim
brew cask install Alfred (conf)

brew cask install Vagrant
brew cask install vagrant-manager

brew cask install Postman
brew cask install spotify
brew cask install Flux
brew cask install VLC
brew cask install Cloudapp (conf)
brew cask install Dropbox
brew cask install Clipy (conf)
brew cask install Virtualbox # open system settings -> security -> allow kernel extension
brew cask install sourcetree
brew cask install google-backup-and-sync
```

> `brew cleanup` `brew cask cleanup` to cleanup the mess

## IntelliJ Settings & Plugins

Go to `Preferences -> Plugins`
- Protobuf
- Key Promoter X
- Lombok




