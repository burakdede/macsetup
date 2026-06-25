#!/usr/bin/env bash
# Coding agent configuration — MCP servers for Claude Code and Codex.
# Identical on macOS and Linux (pure JSON/file manipulation via jq).
#
# ── What this registers ───────────────────────────────────────────────────────
# No-auth MCPs (registered for both Claude Code and Codex):
#   filesystem         — file system access via MCP
#   memory             — persistent memory server
#   sequential-thinking — chain-of-thought reasoning
#   fetch              — HTTP fetch via uvx
#   playwright         — browser automation
#
# Token-gated MCPs (you must fill in the API keys after first run):
#   linear             — Linear project management  → LINEAR_API_KEY
#   notion             — Notion workspace           → NOTION_TOKEN
#   miro               — Miro whiteboards           → MIRO_ACCESS_TOKEN
#
# ── Filling in API keys ───────────────────────────────────────────────────────
#   ~/.claude.json       — Claude Code MCP config
#   ~/.openai/mcp.json   — Codex MCP config
# Edit those files and replace the empty string values for each key.
#
# ── Adding a new MCP ─────────────────────────────────────────────────────────
# Add an add_mcp_all / try_add_mcp_all call below, then re-run:
#   ./run.sh --only agents
#
# Skip:    MACSETUP_SKIP_AGENTS=1 ./run.sh --only agents

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../utils/utils.sh
source "$SCRIPT_DIR/../utils/utils.sh"

CLAUDE_JSON="$HOME/.claude.json"
CODEX_JSON="$HOME/.openai/mcp.json"

_add_mcp_to_file() {
    local target="$1"
    local key_path="$2"
    local name="$3"
    local config="$4"

    mkdir -p "$(dirname "$target")"

    local tmp
    tmp="$(mktemp)"
    if [[ -f "$target" ]]; then
        jq --arg n "$name" --argjson c "$config" \
            "${key_path}"'[$n] = $c' "$target" > "$tmp"
    else
        jq -n --arg n "$name" --argjson c "$config" \
            "{mcpServers: {(\$n): \$c}}" > "$tmp"
    fi
    if jq empty "$tmp" 2>/dev/null; then
        mv "$tmp" "$target"
    else
        rm -f "$tmp"
        log_warn "jq produced invalid JSON for MCP '$name' — $target not modified"
        return 1
    fi
}

add_mcp_claude() {
    local name="$1"
    local config="$2"
    _add_mcp_to_file "$CLAUDE_JSON" ".mcpServers" "$name" "$config"
    log_info "Claude Code MCP registered: $name"
}

add_mcp_codex() {
    local name="$1"
    local config="$2"
    _add_mcp_to_file "$CODEX_JSON" ".mcpServers" "$name" "$config"
    log_info "Codex MCP registered: $name"
}

add_mcp_all() {
    local name="$1"
    local config="$2"
    add_mcp_claude "$name" "$config"
    add_mcp_codex  "$name" "$config"
}

try_add_mcp_all() {
    local name="$1"
    local config="$2"

    local claude_has codex_has
    claude_has=$(jq -e --arg n "$name" '.mcpServers[$n] // empty' "$CLAUDE_JSON" 2>/dev/null && echo yes || echo no)
    codex_has=$(jq -e --arg n "$name" '.mcpServers[$n] // empty' "$CODEX_JSON" 2>/dev/null && echo yes || echo no)

    if [[ "$claude_has" == "yes" && "$codex_has" == "yes" ]]; then
        log_info "MCP '$name' already registered — skipping to preserve existing config."
        return 0
    fi

    if ! (add_mcp_all "$name" "$config") 2>/dev/null; then
        log_warn "MCP '$name' could not be registered — fill in manually later"
    fi
}

configure_mcps() {
    echo_header "MCP servers (Claude Code + Codex)"

    add_mcp_all "filesystem" "$(jq -n \
        --arg home "$HOME" \
        '{command:"npx",args:["-y","@modelcontextprotocol/server-filesystem",$home]}')"

    add_mcp_all "memory" \
        '{"command":"npx","args":["-y","@modelcontextprotocol/server-memory"]}'

    add_mcp_all "sequential-thinking" \
        '{"command":"npx","args":["-y","@modelcontextprotocol/server-sequential-thinking"]}'

    add_mcp_all "fetch" \
        '{"command":"uvx","args":["mcp-server-fetch"]}'

    add_mcp_all "playwright" \
        '{"command":"npx","args":["-y","@playwright/mcp"]}'

    # Token-gated MCPs — fill in the keys after first run.
    local linear_key=""
    local linear_config
    linear_config="$(jq -n \
        --arg key "$linear_key" \
        '{command:"npx",args:["-y","linear-mcp-server"],env:{LINEAR_API_KEY:$key}}')"
    try_add_mcp_all "linear" "$linear_config"
    [[ -z "$linear_key" ]] && log_warn "Linear MCP: set LINEAR_API_KEY in $CLAUDE_JSON (https://linear.app/settings/api)"

    local notion_key=""
    local notion_config
    notion_config="$(jq -n \
        --arg key "$notion_key" \
        '{command:"npx",args:["-y","@notionhq/notion-mcp-server"],env:{NOTION_TOKEN:$key}}')"
    try_add_mcp_all "notion" "$notion_config"
    [[ -z "$notion_key" ]] && log_warn "Notion MCP: set NOTION_TOKEN in $CLAUDE_JSON (https://www.notion.so/profile/integrations)"

    local miro_key=""
    local miro_config
    miro_config="$(jq -n \
        --arg key "$miro_key" \
        '{command:"npx",args:["-y","@k-jarzyna/mcp-miro"],env:{MIRO_ACCESS_TOKEN:$key}}')"
    try_add_mcp_all "miro" "$miro_config"
    [[ -z "$miro_key" ]] && log_warn "Miro MCP: set MIRO_ACCESS_TOKEN in $CLAUDE_JSON (https://miro.com/app/settings/user-profile/apps)"

    log_success "MCP configuration written to:"
    log_success "  $CLAUDE_JSON"
    log_success "  $CODEX_JSON"
}

if should_skip_step AGENTS; then
    log_info "Skipping agents (MACSETUP_SKIP_AGENTS is set)."
    exit 0
fi

configure_mcps
