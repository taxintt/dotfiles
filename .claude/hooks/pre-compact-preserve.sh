#!/usr/bin/env bash
# PreCompact: inject session-critical context (ADR list, progress files, git state)
# into additionalContext so it survives auto-compaction.

set -uo pipefail

input="$(cat || true)"
cwd="$(printf '%s' "$input" | jq -r '.cwd // empty' 2>/dev/null || true)"
[ -z "$cwd" ] && cwd="$PWD"
cd "$cwd" 2>/dev/null || exit 0

parts=""

if [ -d "docs/adr" ]; then
  adr_list="$(find docs/adr -maxdepth 2 -type f -name '*.md' 2>/dev/null | sort | head -30 | while IFS= read -r f; do
    title="$(grep -m1 -E '^#\s' "$f" 2>/dev/null | sed 's/^#\s*//' || true)"
    printf -- "- %s — %s\n" "$f" "${title:-(no title)}"
  done)"
  [ -n "$adr_list" ] && parts="${parts}
## ADRs in repo
${adr_list}"
fi

for f in PROGRESS.md TODO.md NEXT.md; do
  if [ -f "$f" ]; then
    parts="${parts}
## $f (truncated to 1KB)
$(head -c 1024 "$f")"
  fi
done

if command -v git >/dev/null 2>&1 && git rev-parse --git-dir >/dev/null 2>&1; then
  branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo unknown)"
  status="$(git status --short 2>/dev/null | head -30 || true)"
  parts="${parts}
## Git state
branch: ${branch}
status:
${status:-(clean)}"
fi

if [ -z "$parts" ]; then
  exit 0
fi

jq -Rn --arg msg "Session checkpoint preserved across compaction:${parts}" '{
  hookSpecificOutput: {
    hookEventName: "PreCompact",
    additionalContext: $msg
  }
}'
exit 0
