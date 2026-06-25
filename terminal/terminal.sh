#!/usr/bin/env bash
# WezTerm terminal emulator installation for macOS.
#
# Installs WezTerm via Homebrew Cask.  On macOS there is no concept of a
# "default terminal" the way GNOME has — WezTerm is just launched like any
# other .app from the Applications folder or Spotlight.
#
# ── WezTerm configuration ─────────────────────────────────────────────────────
# Config lives in the shared dotfiles/ submodule:
#   dotfiles/.config/wezterm/wezterm.lua
#
# The config is already cross-platform — it detects macOS vs Linux at runtime:
#   local is_mac = wezterm.target_triple:find("darwin") ~= nil
# macOS uses SUPER (Cmd) as the modifier; Linux uses SHIFT|CTRL.
#
# ── Customisation ─────────────────────────────────────────────────────────────
# Machine-local overrides can be placed in the wezterm.lua file directly.
# WezTerm uses a single Lua config file (no include mechanism), so add an
# OS check at the top of the file if a change should only apply on macOS:
#   if wezterm.target_triple:find("darwin") then ... end
#
# ── Upgrading WezTerm ─────────────────────────────────────────────────────────
#   brew upgrade --cask wezterm
#
# Skip:    MACSETUP_SKIP_WEZTERM=1 ./run.sh --only terminal
# Upgrade: MACSETUP_UPGRADE=1      ./run.sh --only terminal

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../utils/utils.sh
source "$SCRIPT_DIR/../utils/utils.sh"

trap 'handle_error $? $LINENO' ERR

installed_wezterm_version() {
    if command_exists wezterm; then
        wezterm --version 2>/dev/null | awk '{print $2}'
    fi
}

install_wezterm() {
    echo_header "WezTerm terminal emulator"

    local got
    got="$(installed_wezterm_version)"

    if [[ -n "$got" ]] && ! upgrade_enabled; then
        log_info "WezTerm $got already installed. (MACSETUP_UPGRADE=1 to reinstall)"
        return 0
    fi

    log_info "Installing WezTerm via Homebrew Cask..."
    brew install --cask wezterm
    log_success "WezTerm installed."
}

main() {
    check_root
    export PATH="$HOME/.local/bin:$PATH"

    if should_skip_step WEZTERM; then
        log_info "Skipping WezTerm (MACSETUP_SKIP_WEZTERM is set)."
        return 0
    fi

    install_wezterm

    echo_header "Terminal setup complete"
    log_success "WezTerm is ready."
    log_info "Config: ~/.config/wezterm/wezterm.lua  (symlinked from dotfiles/)"
    log_info "Launch WezTerm from Applications or Spotlight."
}

main
