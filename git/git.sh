#!/usr/bin/env bash
# GitHub SSH key setup — works on macOS and Linux.
#
# Generates an ed25519 SSH key, loads it into the agent, copies the public key
# to the clipboard (pbcopy on macOS), and tests the GitHub connection.
#
# ── This step is optional ────────────────────────────────────────────────────
# Skip it with --skip-git when running headlessly (CI, first-time bootstrap
# without browser access).  Run it manually later:
#   bash git/git.sh
#
# If SSH auth already works (key already added to GitHub), this script exits
# early after a quick connection test.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../utils/utils.sh
source "$SCRIPT_DIR/../utils/utils.sh"

github_ssh_auth_works() {
    local ssh_output
    set +e
    if command_exists timeout; then
        ssh_output="$(timeout 15 ssh -T git@github.com -o ConnectTimeout=10 -o BatchMode=yes -o StrictHostKeyChecking=accept-new 2>&1)"
    else
        ssh_output="$(ssh -T git@github.com -o ConnectTimeout=10 -o BatchMode=yes -o StrictHostKeyChecking=accept-new 2>&1)"
    fi
    set -e

    if echo "$ssh_output" | grep -q "successfully authenticated"; then
        return 0
    fi
    return 1
}

setup_ssh_key() {
    echo_header "SSH key"
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh

    if [[ -f ~/.ssh/id_ed25519 ]]; then
        log_warn "SSH key already exists at ~/.ssh/id_ed25519"
        chmod 600 ~/.ssh/id_ed25519
        [[ -f ~/.ssh/id_ed25519.pub ]] && chmod 644 ~/.ssh/id_ed25519.pub
    else
        local local_email
        local_email="$(git config --global user.email 2>/dev/null || echo "")"
        if [[ -z "$local_email" ]]; then
            log_warn "No git email configured. Run the configure step first."
            local_email="user@example.com"
        fi
        log_info "Generating ed25519 SSH key (comment: $local_email)..."
        ssh-keygen -t ed25519 -C "$local_email" -f ~/.ssh/id_ed25519 -N ""
        chmod 600 ~/.ssh/id_ed25519
        chmod 644 ~/.ssh/id_ed25519.pub
    fi
}

load_ssh_agent() {
    echo_header "SSH agent"
    local key_loaded=false

    if [[ -n "${SSH_AGENT_PID:-}" ]] && kill -0 "$SSH_AGENT_PID" 2>/dev/null; then
        if ssh-add -l 2>/dev/null | grep -q "id_ed25519"; then
            log_success "Key already loaded in SSH agent."
            key_loaded=true
        fi
    fi

    if [[ "$key_loaded" == "false" ]]; then
        if [[ -z "${SSH_AGENT_PID:-}" ]] || ! kill -0 "${SSH_AGENT_PID:-0}" 2>/dev/null; then
            eval "$(ssh-agent -s)"
        fi
        ssh-add ~/.ssh/id_ed25519
    fi
}

add_key_to_github() {
    echo_header "Add key to GitHub"

    if [[ -f ~/.ssh/id_ed25519.pub ]]; then
        if command_exists pbcopy; then
            pbcopy < ~/.ssh/id_ed25519.pub
            log_success "SSH public key copied to clipboard (pbcopy)."
        elif command_exists xclip; then
            xclip -selection clipboard < ~/.ssh/id_ed25519.pub
            log_success "SSH public key copied to clipboard (xclip)."
        else
            log_info "Public key content (copy and paste to GitHub):"
            cat ~/.ssh/id_ed25519.pub
        fi
    fi

    if ! grep -q "github.com" ~/.ssh/known_hosts 2>/dev/null; then
        touch ~/.ssh/known_hosts
        chmod 644 ~/.ssh/known_hosts
        ssh-keyscan -t ed25519 github.com >> ~/.ssh/known_hosts 2>/dev/null || true
    fi

    log_info "1. Go to: https://github.com/settings/keys"
    log_info "2. Click 'New SSH key' and paste the key from clipboard."

    if command_exists open; then
        open "https://github.com/settings/keys" 2>/dev/null || true
    fi

    read -r -p "After adding the key to GitHub, press Enter to test..."
}

test_github_connection() {
    echo_header "Testing SSH connection to GitHub"
    local ssh_out ssh_code

    set +e
    ssh_out="$(timeout 30 ssh -T git@github.com -o ConnectTimeout=10 -o BatchMode=yes -o StrictHostKeyChecking=yes 2>&1)"
    ssh_code=$?
    set -e

    if echo "$ssh_out" | grep -q "successfully authenticated"; then
        local username
        username="$(echo "$ssh_out" | grep "Hi " | cut -d' ' -f2 | cut -d'!' -f1)"
        log_success "Connected to GitHub as: $username"
    elif [[ $ssh_code -eq 124 ]]; then
        log_error "Connection timed out. Check network or firewall."
        exit 1
    else
        log_error "Authentication failed. Check that the key was added to GitHub correctly."
        log_info "SSH output: $ssh_out"
        exit 1
    fi
}

main() {
    echo_header "Checking Git installation"
    if ! command_exists git; then
        log_error "Git is not installed. Run the system step first."
        exit 1
    fi
    log_success "Git is installed."

    setup_ssh_key
    load_ssh_agent

    if github_ssh_auth_works; then
        echo_header "GitHub SSH"
        log_success "GitHub SSH authentication is already working."
        return 0
    fi

    add_key_to_github
    test_github_connection

    echo_header "GitHub SSH setup complete"
    log_success "SSH key: ~/.ssh/id_ed25519"
    log_info "Clone repos with: git clone git@github.com:username/repo.git"
}

main
