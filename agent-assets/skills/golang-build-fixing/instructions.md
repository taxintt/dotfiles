# Go Build Fixing Skill

Go のビルド・静的解析エラーを段階的 / 最小侵襲で修正する。

## 発火タイミング

- `go build ./...` が失敗
- `go vet ./...` / `staticcheck` / `golangci-lint` が警告を出す
- モジュール依存が壊れている
- 変更を pull したあとビルドが通らない
- ユーザーが明示的に `golang-build-fixing` と呼んだとき

## 動作

1. **診断実行**（利用可能なもの順）
   ```bash
   go build ./...
   go vet ./...
   staticcheck ./...       # あれば
   golangci-lint run       # あれば
   go mod verify
   go mod tidy -v
   ```

2. **エラー分類**: ファイルごとにグループ化、重篤度順にソート
3. **1 件ずつ修正**: 修正 → 再ビルド → 次のエラーへ
4. **サマリ報告**: 修正済み / 残件 / 変更ファイル数

## 停止条件

以下の場合は停止し、残件と理由を報告する:

- 同じエラーが3回の修正試行後も残る
- 修正が解消した数より多くのエラーを追加する
- 依頼範囲を超えるアーキテクチャ変更が必要
- 循環依存の解消にパッケージ再構成が必要
- 外部依存の手動インストールが必要

## 修正戦略（順序厳守）

1. Build エラー → コンパイルを通す
2. Vet 警告 → 疑わしい構文を直す
3. Lint 警告 → スタイル / ベストプラクティス
4. **1 件ずつ検証、refactor は絶対に入れない**

## 典型的修正

| エラー | 典型的な修正 |
|---|---|
| `undefined: X` | import 追加 / typo 修正 |
| `cannot use X as Y` | 型変換または代入の修正 |
| `missing return` | return 文の追加 |
| `X does not implement Y` | メソッド追加 |
| `import cycle` | パッケージ再構成 |
| `declared but not used` | 変数の削除または使用 |
| `cannot find package` | `go get` または `go mod tidy` |

## Iron Law: 最小修正

**一度に複数エラーを直さない。refactor を混ぜない**。

### 典型的な rationalization とその対処

| Rationalization | 対処 |
|---|---|
| 「まとめて直せば速い」 | 因果が追えなくなる。1 件ずつ |
| 「refactor ついでに」 | 本 skill のスコープ外。別 skill で |
| 「似た箇所もついでに」 | 似た箇所が本当に同じ根本原因か確認してから |

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

## 関連

- Patterns: `golang-patterns` skill
- Tests: `golang-testing` skill（修正後の test 実行）
