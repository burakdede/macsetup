#!/usr/bin/env bash
# Common utility functions shared across all macsetup step scripts.
# Ported from linux-setup/utils/utils.sh; GNOME-specific helpers removed.

set -o pipefail

RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
BLUE=$'\033[0;34m'
CYAN=$'\033[0;36m'
RESET=$'\033[0m'

echo_header() {
    local title="${1:-}"
    printf '\n%s┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓%s\n' "$BLUE" "$RESET"
    printf '%s┃ %-78s ┃%s\n' "$BLUE" "${title}" "$RESET"
    printf '%s┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛%s\n' "$BLUE" "$RESET"
}

log_info() {
    printf '%s[INFO]%s %s\n' "$CYAN" "$RESET" "$1"
}

log_warn() {
    printf '%s[WARN]%s %s\n' "$YELLOW" "$RESET" "$1" >&2
}

log_error() {
    printf '%s[ERROR]%s %s\n' "$RED" "$RESET" "$1" >&2
}

log_success() {
    printf '%s[OK]%s %s\n' "$GREEN" "$RESET" "$1"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

check_root() {
    if [[ ${EUID:-$(id -u)} -eq 0 ]]; then
        log_error "Run this project as a normal user, not root."
        exit 1
    fi
}

check_directory() {
    if [[ ! -f "run.sh" ]]; then
        log_error "Run this command from the repository root."
        exit 1
    fi
}

ensure_sudo() {
    if [[ ${EUID:-$(id -u)} -eq 0 ]]; then
        return 0
    fi

    if ! sudo -v; then
        log_error "Sudo authentication failed."
        exit 1
    fi
}

handle_error() {
    local exit_code="${1:-$?}"
    local line="${2:-unknown}"
    log_error "Command failed at line ${line} (exit ${exit_code})."
    exit "$exit_code"
}

run_with_output() {
    log_info "Running: $*"
    "$@"
}

sudo_run() {
    ensure_sudo
    log_info "Running with sudo: $*"
    sudo "$@"
}

is_interactive() {
    [[ -t 0 && -t 1 ]]
}

join_by() {
    local separator="$1"
    shift
    local first=1
    local item

    for item in "$@"; do
        if [[ $first -eq 1 ]]; then
            printf '%s' "$item"
            first=0
        else
            printf '%s%s' "$separator" "$item"
        fi
    done
}

trim() {
    local value="$1"
    value="${value#"${value%%[![:space:]]*}"}"
    value="${value%"${value##*[![:space:]]}"}"
    printf '%s' "$value"
}

read_list_file() {
    local file_path="$1"

    while IFS= read -r line || [[ -n "$line" ]]; do
        line="${line%%#*}"
        line="$(trim "$line")"
        [[ -z "$line" ]] && continue
        printf '%s\n' "$line"
    done < "$file_path"
}

ensure_line_in_file() {
    local line="$1"
    local file_path="$2"

    mkdir -p "$(dirname "$file_path")"
    touch "$file_path"

    if ! grep -Fqx "$line" "$file_path"; then
        printf '%s\n' "$line" >> "$file_path"
    fi
}

# Load KEY=VALUE pairs from versions.txt into the environment.
# Called by step scripts that need pinned versions (editor, terminal).
load_versions() {
    local versions_file="${1:-}"
    if [[ -z "$versions_file" ]]; then
        local utils_dir
        utils_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        versions_file="$utils_dir/../versions.txt"
    fi

    [[ -f "$versions_file" ]] || return 0

    local line key value
    while IFS= read -r line || [[ -n "$line" ]]; do
        line="${line%%#*}"
        line="$(trim "$line")"
        [[ -z "$line" ]] && continue
        key="${line%%=*}"
        value="${line#*=}"
        export "$key"="$value"
    done < "$versions_file"
}

flag_enabled() {
    local value="${1:-0}"
    case "$value" in
        1|true|TRUE|yes|YES|on|ON) return 0 ;;
        *) return 1 ;;
    esac
}

# Check MACSETUP_SKIP_<STEP>=1 env var.
should_skip_step() {
    local step_name="$1"
    local var_name="MACSETUP_SKIP_${step_name}"
    flag_enabled "${!var_name:-0}"
}

# Check MACSETUP_UPGRADE=1 env var — forces reinstall even if tool is present.
upgrade_enabled() {
    flag_enabled "${MACSETUP_UPGRADE:-0}"
}
