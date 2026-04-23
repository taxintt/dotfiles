---
name: golang-patterns
description: Idiomatic Go patterns, best practices, and conventions for building robust, efficient, and maintainable Go applications. Includes Go-specific code review workflow. Use when writing, reviewing, or refactoring Go code, or when invoked as `/go-review`.
---

# Go Development Patterns

Idiomatic Go patterns and best practices for building robust, efficient, and maintainable applications.

## When to Activate

- Writing new Go code
- Reviewing Go code（including invoked as `/go-review`）
- Refactoring existing Go code
- Designing Go packages/modules

## Core Principles

1. **Simplicity and Clarity** - Go favors simplicity over cleverness. Code should be obvious and easy to read.
2. **Make the Zero Value Useful** - Design types so their zero value is immediately usable without initialization.
3. **Accept Interfaces, Return Structs** - Functions should accept interface parameters and return concrete types.
4. **Errors are Values** - Treat errors as first-class values, not exceptions.
5. **Return Early** - Handle errors first, keep happy path unindented.

## Quick Reference: Go Idioms

| Idiom | Description |
|-------|-------------|
| Accept interfaces, return structs | Functions accept interface params, return concrete types |
| Errors are values | Treat errors as first-class values, not exceptions |
| Don't communicate by sharing memory | Use channels for coordination between goroutines |
| Make the zero value useful | Types should work without explicit initialization |
| A little copying is better than a little dependency | Avoid unnecessary external dependencies |
| Clear is better than clever | Prioritize readability over cleverness |
| gofmt is no one's favorite but everyone's friend | Always format with gofmt/goimports |
| Return early | Handle errors first, keep happy path unindented |

## Detailed Pattern References

For detailed code examples and patterns, read the corresponding reference file:

- `error-handling.md` - Error wrapping, custom error types, errors.Is/As
- `concurrency.md` - Worker pools, context, graceful shutdown, errgroup
- `interfaces.md` - Small interfaces, consumer-side definition, type assertions
- `performance.md` - Slice preallocation, sync.Pool, string building, package organization

## Review Workflow

Go コードレビュー時に使う手順。`go-reviewer` agent に委譲するのが基本だが、観点と判定基準はここで統一する。

### 対象特定

```bash
git diff --name-only   # 未コミット変更
git diff --staged --name-only
```

`.go` ファイルのみを抽出して review 対象とする。

### 静的解析（必須）

```bash
go vet ./...
staticcheck ./...              # あれば
golangci-lint run              # あれば
go build -race ./...
govulncheck ./...              # あれば（依存脆弱性）
```

### レビューカテゴリ

#### CRITICAL（必須修正）
- SQL / コマンドインジェクション
- 同期無しの race condition
- goroutine リーク
- ハードコードされた credentials
- unsafe ポインタの誤用
- 重要経路でのエラー黙殺

#### HIGH（修正推奨）
- `fmt.Errorf("...: %w", err)` 等でラップされていないエラー
- `panic` で済ませて return していない
- context の非伝搬
- unbuffered channel によるデッドロック
- インターフェース未実装
- mutex 保護漏れ

#### MEDIUM（検討）
- 非イディオムなパターン
- エクスポート関数の godoc コメント欠如
- 非効率な文字列結合
- slice の preallocate 未実施
- table-driven tests 未使用

### 判定基準

| Status | 条件 |
|---|---|
| **Approve** | CRITICAL / HIGH 共になし |
| **Warning** | MEDIUM のみ（注意付きでマージ可） |
| **Block** | CRITICAL または HIGH が 1 件以上 |

### 出力フォーマット

```text
# Go Code Review Report

## Files Reviewed
- <path 1>
- <path 2>

## Static Analysis
- go vet: OK / N 件
- staticcheck: OK / N 件

## Issues Found
[CRITICAL] <要約>
- File: <path:line>
- Issue: <詳細>
- Fix: <最小修正案>

[HIGH] ...
[MEDIUM] ...

## Summary
- CRITICAL: N / HIGH: N / MEDIUM: N
- Recommendation: Approve / Warning / Block
```

### agent 委譲

詳細レビューは `go-reviewer` agent に委譲する。agent は本 skill の Review カテゴリ / 判定基準に従って report を返す。`golang-testing` skill の内容（table-driven, race detection 等）もレビュー観点として参照する。
