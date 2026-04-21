---
description: 現在のコードベースに対してビルド / 型 / lint / テスト / シークレット / デバッグ文 / git 状態を順次検証する
argument-hint: "[quick|full|pre-commit|pre-pr]"
---

# Verification Command

PR / commit 前に、現プロジェクトの状態を順次検証する。

## 引数（モード）

- `quick`: 1, 2 のみ
- `full`（デフォルト）: 1-7 すべて
- `pre-commit`: 1, 2, 3, 5, 6
- `pre-pr`: full + 7（セキュリティスキャン）

## 手順

1. **Build Check**
   - プロジェクトのビルドコマンドを検出（`package.json` / `Makefile` / `go.mod` 等）
   - 曖昧な場合はユーザーに確認
   - 失敗したらエラーを報告して STOP

2. **Type Check**
   - 言語に応じて: `tsc` / `go vet ./...` / `mypy` など
   - `file:line` でエラーを列挙

3. **Lint Check**
   - 検出した lint コマンド（`eslint` / `golangci-lint` / `ruff` 等）
   - 警告 / エラーを列挙

4. **Test Suite**
   - 検出したテストコマンドを実行
   - pass / fail 数とカバレッジ % を報告

5. **Secret Scan**
   - ソース内の機密値の検出（トークン / パスワード / API key らしき文字列）
   - `.env` / credentials.json など秘匿ファイルが staged になっていないか

6. **Debug Statement Audit**
   - 言語別パターン:
     - JS / TS: `console.log` / `console.debug`
     - Go: `fmt.Println` / `log.Println`（log パッケージ運用の例外を除く）
     - Python: `print`
   - 場所を列挙

7. **Git Status**
   - 未コミットの変更
   - 直近 commit 以降の変更ファイル

## 出力フォーマット

```text
VERIFICATION: PASS / FAIL

Build:    OK / FAIL
Types:    OK / N errors
Lint:     OK / N issues
Tests:    X/Y passed, Z% coverage
Secrets:  OK / N found
Debug:    OK / N occurrences
Git:      <dirty status 要約>

Ready for PR: YES / NO
```

CRITICAL は行ごとに修正候補を添える。
