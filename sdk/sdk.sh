#!/usr/bin/env bash
# SDKMAN installation and package bootstrap — identical on macOS and Linux.
#
# SDKMAN manages JVM-ecosystem SDKs (Java, Kotlin, Gradle, …).
# It is separate from mise because SDKMAN has richer JVM tooling (switching
# between vendors, GraalVM, etc.) whereas mise is better for other runtimes.
#
# ── Adding SDK candidates ─────────────────────────────────────────────────────
# Edit sdk/packages.txt — one candidate per line, comments with #.
# Then run: ./run.sh --only sdk
#
# ── Installing a specific version ────────────────────────────────────────────
# sdk/packages.txt lists the candidate name only; SDKMAN installs the latest
# stable version.  To pin a version, specify it manually:
#   sdk install java 21.0.3-tem
#
# ── Upgrading SDKMAN itself ───────────────────────────────────────────────────
#   sdk selfupdate
#
# Skip:    MACSETUP_SKIP_SDK=1 ./run.sh --only sdk

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../utils/utils.sh
source "$SCRIPT_DIR/../utils/utils.sh"

trap 'handle_error $? $LINENO' ERR

SDKMAN_INIT="$HOME/.sdkman/bin/sdkman-init.sh"
PACKAGES_FILE="$SCRIPT_DIR/packages.txt"

load_sdkman() {
    local restore_nounset=0

    if [[ -s "$SDKMAN_INIT" ]]; then
        [[ -o nounset ]] && { restore_nounset=1; set +u; }
        # shellcheck source=/dev/null
        source "$SDKMAN_INIT"
        [[ "$restore_nounset" -eq 1 ]] && set -u
        return 0
    fi

    log_info "Installing SDKMAN..."
    local tmp_installer
    tmp_installer="$(mktemp)"
    curl -fsSL "https://get.sdkman.io" -o "$tmp_installer"
    [[ -o nounset ]] && { restore_nounset=1; set +u; }
    # rcupdate=false prevents SDKMAN from touching .zshrc/.bashrc;
    # the dotfiles/ .zshrc already sources sdkman-init.sh conditionally.
    SDKMAN_DIR="$HOME/.sdkman" rcupdate=false bash "$tmp_installer"
    [[ "$restore_nounset" -eq 1 ]] && { set -u; restore_nounset=0; }
    rm -f "$tmp_installer"
    [[ -o nounset ]] && { restore_nounset=1; set +u; }
    # shellcheck source=/dev/null
    source "$SDKMAN_INIT"
    [[ "$restore_nounset" -eq 1 ]] && set -u
}

run_sdk() {
    local restore_nounset=0
    [[ -o nounset ]] && { restore_nounset=1; set +u; }
    sdk "$@"
    local rc=$?
    [[ "$restore_nounset" -eq 1 ]] && set -u
    return "$rc"
}

install_sdk_packages() {
    echo_header "SDKMAN packages"

    if [[ ! -f "$PACKAGES_FILE" ]]; then
        log_warn "Missing $PACKAGES_FILE; skipping SDKMAN packages."
        return 0
    fi

    local candidate
    while IFS= read -r candidate || [[ -n "$candidate" ]]; do
        candidate="${candidate%%#*}"
        candidate="$(trim "$candidate")"
        [[ -z "$candidate" ]] && continue

        log_info "Installing SDKMAN candidate: $candidate"
        run_sdk install "$candidate" || log_warn "Unable to install $candidate. Try: sdk list $candidate"
    done < "$PACKAGES_FILE"
}

main() {
    if should_skip_step SDK; then
        log_info "Skipping SDKMAN (MACSETUP_SKIP_SDK is set)."
        return 0
    fi

    load_sdkman
    run_sdk selfupdate || true
    run_sdk update    || true
    install_sdk_packages

    echo_header "SDKMAN setup complete"
    log_success "SDKMAN initialised via ~/.sdkman/bin/sdkman-init.sh"
    log_info "~/.zshrc sources SDKMAN automatically on interactive shells."
}

main
