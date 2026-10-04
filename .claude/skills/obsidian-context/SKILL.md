---
name: obsidian-context
description: Search Obsidian vault for relevant notes and inject them into context. Use when the user asks about topics that might be documented in their notes, when implementing features that may have design docs, or when you need domain knowledge that could be in their vault.
model: haiku
---

[共通本文](shared/instructions.md) を読み、手順に従う。本文中の参考資料は shared/ を基準に解決する。

## Claude Codeでの連携

検索結果は次の動的コンテキストで取得済み。共通本文の検索スクリプトを重ねて実行せず、この出力を使う。

!`~/.claude/skills/obsidian-context/shared/scripts/search-vault.sh $ARGUMENTS`
