#!/usr/bin/env bash
# Dotfiles symlinker for macOS.
#
# Creates symlinks from $HOME (and $HOME/.config) to the shared dotfiles
# that live in the `dotfiles/` git submodule.  Editing files in-place inside
# the submodule working tree is immediately reflected in the repo — no copy
# step needed.
#
# ── Shared dotfiles repo ──────────────────────────────────────────────────────
# The dotfiles/ directory is a git submodule pointing to burakdede/dotfiles.
# Both macsetup and linux-setup reference the same submodule, so a config
# change committed there is picked up by both machines on the next
# `git submodule update --remote dotfiles` + commit.
#
# To update dotfiles on this machine after a remote commit:
#   git submodule update --remote dotfiles
#   git commit -m "chore: bump dotfiles"
#
# To edit a config:
#   $EDITOR ~/Projects/macsetup/dotfiles/.config/nvim/init.lua
#   cd ~/Projects/macsetup/dotfiles && git commit -am "..." && git push
#
# ── What this script does ─────────────────────────────────────────────────────
# 1. Backs up any existing non-symlink files before overwriting them.
# 2. Symlinks each top-level dotfile (.*) in dotfiles/ → $HOME/
# 3. Symlinks each .config sub-directory individually (never symlinks
#    ~/.config itself — other tools own entries there).
#
# Safe to re-run: idempotent.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$SCRIPT_DIR/dotfiles"
# shellcheck source=utils/utils.sh
source "$SCRIPT_DIR/utils/utils.sh"

trap 'handle_error $? $LINENO' ERR

BACKUP_ROOT="$HOME/.local/state/macsetup/dotfiles-backups/$(date +%Y%m%d-%H%M%S)"

backup_target() {
    local target="$1"
    local relative="${target#"$HOME"/}"
    local backup_path="$BACKUP_ROOT/$relative"

    [[ ! -e "$target" && ! -L "$target" ]] && return 0

    # Skip symlinks already pointing into our dotfiles dir.
    # Use plain readlink (not -f) — macOS BSD readlink does not support -f.
    if [[ -L "$target" ]] && \
       [[ "$(readlink "$target" 2>/dev/null)" == "$DOTFILES_DIR"* ]]; then
        return 0
    fi

    mkdir -p "$(dirname "$backup_path")"
    cp -a "$target" "$backup_path"
}

link_path() {
    local source_path="$1"
    local target_path="$2"

    backup_target "$target_path"
    mkdir -p "$(dirname "$target_path")"
    rm -rf "$target_path"
    ln -sf "$source_path" "$target_path"
    log_success "Linked $(basename "$target_path")"
}

install_config_entries() {
    local config_source="$DOTFILES_DIR/.config"
    local config_target="$HOME/.config"

    [[ -d "$config_source" ]] || return 0

    mkdir -p "$config_target"

    shopt -s dotglob nullglob
    local item
    for item in "$config_source"/*; do
        local name
        name="$(basename "$item")"
        link_path "$item" "$config_target/$name"
    done
    shopt -u dotglob nullglob
}

install_home_dotfiles() {
    shopt -s dotglob nullglob
    local path
    for path in "$DOTFILES_DIR"/*; do
        local name
        name="$(basename "$path")"

        # Skip the .config sub-directory (handled separately above).
        [[ "$name" == ".config" ]] && continue

        link_path "$path" "$HOME/$name"
    done
    shopt -u dotglob nullglob
}

install_macos_configs() {
    # macOS-specific .config entries that are NOT in the shared dotfiles submodule.
    # Add any macOS-only tool configs here (e.g. alacritty, iTerm2 dynamic profiles).
    local macos_config="$SCRIPT_DIR/configs/.config"
    [[ -d "$macos_config" ]] || return 0

    local config_target="$HOME/.config"
    mkdir -p "$config_target"

    shopt -s dotglob nullglob
    local item
    for item in "$macos_config"/*; do
        local name
        name="$(basename "$item")"
        link_path "$item" "$config_target/$name"
    done
    shopt -u dotglob nullglob
}

main() {
    if [[ ! -d "$DOTFILES_DIR" ]]; then
        log_error "dotfiles/ submodule not found at $DOTFILES_DIR"
        log_info "Run: git submodule update --init dotfiles"
        exit 1
    fi

    echo_header "Dotfiles"
    mkdir -p "$BACKUP_ROOT"

    install_home_dotfiles
    install_config_entries
    install_macos_configs   # alacritty and other macOS-only configs

    mkdir -p "$HOME/.git_template"
    log_success "Created ~/.git_template (required by init.templateDir in .gitconfig)"
    log_info "Backups (if any) stored in $BACKUP_ROOT"
}

main
