#!/usr/bin/env bash
# PostToolUse(Edit|Write|MultiEdit): auto terraform fmt + tflint feedback for *.tf / *.tfvars.

set -uo pipefail

input="$(cat || true)"
[ -z "$input" ] && exit 0

file="$(printf '%s' "$input" | jq -r '.tool_input.file_path // .tool_input.path // empty' 2>/dev/null || true)"
case "$file" in
  *.tf|*.tfvars) ;;
  *)             exit 0 ;;
esac
[ -f "$file" ] || exit 0

emit() {
  local msg="$1"
  jq -Rn --arg msg "$msg" '{
    hookSpecificOutput: {
      hookEventName: "PostToolUse",
      additionalContext: $msg
    }
  }'
  exit 0
}

if command -v terraform >/dev/null 2>&1; then
  diff="$(terraform fmt -check -diff "$file" 2>&1 || true)"
  if [ -n "$diff" ] && printf '%s' "$diff" | grep -qE '^[+-]'; then
    emit "ERROR: terraform fmt violation in $file
WHY:   Terraform source must be canonically formatted.
FIX:   Run: terraform fmt -recursive \$(dirname \"$file\")
EXAMPLE diff (first 30 lines):
$(printf '%s' "$diff" | head -30)"
  fi
fi

if command -v tflint >/dev/null 2>&1; then
  dir="$(dirname "$file")"
  out="$(timeout 12 tflint --chdir="$dir" --format=compact 2>&1 || true)"
  if [ -n "$out" ] && printf '%s' "$out" | grep -qE ':[0-9]+:'; then
    emit "ERROR: tflint findings in $file
WHY:   tflint caught issues that should be fixed before declaring done.
FIX:   Read findings below and edit the file. tflint can fix some via: tflint --fix
EXAMPLE findings (first 30 lines):
$(printf '%s' "$out" | head -30)"
  fi
fi

exit 0
