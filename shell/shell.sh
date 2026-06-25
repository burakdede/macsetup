#!/usr/bin/env bash
# Zsh shell setup for macOS.
#
# Sets Homebrew zsh as the default login shell, clones antidote (plugin manager)
# and powerlevel10k (prompt theme), and pre-bundles plugins for fast first-launch.
#
# ── How the shell stack works ─────────────────────────────────────────────────
# .zshenv  — sourced for every zsh process; sets PATH, XDG dirs, EDITOR
# .zprofile — sourced for login shells; Homebrew shellenv lives here on macOS
# .zshrc   — sourced for interactive shells; plugins, aliases, prompt
# .p10k.zsh — powerlevel10k theme config (run `p10k configure` to regenerate)
# .zsh_plugins.txt — antidote plugin spec (one plugin per line)
#
# All of the above live in the shared dotfiles/ submodule so they are
# identical across macOS and Linux.
#
# ── Adding or removing plugins ────────────────────────────────────────────────
# Edit dotfiles/.zsh_plugins.txt, then restart your shell.  antidote will
# rebuild .zsh_plugins.zsh automatically on the next interactive session.
#
# ── Customisation that stays local to this machine ────────────────────────────
# Put machine-specific overrides in ~/.zshrc.local (not committed to any repo).
# Example: export WORK_API_KEY="..."
#
# Skip:    MACSETUP_SKIP_SHELL=1 ./run.sh --only shell
# Upgrade: MACSETUP_UPGRADE=1  ./run.sh --only shell (re-clones antidote/p10k)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../utils/utils.sh
source "$SCRIPT_DIR/../utils/utils.sh"

trap 'handle_error $? $LINENO' ERR

ANTIDOTE_DIR="$HOME/.local/share/antidote"
P10K_DIR="$HOME/.local/share/powerlevel10k"

set_default_shell() {
    echo_header "Default shell"

    local zsh_path
    # Prefer Homebrew zsh over the macOS system zsh (/bin/zsh is fine but older).
    if [[ -x "$(brew --prefix 2>/dev/null)/bin/zsh" ]]; then
        zsh_path="$(brew --prefix)/bin/zsh"
    else
        zsh_path="$(command -v zsh 2>/dev/null || true)"
    fi

    if [[ -z "$zsh_path" ]]; then
        log_warn "zsh not found; cannot set as default shell. Install via Brewfile first."
        return 0
    fi

    # Add to /etc/shells if absent (required before chsh accepts it).
    if ! grep -Fqx "$zsh_path" /etc/shells 2>/dev/null; then
        log_info "Adding $zsh_path to /etc/shells (requires sudo)..."
        printf '%s\n' "$zsh_path" | sudo tee -a /etc/shells >/dev/null
    fi

    local current_shell
    # dscl is the macOS-native way to read the login shell.
    current_shell="$(dscl . -read "/Users/$USER" UserShell 2>/dev/null | awk '{print $2}' || true)"

    if [[ "$current_shell" == "$zsh_path" ]]; then
        log_info "Default shell is already $zsh_path."
        return 0
    fi

    chsh -s "$zsh_path"
    log_success "Default shell changed to $zsh_path (effective after next login)."
}

wire_mise_activation() {
    # shellcheck disable=SC2016
    local mise_line='eval "$("$HOME/.local/bin/mise" activate zsh)"'
    local zshrc="$HOME/.zshrc"

    # If .zshrc is already a symlink into the dotfiles repo, the activation
    # line is already present in the source file.
    if [[ -L "$zshrc" ]]; then
        log_info "$HOME/.zshrc is a symlink; mise activation line already present in source."
        return 0
    fi

    ensure_line_in_file "$mise_line" "$zshrc"
    log_success "mise activation wired into ~/.zshrc"
}

sync_git_repo() {
    local repo_url="$1"
    local dest_dir="$2"

    if [[ -d "$dest_dir/.git" ]]; then
        if upgrade_enabled; then
            log_info "Upgrading $(basename "$dest_dir")..."
            git -C "$dest_dir" pull --ff-only >/dev/null 2>&1 || log_warn "Could not fast-forward $dest_dir."
        else
            log_info "$(basename "$dest_dir") already present."
        fi
        return 0
    fi

    log_info "Cloning $(basename "$dest_dir")..."
    mkdir -p "$(dirname "$dest_dir")"
    if ! git clone --depth 1 "$repo_url" "$dest_dir" >/dev/null 2>&1; then
        log_warn "Could not clone $repo_url."
    fi
}

install_shell_profile_tools() {
    echo_header "Zsh prompt and plugins (antidote + powerlevel10k)"

    sync_git_repo "https://github.com/mattmc3/antidote.git"    "$ANTIDOTE_DIR"
    sync_git_repo "https://github.com/romkatv/powerlevel10k.git" "$P10K_DIR"

    # Pre-bundle plugins so the first shell launch is fast and offline-safe.
    local plugins_txt="${ZDOTDIR:-$HOME}/.zsh_plugins.txt"
    local plugins_zsh="${ZDOTDIR:-$HOME}/.zsh_plugins.zsh"
    if [[ -f "$plugins_txt" && -d "$ANTIDOTE_DIR/functions" ]]; then
        log_info "Pre-bundling zsh plugins with antidote..."
        local clean_txt
        clean_txt="$(mktemp)"
        grep -Ev '^[[:space:]]*(#|$)' "$plugins_txt" > "$clean_txt"
        ANTIDOTE_HOME="$ANTIDOTE_DIR" \
            zsh -c "fpath=('$ANTIDOTE_DIR/functions' \$fpath); autoload -Uz antidote; antidote bundle < '$clean_txt'" \
            2>&1 | grep -Ev '^[[:space:]]*warning:' >| "$plugins_zsh" || true
        rm -f "$clean_txt"
        log_success "Plugins bundled to $plugins_zsh"
    fi

    log_success "antidote and powerlevel10k ready."
    log_info "Run 'p10k configure' to customise the prompt after first login."
}

main() {
    check_root
    export PATH="$HOME/.local/bin:$PATH"

    if should_skip_step SHELL; then
        log_info "Skipping shell setup (MACSETUP_SKIP_SHELL is set)."
        return 0
    fi

    set_default_shell
    wire_mise_activation
    install_shell_profile_tools

    echo_header "Shell setup complete"
    log_success "zsh is the default shell."
    log_info "Configs: ~/.zshrc  ~/.zshenv  ~/.zprofile  (symlinked from dotfiles/)"
    log_info "Log out and back in for the shell change to take effect."
}

main
