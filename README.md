# MacOS Setup Guide

## Clean MacOS Installation

- [offical guide](https://support.apple.com/en-us/HT204904)
- restart machine with `CMD + R` to start recovery installation
- wipe out disk entirely
	- select `APFS` as file system
	- leave default name
	- done!
- install macOS!


## Prerequisite Apps

### install developer tools along with Xcode
`xcode-select --install`
`sudo xcodebuild -license`

### install homebrew
`/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"`

### install cask (homebrew but for apps)
`brew tap caskroom/cask`

### install git & configure
`brew install git`
git config --global user.email 'me@example.com'
git config --global user.name 'Burak Dede'

### add sshkey for github and others
- [creating new ssh key](https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/)
- [adding ssh key to github](https://help.github.com/articles/adding-a-new-ssh-key-to-your-github-account/)

# MacOS System Settings

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
- Left down corner seems like a habit for me use it

### Spaces
- Enable spaces (press F3 and add as much as space 4 optimum)
- Change default shortcut for switch
	- default is `Ctrl - right/left`
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
- remove tags everywhere!!!
- move home folder to sidebar











