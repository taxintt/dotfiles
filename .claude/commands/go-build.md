---
description: Go のビルド / vet / lint エラーを go-build-resolver エージェントに委譲し、1 件ずつ最小修正する
---

# Go Build and Fix

このコマンドは **go-build-resolver** エージェントを呼び出し、Go のビルド・vet・lint エラーを段階的・最小侵襲で修正する。

## 動作

1. **診断実行**: `go build ./...` / `go vet ./...` / `staticcheck ./...` / `golangci-lint run`（利用可能なもの）
2. **エラー分類**: ファイルごとにグループ化、重篤度順にソート
3. **1 件ずつ修正**: 修正 → 再ビルド → 次のエラーへ
4. **サマリ報告**: 修正済み / 残件 / 変更ファイル数

## 使うタイミング

- `go build ./...` が失敗する
- `go vet ./...` / `staticcheck` / `golangci-lint` が警告を出す
- モジュール依存が壊れている
- 変更を pull したあとビルドが通らない

## 診断コマンド

```bash
go build ./...
go vet ./...
staticcheck ./...      # あれば
golangci-lint run      # あれば
go mod verify
go mod tidy -v
```

## 出力フォーマット

```text
# Go Build Resolution

## 初期診断
<ビルド/vet/lint の出力サマリ、件数>

## Fix 1: <エラー種別>
- File: <path:line>
- Error: <メッセージ>
- Cause: <原因 1 行>
- Change: <最小修正 diff 相当>
- 再ビルド結果: <残件数>

## Fix 2: ...

## 最終検証
- `go vet ./...`: OK / N 件
- `go test ./...`: OK / N 件

## サマリ
- 修正件数 / 変更ファイル数 / 残件
- Build Status: SUCCESS / FAIL
```

## 修正戦略

1. Build エラー → コンパイルを通す
2. Vet 警告 → 疑わしい構文を直す
3. Lint 警告 → スタイル / ベストプラクティス
4. 1 件ずつ検証、リファクタは入れない

## 修正方針の典型

| エラー | 典型的な修正 |
|--------|-------------|
| `undefined: X` | import 追加 / typo 修正 |
| `cannot use X as Y` | 型変換または代入の修正 |
| `missing return` | return 文の追加 |
| `X does not implement Y` | メソッド追加 |
| `import cycle` | パッケージ再構成 |
| `declared but not used` | 変数の削除または使用 |
| `cannot find package` | `go get` または `go mod tidy` |

停止条件や再試行ポリシーは `~/.claude/agents/go-build-resolver.md` を参照。

## 関連

- Agent: `~/.claude/agents/go-build-resolver.md`
- Skill: `~/.claude/skills/golang-patterns/`
- Commands: `/go-tdd` / `/go-review` / `/verify`
