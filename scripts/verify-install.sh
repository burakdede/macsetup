#!/usr/bin/env bash
# Post-install health check for macOS developer setup.
#
# Prints a ✓/✗ summary for every tool and config file managed by macsetup.
# Does not install anything — safe to run at any time.
#
# Usage:
#   ./run.sh --verify
#   bash scripts/verify-install.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck source=../utils/utils.sh
source "$ROOT_DIR/utils/utils.sh"

PASS=0
FAIL=0

check() {
    local label="$1"
    local result="$2"  # "ok" or anything else = fail

    if [[ "$result" == "ok" ]]; then
        printf '%s[✓]%s %s\n' "$GREEN" "$RESET" "$label"
        PASS=$((PASS + 1))
    else
        printf '%s[✗]%s %s  (%s)\n' "$RED" "$RESET" "$label" "$result"
        FAIL=$((FAIL + 1))
    fi
}

check_cmd() {
    local label="$1"
    local cmd="$2"
    if command_exists "$cmd"; then
        local ver
        ver="$("$cmd" --version 2>/dev/null | head -1 || echo "installed")"
        check "$label" "ok"
    else
        check "$label" "not found"
    fi
}

check_symlink() {
    local label="$1"
    local path="$2"

    if [[ -L "$path" ]]; then
        check "$label" "ok"
    elif [[ -e "$path" ]]; then
        check "$label" "exists but is not a symlink — re-run dotfiles step"
    else
        check "$label" "missing — run dotfiles step"
    fi
}

check_dir() {
    local label="$1"
    local path="$2"

    if [[ -d "$path" ]]; then
        check "$label" "ok"
    else
        check "$label" "missing"
    fi
}

echo_header "macsetup install verification"

# ── Homebrew ──────────────────────────────────────────────────────────────────
echo_header "Homebrew"
check_cmd "brew" "brew"

# ── Core CLI tools ────────────────────────────────────────────────────────────
echo_header "Core CLI"
check_cmd "git"       "git"
check_cmd "curl"      "curl"
check_cmd "jq"        "jq"
check_cmd "ripgrep (rg)" "rg"
check_cmd "eza"       "eza"
check_cmd "bat"       "bat"
check_cmd "fd"        "fd"
check_cmd "fzf"       "fzf"
check_cmd "gh (GitHub CLI)" "gh"
check_cmd "just (task runner)" "just"
check_cmd "direnv"             "direnv"
check_cmd "shfmt"              "shfmt"
check_cmd "uv (Python)"        "uv"

# ── Runtime manager ───────────────────────────────────────────────────────────
echo_header "mise"
if [[ -x "$HOME/.local/bin/mise" ]]; then
    check "mise binary at ~/.local/bin/mise" "ok"
else
    check "mise binary at ~/.local/bin/mise" "not found — run system step"
fi

# ── Shell ─────────────────────────────────────────────────────────────────────
echo_header "Shell (zsh)"
check_cmd "zsh" "zsh"

default_shell="$(dscl . -read "/Users/$USER" UserShell 2>/dev/null | awk '{print $2}' || true)"
if echo "$default_shell" | grep -q "zsh"; then
    check "default shell is zsh ($default_shell)" "ok"
else
    check "default shell is zsh" "current: $default_shell — run shell step"
fi

check_dir "antidote"     "$HOME/.local/share/antidote"
check_dir "powerlevel10k" "$HOME/.local/share/powerlevel10k"

# ── Dotfiles ──────────────────────────────────────────────────────────────────
echo_header "Dotfiles (symlinks)"
check_symlink "~/.zshrc"           "$HOME/.zshrc"
check_symlink "~/.zshenv"          "$HOME/.zshenv"
check_symlink "~/.zprofile"        "$HOME/.zprofile"
check_symlink "~/.p10k.zsh"        "$HOME/.p10k.zsh"
check_symlink "~/.zsh_plugins.txt" "$HOME/.zsh_plugins.txt"
check_symlink "~/.gitconfig"       "$HOME/.gitconfig"
check_symlink "~/.vimrc"           "$HOME/.vimrc"

check_symlink "~/.config/nvim"     "$HOME/.config/nvim"
check_symlink "~/.config/tmux"     "$HOME/.config/tmux"
check_symlink "~/.config/wezterm"  "$HOME/.config/wezterm"

# ── Neovim ────────────────────────────────────────────────────────────────────
echo_header "Neovim"
check_cmd "nvim" "nvim"

if command_exists nvim; then
    local_ver="$(nvim --version 2>/dev/null | head -1 | awk '{print $2}' | sed 's/^v//')"
    load_versions
    wanted="${NEOVIM_VERSION:-}"
    if [[ -n "$wanted" && "$local_ver" != "$wanted" ]]; then
        check "neovim version $wanted" "installed: $local_ver (run: brew upgrade neovim)"
    else
        check "neovim version" "ok ($local_ver)"
    fi
fi

vi_target="$(readlink "$HOME/.local/bin/vi" 2>/dev/null || true)"
if echo "$vi_target" | grep -q "nvim"; then
    check "vi → nvim shim" "ok"
else
    check "vi → nvim shim" "missing — run editor step"
fi

# ── Tmux ──────────────────────────────────────────────────────────────────────
echo_header "Tmux"
check_cmd "tmux" "tmux"
check_dir "TPM" "$HOME/.local/share/tmux/plugins/tpm"
check_symlink "~/.config/tmux (symlink)" "$HOME/.config/tmux"

# ── WezTerm ───────────────────────────────────────────────────────────────────
echo_header "WezTerm"
check_cmd "wezterm" "wezterm"
check_symlink "~/.config/wezterm (symlink)" "$HOME/.config/wezterm"

# ── SDKMAN ────────────────────────────────────────────────────────────────────
echo_header "SDKMAN"
if [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]]; then
    check "SDKMAN init script" "ok"
else
    check "SDKMAN init script" "missing — run sdk step"
fi

# ── Agents ────────────────────────────────────────────────────────────────────
echo_header "Coding agents"
check_cmd "claude (Claude Code)" "claude"
check_cmd "codex"                "codex"
check_cmd "opencode"             "opencode"
check_symlink "~/.config/agents"             "$HOME/.config/agents"
check_symlink "~/.config/mise"               "$HOME/.config/mise"

if [[ -L "$HOME/.claude/CLAUDE.md" ]]; then
    check "~/.claude/CLAUDE.md → central instructions" "ok"
elif [[ -f "$HOME/.claude/CLAUDE.md" ]]; then
    check "~/.claude/CLAUDE.md → central instructions" "exists but not a symlink — re-run agents step"
else
    check "~/.claude/CLAUDE.md → central instructions" "missing — run agents step"
fi

# ── Summary ───────────────────────────────────────────────────────────────────
echo_header "Summary"
printf '%s[✓]%s %d passed    %s[✗]%s %d failed\n' \
    "$GREEN" "$RESET" "$PASS" "$RED" "$RESET" "$FAIL"

if [[ $FAIL -gt 0 ]]; then
    log_info "Run ./run.sh to install missing components, or use --only STEP for a single step."
    exit 1
fi
