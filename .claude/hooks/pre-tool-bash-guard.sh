#!/usr/bin/env bash
# PreToolUse(Bash): block destructive IaC / k8s commands.
# Reference: harness-engineering-best-practices-2026 — PreToolUse safety gates.
#
# Token-based check: split the command line on shell separators (; && || |)
# and inspect the first token of each segment. This avoids false positives
# from strings inside quoted arguments (e.g. `git commit -m "terraform apply"`).

set -euo pipefail

input="$(cat || true)"
[ -z "$input" ] && exit 0

cmd="$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null || true)"
[ -z "$cmd" ] && exit 0

block() {
  local reason="$1"
  cat >&2 <<EOF
ERROR: Blocked destructive command by harness PreToolUse guard.
WHY:   $reason
FIX:   Run a plan/dry-run first, get explicit human approval, then execute manually.
EXAMPLE:
  Output the command to the user and wait for confirmation before executing.
EOF
  exit 2
}

segments="$(printf '%s' "$cmd" | sed -E 's/(\|\|?|&&|;)/\n/g')"

while IFS= read -r seg; do
  set -- $seg
  first="${1:-}"
  second="${2:-}"
  third="${3:-}"
  case "$first" in
    terraform)
      case "$second" in
        apply)
          block "terraform apply mutates real infrastructure. Always plan + review first." ;;
        destroy)
          block "terraform destroy deletes infrastructure irreversibly." ;;
        state)
          [ "$third" = "rm" ] && \
            block "terraform state rm desyncs state from real resources; high blast radius." ;;
      esac
      ;;
    kubectl)
      if printf '%s' "$seg" | grep -qE '(^|[[:space:]])delete([[:space:]]+(ns|namespace))([[:space:]]|$)'; then
        block "kubectl delete namespace cascades to all resources within."
      fi
      if printf '%s' "$seg" | grep -qE '(--context[= ](prod|production)|--context[[:space:]]+(prod|production))'; then
        if printf '%s' "$seg" | grep -qE '(^|[[:space:]])(apply|delete|patch|replace|edit)([[:space:]]|$)'; then
          block "kubectl write op against prod context. Use a non-prod context or get explicit approval."
        fi
      fi
      ;;
  esac
done <<< "$segments"

exit 0
