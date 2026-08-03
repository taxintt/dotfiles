#!/usr/bin/env bash
# Skill 利用状況レポート: 既存 transcript から skill 発火を遡及集計する。
# ~/.claude/projects/**/*.jsonl の tool_use(name=Skill)を数え、
# 発火頻度表 + 発火 0 回 skill(削除候補)を出力する。read only・hook 不要。

set -uo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.."; pwd)"
JQ="$(command -v gojq 2>/dev/null || command -v jq)"
skills_dir="$REPO_DIR/.claude/skills"
proj="$HOME/.claude/projects"

[ -n "$JQ" ] || { echo "gojq/jq not found" >&2; exit 1; }
[ -d "$proj" ] || { echo "no transcripts: $proj"; exit 0; }

# transcript(親 + subagents/)を走査し、Skill 発火の skill 名を抽出
used="$(find "$proj" -name '*.jsonl' -print0 \
  | xargs -0 cat 2>/dev/null \
  | "$JQ" -r 'select((.message.content?|type)=="array") | .message.content[]
      | select(.type=="tool_use" and .name=="Skill") | .input.skill // empty' \
  2>/dev/null | sed '/^$/d' | sort)"

echo "== skill 発火頻度 (多い順) =="
if [ -n "$used" ]; then
  printf '%s\n' "$used" | uniq -c | sort -rn
else
  echo "(発火記録なし)"
fi

echo
echo "== 発火 0 回 (削除候補・要人間判断) =="
comm -23 \
  <(find "$skills_dir" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort -u) \
  <(printf '%s\n' "$used" | sort -u)
