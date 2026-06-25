#!/usr/bin/env bash
# Neovim installation and setup for macOS.
#
# Installs neovim via Homebrew (already in Brewfile as a safety net),
# creates vi/vim → nvim shims in ~/.local/bin, and bootstraps lazy.nvim plugins.
#
# ── Neovim configuration ──────────────────────────────────────────────────────
# Config lives in the shared dotfiles/ submodule:
#   dotfiles/.config/nvim/init.lua         — entry point
#   dotfiles/.config/nvim/lua/config/      — options, keymaps, autocmds
#   dotfiles/.config/nvim/lua/plugins/     — lazy.nvim plugin specs
#     tools.lua  — core tools (telescope, treesitter, tmux-navigator, …)
#     lsp.lua    — language server configs
#     ui.lua     — theme, statusline, etc.
#
# ── Adding plugins ────────────────────────────────────────────────────────────
# Add a spec to the relevant lua/plugins/*.lua file, then run:
#   nvim --headless "+Lazy! sync" +qa
# or just open nvim and run :Lazy sync.
#
# ── Upgrading Neovim ─────────────────────────────────────────────────────────
#   brew upgrade neovim
#
# Skip:    MACSETUP_SKIP_NEOVIM=1 ./run.sh --only editor
# Upgrade: MACSETUP_UPGRADE=1     ./run.sh --only editor

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../utils/utils.sh
source "$SCRIPT_DIR/../utils/utils.sh"

trap 'handle_error $? $LINENO' ERR

load_versions

NEOVIM_VERSION="${NEOVIM_VERSION:-}"

installed_nvim_version() {
    if command_exists nvim; then
        nvim --version 2>/dev/null | head -n1 | awk '{print $2}' | sed 's/^v//'
    fi
}

install_neovim() {
    echo_header "Neovim"

    local got
    got="$(installed_nvim_version)"

    if [[ -n "$got" ]] && ! upgrade_enabled; then
        log_info "Neovim $got already installed. (MACSETUP_UPGRADE=1 to reinstall)"
        return 0
    fi

    log_info "Installing Neovim via Homebrew..."
    brew install neovim
    log_success "Neovim $(installed_nvim_version) installed."
}

register_shims() {
    # On macOS there is no update-alternatives.  Instead create symlinks in
    # ~/.local/bin (which is prepended to PATH in .zshenv) so that vi and vim
    # resolve to nvim without touching system paths.
    local nvim_path
    nvim_path="$(command -v nvim 2>/dev/null || true)"
    if [[ -z "$nvim_path" ]]; then
        log_warn "nvim not found; skipping vi/vim shims."
        return 0
    fi

    mkdir -p "$HOME/.local/bin"
    ln -sf "$nvim_path" "$HOME/.local/bin/vi"
    ln -sf "$nvim_path" "$HOME/.local/bin/vim"
    log_success "vi and vim → nvim shims created in ~/.local/bin"
}

bootstrap_plugins() {
    if ! command_exists nvim; then
        log_warn "nvim not found; skipping plugin bootstrap."
        return 0
    fi

    local nvim_config="$HOME/.config/nvim/init.lua"
    if [[ ! -f "$nvim_config" ]]; then
        log_warn "~/.config/nvim/init.lua not found; run dotfiles step first."
        return 0
    fi

    log_info "Bootstrapping Neovim plugins (headless lazy.nvim sync)..."
    nvim --headless "+Lazy! sync" +qa 2>&1 | grep -v "^$" || true
    log_success "Neovim plugins installed."
}

main() {
    check_root
    export PATH="$HOME/.local/bin:$PATH"

    if should_skip_step NEOVIM; then
        log_info "Skipping Neovim (MACSETUP_SKIP_NEOVIM is set)."
        return 0
    fi

    install_neovim
    register_shims
    bootstrap_plugins

    echo_header "Editor setup complete"
    log_success "Neovim is ready."
    log_info "Config: ~/.config/nvim/  (symlinked from dotfiles/)"
    log_info "Open nvim and run :checkhealth to verify LSP and treesitter."
}

main
