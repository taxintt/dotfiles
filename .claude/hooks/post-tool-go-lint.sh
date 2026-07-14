#!/usr/bin/env bash
# PostToolUse(Edit|Write|MultiEdit): auto gofmt + golangci-lint feedback for *.go.
# Failures inject `hookSpecificOutput.additionalContext` so Claude self-corrects.

set -uo pipefail

input="$(cat || true)"
[ -z "$input" ] && exit 0

JQ=$(command -v gojq 2>/dev/null || command -v jq)
file="$(printf '%s' "$input" | $JQ -r '.tool_input.file_path // .tool_input.path // empty' 2>/dev/null || true)"
case "$file" in
  *.go) ;;
  *)    exit 0 ;;
esac
[ -f "$file" ] || exit 0

emit() {
  local msg="$1"
  $JQ -Rn --arg msg "$msg" '{
    hookSpecificOutput: {
      hookEventName: "PostToolUse",
      additionalContext: $msg
    }
  }'
  exit 0
}

if command -v gofmt >/dev/null 2>&1; then
  diff="$(gofmt -d "$file" 2>/dev/null || true)"
  if [ -n "$diff" ]; then
    emit "ERROR: gofmt violation in $file
WHY:   Go source must be canonically formatted before commit.
FIX:   Run: gofmt -w \"$file\"
EXAMPLE diff (first 30 lines):
$(printf '%s' "$diff" | head -30)"
  fi
fi

if command -v golangci-lint >/dev/null 2>&1; then
  export GOLANGCI_LINT_CACHE="${TMPDIR:-/tmp}/golangci-cache"
  out="$(timeout 12 golangci-lint run --fast --path-mode=abs --timeout=10s --out-format=line-number "$file" 2>&1 || true)"
  if [ -n "$out" ] && printf '%s' "$out" | grep -qE ':[0-9]+:[0-9]+:'; then
    emit "ERROR: golangci-lint findings in $file
WHY:   Static analysis caught issues that should be fixed before declaring done.
FIX:   Read findings below and edit the file. Re-run will re-check automatically.
EXAMPLE findings (first 30 lines):
$(printf '%s' "$out" | head -30)"
  fi
fi

exit 0
