#!/usr/bin/env bash
# macOS system bootstrap: Homebrew, Brew packages, mise, Nerd Fonts.
#
# ── Customisation ─────────────────────────────────────────────────────────────
# Packages:  edit Brewfile at the repo root.
# Fonts:     add/remove cask entries with "font-*" in Brewfile.
# mise:      see ~/.config/mise/ for tool version management after install.
#
# To upgrade all packages later:
#   brew upgrade && brew upgrade --cask
#
# To upgrade mise:
#   mise self-update
#
# Skip mise install:   MACSETUP_SKIP_MISE=1 ./run.sh --only system
# Force reinstall:     MACSETUP_UPGRADE=1 ./run.sh --only system

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../utils/utils.sh
source "$SCRIPT_DIR/../utils/utils.sh"

trap 'handle_error $? $LINENO' ERR

BREWFILE="$SCRIPT_DIR/../Brewfile"

install_homebrew() {
    echo_header "Homebrew"

    if command_exists brew; then
        log_info "Homebrew $(brew --version | head -1) already installed."
        log_info "Updating Homebrew..."
        brew update
        return 0
    fi

    log_info "Installing Homebrew..."
    if ! command_exists xcode-select; then
        log_error "xcode-select not found. Install Xcode Command Line Tools first:"
        log_info "  xcode-select --install"
        exit 1
    fi
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    log_success "Homebrew installed."

    # Add Homebrew to current shell PATH (Apple Silicon vs Intel).
    if [[ -x /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -x /usr/local/bin/brew ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
}

install_brew_packages() {
    echo_header "Homebrew packages (Brewfile)"

    if [[ ! -f "$BREWFILE" ]]; then
        log_warn "Brewfile not found at $BREWFILE; skipping."
        return 0
    fi

    brew bundle --file="$BREWFILE" --no-lock
    brew cleanup -s
    log_success "Homebrew packages installed."
}

install_mise() {
    echo_header "mise (runtime version manager)"

    # mise is also in Brewfile, but installing via the official script matches
    # the linux-setup path (~/.local/bin/mise) so the same .zshrc activation
    # line works on both platforms without OS branching.
    if command_exists mise && ! upgrade_enabled; then
        log_info "mise $(mise --version 2>/dev/null) already installed."
        return 0
    fi

    if should_skip_step MISE; then
        log_info "Skipping mise (MACSETUP_SKIP_MISE is set)."
        return 0
    fi

    log_info "Installing mise via official installer..."
    curl -fsSL https://mise.run | sh
    log_success "mise installed to ~/.local/bin/mise"
    log_info "Reload your shell or run: eval \"\$(~/.local/bin/mise activate zsh)\""
}

main() {
    check_root

    install_homebrew
    install_brew_packages
    install_mise

    echo_header "System setup complete"
    log_success "Homebrew packages and mise are ready."
    log_info "Next: run dotfiles and shell steps."
}

main
