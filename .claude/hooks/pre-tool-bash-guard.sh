#!/usr/bin/env bash
# PreToolUse(Bash): block destructive IaC / k8s commands, and writes to files
# that pre-tool-edit-guard.sh protects. The latter only sees Edit|Write|MultiEdit,
# so `sed -i` / `>` / `tee` from this tool would otherwise bypass it entirely.
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

# Same protected set as pre-tool-edit-guard.sh. Keep the two in sync.
check_target() {
  case "$1" in
    *.tfstate|*.tfstate.backup|*/terraform.tfstate.d/*)
      block "Terraform state files are managed by terraform CLI. Direct writes cause drift and corruption." ;;
    *.env|*.env.*|.envrc)
      block "Environment / secret files must not be modified by the agent." ;;
  esac
}

# Drop heredoc bodies first. Their content is data, not commands, so scanning it
# for redirections misreads prose (a PR body quoting `> .env`, say) as a write.
# The line carrying the `<<` is kept, so `cat > .env <<EOF` is still caught.
cmd="$(printf '%s\n' "$cmd" | awk '
{
  if (d != "") { if ($0 == d || $1 == d) d = ""; next }
  if (match($0, /<<-?[ \t]*[\047"]?[A-Za-z_][A-Za-z0-9_]*[\047"]?/)) {
    t = substr($0, RSTART, RLENGTH)
    sub(/^<<-?[ \t]*/, "", t)
    gsub(/[\047"]/, "", t)
    d = t
  }
  print
}')"

segments="$(printf '%s' "$cmd" | sed -E 's/(\|\|?|&&|;)/\n/g')"

while IFS= read -r seg; do
  set -- $seg
  first="${1:-}"
  second="${2:-}"
  third="${3:-}"

  # Redirection targets (`> f`, `>>f`), plus every token of an in-place sed or
  # a tee, which are the write vectors this tool actually reaches for.
  targets="$(printf '%s' "$seg" | grep -oE '>>?[[:space:]]*[^[:space:]|;&<>]+' | sed -E 's/^>>?[[:space:]]*//' || true)"
  case "$first" in
    tee)
      targets="$targets
$seg" ;;
    sed)
      printf '%s' "$seg" | grep -qE '(^|[[:space:]])-i' && targets="$targets
$seg" ;;
  esac
  for target in $targets; do
    check_target "$target"
  done

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
