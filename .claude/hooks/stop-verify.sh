#!/usr/bin/env bash
# Stop hook: block completion until repo-level tests/validation pass.
# CRITICAL: stop_hook_active early-return must be the very first check (prevents infinite loop).

set -uo pipefail

input="$(cat || true)"
[ -z "$input" ] && exit 0

active="$(printf '%s' "$input" | jq -r '.stop_hook_active // false' 2>/dev/null || echo "false")"
if [ "$active" = "true" ]; then
  exit 0
fi

cwd="$(printf '%s' "$input" | jq -r '.cwd // empty' 2>/dev/null || true)"
[ -z "$cwd" ] && cwd="$PWD"
cd "$cwd" 2>/dev/null || exit 0

block() {
  local reason="$1"
  jq -Rn --arg r "$reason" '{decision:"block", reason:$r}'
  exit 0
}

failures=""

if [ -f "go.mod" ] && command -v go >/dev/null 2>&1; then
  out="$(timeout 60 go test ./... -count=1 -timeout=45s -short 2>&1 || true)"
  if printf '%s' "$out" | grep -qE '^(FAIL|---\s*FAIL)'; then
    failures="${failures}
== Go tests failed ==
$(printf '%s' "$out" | grep -E '^(FAIL|---\s*FAIL|\s+.*\.go:[0-9]+)' | head -30)"
  fi
fi

tf_dirs="$(find . -maxdepth 4 -name '*.tf' -not -path './.terraform/*' -not -path '*/_archive/*' 2>/dev/null | xargs -I{} dirname {} | sort -u | head -10)"
if [ -n "$tf_dirs" ] && command -v terraform >/dev/null 2>&1; then
  while IFS= read -r d; do
    [ -d "$d/.terraform" ] || continue
    out="$(cd "$d" && timeout 20 terraform validate 2>&1 || true)"
    if printf '%s' "$out" | grep -qE '(Error:|Errors:)'; then
      # "Module source has changed" は terraform init が必要な状態なのでブロックしない
      if ! printf '%s' "$out" | grep -qF 'Module source has changed'; then
        failures="${failures}
== terraform validate failed in $d ==
$(printf '%s' "$out" | head -20)"
      fi
    fi
  done <<< "$tf_dirs"
fi

if [ -n "$failures" ]; then
  block "Completion blocked by Stop hook — fix the following before declaring done:
$failures

FIX: Address each failure, then signal completion again. The harness will re-verify."
fi

exit 0
