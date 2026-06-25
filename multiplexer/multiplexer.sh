#!/usr/bin/env bash
# Tmux multiplexer setup — identical on macOS and Linux.
#
# tmux is installed via Brewfile (system step).  This script wires up the
# XDG-compatible config path and installs TPM (Tmux Plugin Manager).
#
# ── Tmux configuration ────────────────────────────────────────────────────────
# Config lives in the shared dotfiles/ submodule:
#   dotfiles/.config/tmux/tmux.conf
#
# tmux 3.1+ reads ~/.config/tmux/tmux.conf automatically when XDG_CONFIG_HOME
# is set.  For older versions this script creates ~/.tmux.conf as a shim that
# sources the XDG path.
#
# ── Adding tmux plugins ───────────────────────────────────────────────────────
# Add a `set -g @plugin '...'` line to tmux.conf, then inside a running tmux
# session press prefix + I (capital i) to install.
#
# ── Upgrading plugins ─────────────────────────────────────────────────────────
# Inside a tmux session: prefix + U

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../utils/utils.sh
source "$SCRIPT_DIR/../utils/utils.sh"

trap 'handle_error $? $LINENO' ERR

ensure_tmux_config() {
    echo_header "Tmux"

    if ! command_exists tmux; then
        log_warn "tmux is not installed. Run the system step first."
        return 0
    fi

    local version
    version="$(tmux -V | awk '{print $2}')"
    log_info "tmux version: $version"

    local config_dir="$HOME/.config/tmux"
    mkdir -p "$config_dir"

    # Create ~/.tmux.conf shim for tmux < 3.1.
    local shim="$HOME/.tmux.conf"
    local xdg_conf="$config_dir/tmux.conf"
    local shim_line="source-file $xdg_conf"

    if [[ ! -f "$shim" ]]; then
        printf '%s\n' "$shim_line" > "$shim"
        log_info "Created ~/.tmux.conf shim pointing to $xdg_conf"
    else
        if ! grep -Fq "$shim_line" "$shim"; then
            log_info "$HOME/.tmux.conf already exists; not overwriting."
        fi
    fi

    local plugin_root="$HOME/.local/share/tmux/plugins"
    local tpm_dir="$plugin_root/tpm"
    mkdir -p "$plugin_root"

    if [[ ! -d "$tpm_dir" ]] && command_exists git; then
        log_info "Installing TPM (Tmux Plugin Manager)..."
        git clone --depth 1 https://github.com/tmux-plugins/tpm "$tpm_dir"
        log_success "TPM installed at $tpm_dir"
    elif [[ -d "$tpm_dir" ]]; then
        log_info "TPM is already installed."
    fi

    if [[ -x "$tpm_dir/bin/install_plugins" ]]; then
        "$tpm_dir/bin/install_plugins" >/dev/null 2>&1 || true
    fi

    log_success "Tmux config: $xdg_conf"
}

main() {
    check_root
    ensure_tmux_config
    echo_header "Multiplexer setup complete"
}

main
