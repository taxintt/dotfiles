#!/usr/bin/env bash
# PreToolUse(Edit|Write|MultiEdit): block edits to terraform state and .env files.

set -euo pipefail

input="$(cat || true)"
[ -z "$input" ] && exit 0

file="$(printf '%s' "$input" | jq -r '.tool_input.file_path // .tool_input.path // empty' 2>/dev/null || true)"
[ -z "$file" ] && exit 0

block() {
  local reason="$1"
  cat >&2 <<EOF
ERROR: Blocked edit to protected file: $file
WHY:   $reason
FIX:   Use the proper CLI to mutate this file (e.g. \`terraform state mv\`, \`direnv edit\`)
       or ask the user to edit it manually.
EOF
  exit 2
}

case "$file" in
  *.tfstate|*.tfstate.backup|*/terraform.tfstate.d/*)
    block "Terraform state files are managed by terraform CLI. Direct edits cause drift and corruption." ;;
  *.env|*.env.*|.envrc|*/.env|*/.env.*)
    block "Environment / secret files must not be modified by the agent." ;;
esac

exit 0
