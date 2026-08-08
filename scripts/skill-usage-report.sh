#!/usr/bin/env bash
# Skill 利用状況レポート: 既存 transcript から skill 発火を遡及集計する。
# 発火は 2 経路ある。両方を数えないと「削除候補」を誤検出する:
#   A) tool_use(name=Skill) の .input.skill … auto/合成発火 (skill ディレクトリ名)
#   B) メッセージ内 <command-name>/xxx</command-name> … 手動 /slash 発火 (別名の場合あり)
# B の /slash 別名は各 SKILL.md frontmatter の description 内 `/xxx` から解決する
# (本文を走査すると他 skill の相互参照を誤って拾うため frontmatter のみ)。
# read only・hook 不要。
set -uo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.."; pwd)"
JQ="$(command -v gojq 2>/dev/null || command -v jq)"
skills_dir="$REPO_DIR/.claude/skills"
proj="$HOME/.claude/projects"

[ -n "$JQ" ] || { echo "gojq/jq not found" >&2; exit 1; }
[ -d "$skills_dir" ] || { echo "no skills dir: $skills_dir" >&2; exit 1; }
[ -d "$proj" ] || { echo "no transcripts: $proj"; exit 0; }

# --- alias→dir マップ (self-alias + frontmatter description の /slash) ---
# 1 行 = "<alias>\t<dir>"。1 別名が複数 dir を指す場合あり(例 /go-tdd)。
mapfile="$(mktemp)"
trap 'rm -f "$mapfile"' EXIT
for d in "$skills_dir"/*/; do
  name="$(basename "$d")"
  [ -f "$d/SKILL.md" ] || continue
  printf '%s\t%s\n' "$name" "$name"   # dir 名自体も /slash になりうる
  awk '/^---[[:space:]]*$/{c++; if(c==2) exit} c>=1' "$d/SKILL.md" \
    | grep -oE '/[a-zA-Z][a-zA-Z0-9-]*' | sed 's#^/##' \
    | while IFS= read -r a; do printf '%s\t%s\n' "$a" "$name"; done
done | sort -u >"$mapfile"   # 同一 alias→dir の重複行を畳む(自己別名 == frontmatter 別名の二重計上防止)

# --- 経路 A: Skill tool_use (既に dir 名。plugin: 接頭辞を除去) ---
pathA="$(find "$proj" -name '*.jsonl' -print0 | xargs -0 cat 2>/dev/null \
  | "$JQ" -r 'select((.message.content?|type)=="array") | .message.content[]
      | select(.type=="tool_use" and .name=="Skill") | .input.skill // empty' 2>/dev/null \
  | sed 's/^plugin://; /^$/d')"

# --- 経路 B: <command-name>/xxx</command-name> の slash 名 ---
pathB="$(find "$proj" -name '*.jsonl' -print0 | xargs -0 cat 2>/dev/null \
  | "$JQ" -r '.. | strings | select(test("<command-name>"))' 2>/dev/null \
  | grep -oE '<command-name>[^<]+</command-name>' \
  | sed -E 's#</?command-name>##g; s#^/##; /^$/d')"

# --- B を alias→dir へ解決。未解決 slash は UNMAPPED として温存(取りこぼし可視化) ---
resolvedB="$(printf '%s\n' "$pathB" | sed '/^$/d' | awk -F'\t' -v mf="$mapfile" '
  BEGIN { while ((getline line < mf) > 0) {
            split(line, p, "\t"); m[p[1]] = m[p[1]] (m[p[1]] ? "\t" : "") p[2] } }
  { if ($0 in m) { n = split(m[$0], a, "\t"); for (i = 1; i <= n; i++) print a[i] }
    else print "UNMAPPED:" $0 }')"

# 解決済み dir 名の全集合(A + 解決済み B)。UNMAPPED は集計から除外し末尾で別掲。
resolved="$(printf '%s\n%s\n' "$pathA" "$resolvedB" | sed '/^$/d' | grep -v '^UNMAPPED:' || true)"

echo "== skill 発火頻度 (多い順) =="
if [ -n "$resolved" ]; then
  printf '%s\n' "$resolved" | sort | uniq -c | sort -rn
else
  echo "(発火記録なし)"
fi

echo
echo "== 発火 0 回 (削除候補・要人間判断) =="
comm -23 \
  <(find "$skills_dir" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort -u) \
  <(printf '%s\n' "$resolved" | sort -u)

unmapped="$(printf '%s\n' "$resolvedB" | grep '^UNMAPPED:' | sort | uniq -c | sort -rn || true)"
if [ -n "$unmapped" ]; then
  echo
  echo "== 未解決 /slash (skill 外・builtin/plugin の可能性。集計対象外) =="
  printf '%s\n' "$unmapped"
fi
