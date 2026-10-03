---
name: golang-patterns
description: Idiomatic Go patterns, best practices, and conventions for building robust, efficient, and maintainable Go applications. Includes Go-specific code review workflow. Use when writing, reviewing, or refactoring Go code, or when invoked as `/go-review`.
model: sonnet
---

[共通本文](shared/instructions.md) を読み、手順に従う。本文中の参考資料は `shared/` を基準に解決する。

## Claude Codeでの委譲

詳細レビューは `go-reviewer` agent に委譲する。共通本文のレビューカテゴリ・判定基準に従って報告させる。
