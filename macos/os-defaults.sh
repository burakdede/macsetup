#!/usr/bin/env bash
# macOS system defaults — sets sensible defaults via the `defaults` command.
#
# Source: adapted from github.com/mathiasbynens/dotfiles/.macos
#
# ── What this changes ─────────────────────────────────────────────────────────
# General UI:   scrollbars always visible, expanded save/print panels,
#               save to disk (not iCloud), no auto-capitalisation
# Keyboard:     fast repeat rate (KeyRepeat 1, InitialKeyRepeat 10)
# Screen:       password on wake, screenshots to ~/Documents as PNG
# Finder:       show extensions, status bar, path bar, folders first,
#               no .DS_Store on network/USB, list view default
# Dock:         auto-hide, small icons (40px), no recent apps, hot corners
# Activity Monitor, App Store, Photos: sensible defaults
#
# ── Customising ───────────────────────────────────────────────────────────────
# Each `defaults write` call is self-contained and commented.  Edit the value
# inline and re-run this script — changes take effect after the app restart at
# the bottom of the script.
#
# ── Hot corners ───────────────────────────────────────────────────────────────
# Values: 0=no-op, 2=Mission Control, 3=App Windows, 4=Desktop,
#         5=Screensaver, 10=Sleep, 11=Launchpad, 12=Notification Center
# Current: TL=Mission Control, TR=Desktop, BL=Screensaver
#
# Skip:    MACSETUP_SKIP_MACOS_DEFAULTS=1 ./run.sh --only macos

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../utils/utils.sh
source "$SCRIPT_DIR/../utils/utils.sh"

if should_skip_step MACOS_DEFAULTS; then
    log_info "Skipping macOS defaults (MACSETUP_SKIP_MACOS_DEFAULTS is set)."
    exit 0
fi

echo_header "macOS system defaults"

# Close System Preferences to prevent interference.
osascript -e 'tell application "System Settings" to quit' 2>/dev/null || \
    osascript -e 'tell application "System Preferences" to quit' 2>/dev/null || true

ensure_sudo

# Keep sudo alive for the duration of this script.
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
SUDO_KEEPALIVE_PID=$!
trap 'kill $SUDO_KEEPALIVE_PID 2>/dev/null || true' EXIT

###############################################################################
# General UI/UX                                                               #
###############################################################################

sudo nvram SystemAudioVolume=" "                                     # no boot sound
defaults write NSGlobalDomain AppleShowScrollBars -string "Always"
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false  # disk not iCloud
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

###############################################################################
# Keyboard                                                                    #
###############################################################################

defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 10

defaults write NSGlobalDomain AppleLanguages -array "en"
defaults write NSGlobalDomain AppleLocale -string "en_GB@currency=EUR"
defaults write NSGlobalDomain AppleMeasurementUnits -string "Centimeters"
defaults write NSGlobalDomain AppleMetricUnits -bool true

sudo defaults write /Library/Preferences/com.apple.loginwindow showInputMenu -bool true

###############################################################################
# Bluetooth                                                                   #
###############################################################################

defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40

###############################################################################
# Screen                                                                      #
###############################################################################

defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0
defaults write com.apple.screencapture location -string "${HOME}/Documents"
defaults write com.apple.screencapture type -string "png"

###############################################################################
# Finder                                                                      #
###############################################################################

defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
defaults write com.apple.finder _FXSortFoldersFirst -bool true
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"     # search current folder
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
defaults write NSGlobalDomain com.apple.springing.enabled -bool true
defaults write NSGlobalDomain com.apple.springing.delay -float 0
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"     # list view
defaults write com.apple.finder WarnOnEmptyTrash -bool false
defaults write com.apple.NetworkBrowser BrowseAllInterfaces -bool true
sudo chflags nohidden ~/Library
sudo chflags nohidden /Volumes

###############################################################################
# Dock                                                                        #
###############################################################################

defaults write com.apple.dock mru-spaces -bool false
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0
defaults write com.apple.dock tilesize -int 40
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock showhidden -bool true
defaults write com.apple.dock show-recents -bool false

# Hot corners (TL=Mission Control, TR=Desktop, BL=Screensaver)
defaults write com.apple.dock wvous-tl-corner -int 2
defaults write com.apple.dock wvous-tl-modifier -int 0
defaults write com.apple.dock wvous-tr-corner -int 4
defaults write com.apple.dock wvous-tr-modifier -int 0
defaults write com.apple.dock wvous-bl-corner -int 5
defaults write com.apple.dock wvous-bl-modifier -int 0

###############################################################################
# Terminal.app (less relevant if using WezTerm, but harmless)                #
###############################################################################

defaults write com.apple.terminal StringEncodings -array 4
defaults write com.apple.terminal SecureKeyboardEntry -bool true
defaults write com.apple.Terminal ShowLineMarks -int 0

###############################################################################
# Activity Monitor                                                            #
###############################################################################

defaults write com.apple.ActivityMonitor OpenMainWindow -bool true
defaults write com.apple.ActivityMonitor IconType -int 5
defaults write com.apple.ActivityMonitor ShowCategory -int 0
defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
defaults write com.apple.ActivityMonitor SortDirection -int 0

###############################################################################
# App Store                                                                   #
###############################################################################

defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1
defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1
defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1
defaults write com.apple.SoftwareUpdate ConfigDataInstall -int 1
defaults write com.apple.commerce AutoUpdate -bool true
defaults write com.apple.commerce AutoUpdateRestartRequired -bool true

###############################################################################
# Photos                                                                      #
###############################################################################

defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true

###############################################################################
# Restart affected apps                                                       #
###############################################################################

for app in "Activity Monitor" "cfprefsd" "Dock" "Finder" "SystemUIServer"; do
    killall "${app}" 2>/dev/null || true
done

echo_header "macOS defaults complete"
log_success "System defaults applied."
log_warn "Some changes require a logout/restart to fully take effect."
