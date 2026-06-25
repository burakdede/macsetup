#!/usr/bin/env bash
# macOS Developer Machine Setup — Orchestration Script
#
# ── Quick start ───────────────────────────────────────────────────────────────
#   git clone git@github.com:burakdede/macsetup.git ~/Projects/macsetup
#   cd ~/Projects/macsetup
#   git submodule update --init dotfiles   # pull shared configs
#   ./run.sh
#
# ── Step overview ─────────────────────────────────────────────────────────────
#  1. system      — Homebrew, Brewfile packages, mise runtime manager
#  2. dotfiles    — symlink shared configs into $HOME (via dotfiles/ submodule)
#  3. configure   — interactive git identity prompts → ~/.gitconfig.local
#  4. shell       — set zsh as default shell, install antidote + powerlevel10k
#  5. editor      — neovim + lazy.nvim plugin bootstrap, vi/vim shims
#  6. multiplexer — tmux config wiring + TPM (Tmux Plugin Manager)
#  7. terminal    — WezTerm via Homebrew Cask
#  8. sdk         — SDKMAN (Java, Kotlin, …)
#  9. agents      — MCP server config for Claude Code and Codex
# 10. git         — GitHub SSH key setup (interactive; skippable)
# 11. macos       — macOS system defaults via `defaults write` (skippable)
#
# ── Syncing shared dotfiles ───────────────────────────────────────────────────
# The dotfiles/ directory is a git submodule (burakdede/dotfiles).
# Both this repo and linux-setup share the same submodule, so a config
# change committed there is available on both machines.
#
# To pull the latest dotfiles:
#   git submodule update --remote dotfiles
#   git commit -m "chore: bump dotfiles"
#
# ── Environment variable overrides ───────────────────────────────────────────
# MACSETUP_UPGRADE=1           — re-install tools even if already present
# MACSETUP_SKIP_<STEP>=1       — skip a specific step (e.g. MACSETUP_SKIP_SDK)
# MACSETUP_GIT_NAME / _EMAIL   — pre-seed git identity (non-interactive CI use)
# MACSETUP_PROMPT_TIMEOUT_SECONDS=N — timeout for configure prompts (default 60)

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=utils/utils.sh
source "$ROOT_DIR/utils/utils.sh"

trap 'handle_error $? $LINENO' ERR

INCLUDE_GIT=1
INCLUDE_MACOS=1
ONLY_STEPS=()
VERIFY_ONLY=0
RUN_TS="$(date +%Y%m%d-%H%M%S)"
LOG_FILE="${MACSETUP_LOG_FILE:-$HOME/.local/state/macsetup/logs/run-${RUN_TS}.log}"
LOGGING_INITIALIZED=0
LOG_PIPE=""
LOG_TEE_PID=""
ORIG_STDOUT_FD=""
ORIG_STDERR_FD=""

usage() {
    cat <<'EOF'
Usage: ./run.sh [options]

Options:
  --skip-git          Skip GitHub SSH setup step (default: included).
  --skip-macos        Skip macOS system defaults step (default: included).
  --include-git       Explicitly include GitHub SSH setup step.
  --include-macos     Explicitly include macOS defaults step.
  --only STEP         Run only a single step. Repeatable.
  --verify            Print a ✓/✗ summary of installed tools without installing.
  --help              Show this help text.

Valid STEP values (run in this order on a fresh machine):
  system          Homebrew, Brewfile packages, mise runtime manager
  dotfiles        Symlink shared configs from dotfiles/ submodule into $HOME
  configure       Git identity prompts — writes to ~/.gitconfig.local
  shell           Set zsh as default shell, install antidote + powerlevel10k
  editor          Neovim via Homebrew + lazy.nvim bootstrap, vi/vim shims
  multiplexer     Tmux config wiring + TPM (Tmux Plugin Manager)
  terminal        WezTerm via Homebrew Cask
  sdk             SDKMAN toolchain (Java, Kotlin, …)
  agents          MCP server config for Claude Code and Codex
  git             GitHub SSH key setup (interactive)
  macos           macOS system defaults via 'defaults write'

Dependencies:
  - Run system first on a fresh machine; other steps need its packages.
  - Run dotfiles before configure, shell, editor, multiplexer, terminal.
  - Run shell before terminal (terminal picks up the new default shell).
  - Run sdk before editor if you use Java LSP in Neovim (jdtls needs a JDK).
  - Run system before agents (agents needs npm/node).

Environment variable overrides:
  MACSETUP_UPGRADE=1           Re-install tools even if already present.
  MACSETUP_SKIP_<STEP>=1       Skip a specific step from within a script.
  MACSETUP_GIT_NAME / _EMAIL   Pre-seed git identity for non-interactive runs.
EOF
}

contains_step() {
    local wanted="$1"
    local step
    for step in "${ONLY_STEPS[@]}"; do
        [[ "$step" == "$wanted" ]] && return 0
    done
    return 1
}

should_run_step() {
    local step="$1"
    [[ ${#ONLY_STEPS[@]} -eq 0 ]] && return 0
    contains_step "$step"
}

check_step_deps() {
    local step="$1"
    shift
    local dep
    for dep in "$@"; do
        if [[ ${#ONLY_STEPS[@]} -gt 0 ]] && ! contains_step "$dep"; then
            log_warn "Step '$step' may depend on '$dep' which is not in the selected steps."
        fi
    done
}

run_script() {
    local step="$1"
    local script_path="$2"
    local description="$3"

    if [[ ! -f "$script_path" ]]; then
        log_warn "Skipping ${description}; script not found at ${script_path}."
        return 0
    fi

    echo_header "Starting: ${description}"
    bash "$script_path"
    log_success "Completed: ${description}"
}

init_run_logging() {
    [[ "$LOGGING_INITIALIZED" -eq 1 ]] && return 0

    if ! mkdir -p "$(dirname "$LOG_FILE")" || ! touch "$LOG_FILE"; then
        LOG_FILE="${TMPDIR:-/tmp}/macsetup-logs/run-${RUN_TS}.log"
        if ! mkdir -p "$(dirname "$LOG_FILE")" || ! touch "$LOG_FILE"; then
            log_warn "Could not create run log. Continuing without persistent log."
            LOGGING_INITIALIZED=0
            return 0
        fi
        log_warn "Using fallback log path: $LOG_FILE"
    fi

    LOG_PIPE="$(mktemp -u "${TMPDIR:-/tmp}/macsetup-log.XXXXXX")"
    if mkfifo "$LOG_PIPE"; then
        exec {ORIG_STDOUT_FD}>&1
        exec {ORIG_STDERR_FD}>&2
        tee -a "$LOG_FILE" < "$LOG_PIPE" &
        LOG_TEE_PID="$!"
        exec > "$LOG_PIPE" 2>&1
        LOGGING_INITIALIZED=1
    fi
}

cleanup_run_logging() {
    if [[ -n "$ORIG_STDOUT_FD" && -n "$ORIG_STDERR_FD" ]]; then
        exec 1>&"$ORIG_STDOUT_FD" 2>&"$ORIG_STDERR_FD" || true
        exec {ORIG_STDOUT_FD}>&- || true
        exec {ORIG_STDERR_FD}>&- || true
        ORIG_STDOUT_FD=""
        ORIG_STDERR_FD=""
    fi
    [[ -n "$LOG_PIPE" && -p "$LOG_PIPE" ]] && rm -f "$LOG_PIPE" || true
    [[ -n "$LOG_TEE_PID" ]] && wait "$LOG_TEE_PID" 2>/dev/null || true
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --skip-git)       INCLUDE_GIT=0 ;;
        --skip-macos)     INCLUDE_MACOS=0 ;;
        --include-git)    INCLUDE_GIT=1 ;;
        --include-macos)  INCLUDE_MACOS=1 ;;
        --only)
            shift
            [[ $# -eq 0 ]] && { log_error "--only requires a step name."; exit 1; }
            ONLY_STEPS+=("$1")
            ;;
        --verify)         VERIFY_ONLY=1 ;;
        --help|-h)        usage; exit 0 ;;
        *)                log_error "Unknown argument: $1"; usage; exit 1 ;;
    esac
    shift
done

trap cleanup_run_logging EXIT

main() {
    init_run_logging

    if [[ $VERIFY_ONLY -eq 1 ]]; then
        log_info "Run log: $LOG_FILE"
        bash "$ROOT_DIR/scripts/verify-install.sh"
        log_info "Verification log saved to: $LOG_FILE"
        return 0
    fi

    check_root
    check_directory

    local step_name
    local -a steps=(
        "system|$ROOT_DIR/system/system.sh|Homebrew packages and developer tooling"
        "dotfiles|$ROOT_DIR/dotfiles.sh|Dotfiles (shared submodule)"
        "configure|$ROOT_DIR/configure/configure.sh|Interactive configuration (git identity)"
        "shell|$ROOT_DIR/shell/shell.sh|Zsh shell"
        "editor|$ROOT_DIR/editor/editor.sh|Neovim editor"
        "multiplexer|$ROOT_DIR/multiplexer/multiplexer.sh|Tmux multiplexer"
        "terminal|$ROOT_DIR/terminal/terminal.sh|WezTerm terminal emulator"
        "sdk|$ROOT_DIR/sdk/sdk.sh|SDKMAN toolchain"
        "agents|$ROOT_DIR/agents/agents.sh|Coding agent MCP configuration"
    )

    [[ $INCLUDE_GIT -eq 1 ]]   && steps+=("git|$ROOT_DIR/git/git.sh|GitHub SSH setup")
    [[ $INCLUDE_MACOS -eq 1 ]] && steps+=("macos|$ROOT_DIR/macos/os-defaults.sh|macOS system defaults")

    echo_header "macOS developer machine bootstrap"
    log_info "Run log: $LOG_FILE"
    log_info "Use --skip-git to skip the interactive GitHub SSH step."
    log_info "Use --skip-macos to skip system defaults (safe to run later)."

    if [[ ${#ONLY_STEPS[@]} -gt 0 ]]; then
        for step_name in shell editor multiplexer terminal sdk agents; do
            contains_step "$step_name" && check_step_deps "$step_name" system
        done
        contains_step configure && check_step_deps configure dotfiles
        contains_step terminal  && check_step_deps terminal shell
        contains_step editor    && check_step_deps "editor (Java LSP)" sdk
    fi

    local total=0
    local record
    for record in "${steps[@]}"; do
        IFS='|' read -r step_name _ _ <<< "$record"
        should_run_step "$step_name" && total=$((total + 1))
    done

    if [[ $total -eq 0 ]]; then
        log_warn "No steps selected."
        exit 0
    fi

    local current=0
    local script_path description
    for record in "${steps[@]}"; do
        IFS='|' read -r step_name script_path description <<< "$record"
        should_run_step "$step_name" || continue
        current=$((current + 1))
        echo_header "Step ${current}/${total}: ${description}"
        run_script "$step_name" "$script_path" "$description"
    done

    echo_header "Bootstrap complete"
    log_success "Run log saved to: $LOG_FILE"
    log_info "Post-install checklist:"
    log_info "  1. Log out and back in for default-shell change to take effect."
    log_info "  2. Open a new terminal to load the updated zsh / mise configuration."
    log_info "  3. Open WezTerm → tmux session → nvim to verify the full stack."
    log_info "  4. Run ./run.sh --verify for a health check summary."
}

main
