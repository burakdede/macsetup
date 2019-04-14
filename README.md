# MacOS Setup Guide

Guide for setting up my machine.


## Clean MacOS Installation

If I am comfortable with wiping the whole disk, go with this option.

- [offical guide to installing MacOS from scratch](https://support.apple.com/en-us/HT204904)
- restart machine with `CMD + R` to start recovery installation
- wipe out disk entirely
	- select `APFS` as file system
	- leave name and others as default
- continue following menus


## Prerequisite Apps

#### install developer tools along with Xcode
- `xcode-select --install` this includes stuff like `gcc` and `developer toolchain` needed by most program/apps
- install `Xcode` (option and takes ages)
- `sudo xcodebuild -license` (even though you don't need xcode you need to agree!)

#### install homebrew
```sh
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew tap homebrew/versions
brew tap homebrew/bundle
brew tap homebrew/core
brew tap caskroom/cask
brew tap caskroom/fonts
```

must know brew commands (all start with brew, duh..)
* `brew install formulae-name` (install package-name)
* `brew list` (list all the package installed)
* `brew search formulae-name` (search brew repo for formulae)
* `brew update` (fetch new version of brew and updates all formulaes)
* `brew upgrade formulae-name` (update formulae to latest version)
* `brew uninstall formulae-name` (remove formulae from the system)
* `brew cleanup` (remove any old packages that is not used anymore - huge disk space saver)
* `brew doctor` (will check if any error related to brew occur in system)

> thats too many commands to know, add alias for it maybe?
`alias brewup='brew update; brew upgrade; brew cleanup; brew doctor'`

#### install cask for gui apps
- `brew tap caskroom/cask`

#### install git
- `brew install git`
- `git config --global user.email 'me@example.com'`
- `git config --global user.name 'Burak Dede'`
- symlink `.gitconfig` and `.gitignore_global`

#### add sshkey for github
- [creating new ssh key](https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/)
- [adding ssh key to github](https://help.github.com/articles/adding-a-new-ssh-key-to-your-github-account/)

## MacOS System Settings

#### Dock
- auto hide to bottom
- make size smaller
- add `Applications` folder to shortcuts
- add `Home` folder to shortcuts

#### Keyboard & Mouse
- `System Settings -> Keyboard -> Key Repeat & Delay` All the way to the right = no delay
- `System Settings -> Trackpad` enable almost all of them somehow they are useful

#### Screen Saver & Sleep
- `Desktop & Screen Saver -> Hot corners` Enable hotcorners
- I use `Left-Down` corner for this.

#### Spaces
- Enable spaces
- Disable `Automatic rearranging of Space`
- Change default shortcut for switch
	- default is `Ctrl - Right/Left Arrow`
	- `System Settings -> Keyboard -> Shortcut -> Mission Control -> Switch to Desktop`
	- new shortcut for it `Ctrl - 1/2/3/4....`

#### Security
- Turn off guest account
- Turn on firewall

#### Finder
- `Finder -> Pref -> New Finder Show Home` (start from home folder)
- `Finder -> Pref -> Sidebar do not show Recents, Music, Recent Tags` (useless, I rarely use those folders)
- `Finder -> Pref -> Advanced`
	- show all filename extensions
	- keep folders on top when sorting by name
- remove tags (I never used this feature)
- move `Home` folder and `Dropbox` to sidebar
- Add `New Folder`, 'Delete', 'Path' to toolbar 

#### Spotlight
- turn off file/folder indexing (I use Alfred for this)
```sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.metadata.mds.plist```
- uncheck everything related to indexing


## Programming Language SDK & Setups

#### SDKMan

```sh
curl -s "https://get.sdkman.io" | bash
```

in new terminal after installation

```sh
source "$HOME/.sdkman/bin/sdkman-init.sh"
sdk version
```


```sh
sdk install java
sdk install scala
sdk install kotlin
sdk install visualvm
sdk install maven
sdk install springboot
sdk install sbt
sdk install gradle
```

> [more usage commands](https://sdkman.io/usage)
* `sdk uninstall package`
* `sdk install package 2.3.4`
* `sdk list`
* `sdk list java/scala`
* `sdk current java`
* `sdk defualt scala 2.11.6`
* `sdk selfupdate`
* `sdk update`


#### Java & JDK

Current default version is `9`

```sh
brew tap caskroom/versions
brew cask install java8
```

Set the `JAVA_HOME` env. variable and check installed JDKs

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

#### Ruby

```
brew install ruby
brew install rbenv
```

#### Javascript & Node
```sh
brew install node
```

## Brew Packages

```sh
brew intall bash  #(conf - https://apple.stackexchange.com/questions/193411/update-bash-to-version-4-0-on-osx)
brew install wget --with-iri
brew install mas #(conf - https://github.com/mas-cli/mas)
mas signin me@example.com
brew install coreutils
brew install packer
brew install terraform
brew install vault
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
brew cask install macdown
brew cask install vagrant
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
brew cask install datagrip
```

> `brew cleanup` to cleanup the mess


## IntelliJ Settings & Plugins

Go to `Preferences -> Plugins`
- Protobuf
- Key Promoter X
- Lombok
- Markdown Support
- Docker Integration


## Sublime Text & Plugins

- remove current sublime `User` directory
- symlink one in the dotfiles to fresh install
- Install Package Control - https://packagecontrol.io/installation
- restart

> Check sublime directory in `dotfiles` and try to symlink it to `/Library/Application Support/Sublime Text 3/Packages/User`

Plugins that will be installed by default
- A File Icon
- AdvancedNewFile
- All Autocomplete
- BracketHighlighter
- Color Highlighter
- ColorPicker
- CSS3
- DocBlockr
- Emmet
- Git
- GitGutter
- HTML-CSS-JS Prettify
- HTML5
- jQuery
- Markdown Preview
- Package Control
- Sass
- SideBarEnhancements
- SublimeCodeIntel
- SublimeLinter
- Theme - Spacegray

> For synchronizing use [sublime settings doc](https://packagecontrol.io/docs/syncing)
