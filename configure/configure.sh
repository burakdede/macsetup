#!/usr/bin/env bash
# Interactive configuration — git identity setup.
#
# Prompts for git name and email and writes them to ~/.gitconfig.local,
# which is included by the shared .gitconfig via [include] directive.
# This keeps machine-specific identity out of the committed dotfiles.
#
# ── Why .gitconfig.local? ────────────────────────────────────────────────────
# The shared dotfiles/.gitconfig contains team-shared defaults (aliases, hooks,
# diff/merge tools).  Machine-specific values (name, email, signing key) live
# in ~/.gitconfig.local so you can use a different email on work vs personal
# machines without editing the shared config.
#
# ── Non-interactive / CI use ─────────────────────────────────────────────────
# Set env vars to skip the prompts:
#   MACSETUP_GIT_NAME="Full Name" MACSETUP_GIT_EMAIL="you@example.com" ./run.sh --only configure
#
# Skip:    MACSETUP_SKIP_CONFIGURE=1 ./run.sh --only configure

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../utils/utils.sh
source "$SCRIPT_DIR/../utils/utils.sh"

trap 'handle_error $? $LINENO' ERR

LOCAL_GITCONFIG="$HOME/.gitconfig.local"
PROMPT_TIMEOUT_SECONDS="${MACSETUP_PROMPT_TIMEOUT_SECONDS:-60}"

prompt_with_default() {
    local prompt="$1"
    local default="$2"
    local result

    local prompt_out="/dev/stderr"
    local prompt_in=""
    if [[ -t 0 && -r /dev/tty && -w /dev/tty ]]; then
        prompt_out="/dev/tty"
        prompt_in="/dev/tty"
    fi

    if [[ -n "$default" ]]; then
        printf '%s [%s]: ' "$prompt" "$default" > "$prompt_out"
    else
        printf '%s: ' "$prompt" > "$prompt_out"
    fi

    if [[ "${PROMPT_TIMEOUT_SECONDS}" =~ ^[0-9]+$ ]] && [[ "$PROMPT_TIMEOUT_SECONDS" -gt 0 ]]; then
        if [[ -n "$prompt_in" ]]; then
            if ! read -r -t "$PROMPT_TIMEOUT_SECONDS" result < "$prompt_in"; then
                printf '\n' > "$prompt_out"
                log_warn "Input timed out after ${PROMPT_TIMEOUT_SECONDS}s."
                result=""
            fi
        elif ! read -r -t "$PROMPT_TIMEOUT_SECONDS" result; then
            printf '\n' > "$prompt_out"
            log_warn "Input timed out after ${PROMPT_TIMEOUT_SECONDS}s."
            result=""
        fi
    else
        if [[ -n "$prompt_in" ]]; then
            read -r result < "$prompt_in" || result=""
        else
            read -r result || result=""
        fi
    fi

    if [[ -z "$result" ]]; then
        printf '%s' "$default"
    else
        printf '%s' "$result"
    fi
}

git_local_get() {
    git config --file "$LOCAL_GITCONFIG" "$1" 2>/dev/null || true
}

git_global_get() {
    git config --global "$1" 2>/dev/null || true
}

configure_git_identity() {
    echo_header "Git identity"

    local current_name current_email
    current_name="$(git_local_get user.name || git_global_get user.name)"
    current_email="$(git_local_get user.email || git_global_get user.email)"

    if [[ -n "${MACSETUP_GIT_NAME:-}" ]]; then
        current_name="${MACSETUP_GIT_NAME}"
    fi
    if [[ -n "${MACSETUP_GIT_EMAIL:-}" ]]; then
        current_email="${MACSETUP_GIT_EMAIL}"
    fi

    if [[ -n "${MACSETUP_GIT_NAME:-}" && -n "${MACSETUP_GIT_EMAIL:-}" ]]; then
        touch "$LOCAL_GITCONFIG"
        git config --file "$LOCAL_GITCONFIG" user.name  "$MACSETUP_GIT_NAME"
        git config --file "$LOCAL_GITCONFIG" user.email "$MACSETUP_GIT_EMAIL"
        log_success "Git identity written from environment variables to $LOCAL_GITCONFIG"
        return 0
    fi

    if [[ -n "$current_name" && -n "$current_email" ]]; then
        log_info "Current git identity:"
        log_info "  name:  $current_name"
        log_info "  email: $current_email"
        printf '\nPress Enter to keep existing values, or type new ones.\n\n'
    fi

    local name email

    name="$(prompt_with_default "Full name" "$current_name")"
    if [[ -z "$name" ]]; then
        log_warn "Name cannot be empty. Skipping git identity configuration."
        return 0
    fi

    email="$(prompt_with_default "Email address" "$current_email")"
    if [[ -z "$email" ]]; then
        log_warn "Email cannot be empty. Skipping git identity configuration."
        return 0
    fi

    if [[ ! "$email" =~ ^[^@]+@[^@]+\.[^@]+$ ]]; then
        log_warn "Email '$email' does not look valid. Skipping."
        return 0
    fi

    touch "$LOCAL_GITCONFIG"
    git config --file "$LOCAL_GITCONFIG" user.name  "$name"
    git config --file "$LOCAL_GITCONFIG" user.email "$email"

    log_success "Git identity written to $LOCAL_GITCONFIG"
    log_info "  name:  $name"
    log_info "  email: $email"
}

main() {
    if should_skip_step CONFIGURE; then
        log_info "Skipping configure (MACSETUP_SKIP_CONFIGURE is set)."
        return 0
    fi

    if [[ -n "${MACSETUP_GIT_NAME:-}" && -n "${MACSETUP_GIT_EMAIL:-}" ]]; then
        configure_git_identity
        echo_header "Configuration complete"
        log_success "Machine-local settings are in $LOCAL_GITCONFIG"
        return 0
    fi

    if ! is_interactive; then
        log_info "Non-interactive environment; skipping configure step."
        log_info "Run manually: bash configure/configure.sh"
        return 0
    fi

    configure_git_identity

    echo_header "Configuration complete"
    log_success "Machine-local settings are in $LOCAL_GITCONFIG"
    log_info "This file is not committed — it stays on this machine only."
}

main
