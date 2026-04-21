---
description: Go コードをイディオム / 並行安全性 / エラー処理 / セキュリティ観点でレビューする。go-reviewer エージェントを呼び出す
---

# Go Code Review

このコマンドは **go-reviewer** エージェントを呼び出し、Go 固有観点の包括的コードレビューを行う。

## 動作

1. **対象特定**: `git diff`（未コミット + staged）で変更された `.go` ファイルを抽出
2. **静的解析**: `go vet` / `staticcheck` / `golangci-lint` を実行
3. **セキュリティ**: SQL/コマンドインジェクション、race condition、ハードコード credentials
4. **並行性**: goroutine リーク、チャネル運用、mutex 保護
5. **イディオム**: Go 標準規約との整合
6. **レポート生成**: 重篤度別に分類

## 使うタイミング

- Go コードを書いた / 変更した直後
- Go 変更を commit する前
- Go コードを含む PR をレビューするとき

## レビューカテゴリ

### CRITICAL (必須修正)
- SQL / コマンドインジェクション
- 同期無しの race condition
- goroutine リーク
- ハードコードされた credentials
- unsafe ポインタの誤用
- 重要経路でのエラー黙殺

### HIGH (修正推奨)
- `fmt.Errorf("...: %w", err)` 等でラップされていないエラー
- `panic` で済ませて return していない
- context の非伝搬
- unbuffered channel によるデッドロック
- インターフェース未実装
- mutex 保護漏れ

### MEDIUM (検討)
- 非イディオムなパターン
- エクスポート関数の godoc コメント欠如
- 非効率な文字列結合
- slice の preallocate 未実施
- table-driven tests 未使用

## 自動チェック

```bash
go vet ./...
staticcheck ./...       # あれば
golangci-lint run       # あれば
go build -race ./...
govulncheck ./...       # あれば（依存脆弱性）
```

## 出力フォーマット

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

## 判定基準

| Status   | 条件 |
|----------|------|
| Approve  | CRITICAL / HIGH 共になし |
| Warning  | MEDIUM のみ（注意付きでマージ可） |
| Block    | CRITICAL または HIGH が 1 件以上 |

## 関連

- Agent: `~/.claude/agents/go-reviewer.md`
- Skills: `~/.claude/skills/golang-patterns/` / `~/.claude/skills/golang-testing/`
- Commands: Go 以外は `/code-review`、事前に `/go-tdd` や `/go-build`
