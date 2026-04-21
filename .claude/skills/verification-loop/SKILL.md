---
name: verification-loop
description: PR 作成前にビルド / 型チェック / lint / テスト / セキュリティを網羅的に検証するシステム
---

# Verification Loop Skill

Claude Code セッション向けの包括的な検証システム。

## 使うタイミング

以下の場面でこの skill を起動する:
- 機能実装や大きなコード変更の完了後
- PR 作成の直前
- 品質ゲートの通過を確認したいとき
- リファクタリングの直後

## Verification Phases

各 Phase には **PASS/FAIL 判定基準** がある。コマンド例は stack 既定 (TS / Python) で、他 stack では**同等コマンドに置換**する（例は Phase 末尾の Stack Adaptation 節）。

### Phase 1: Build Verification `[critical]`
```bash
npm run build 2>&1 | tail -20   # or: pnpm build
```
**PASS/FAIL**: exit code 0 かつ stderr に `Error:` が含まれない → PASS。FAIL なら **STOP して fix** し全 phase やり直し。

### Phase 2: Type Check `[critical]`
```bash
npx tsc --noEmit 2>&1 | head -30   # TS
pyright . 2>&1 | head -30           # Python
```
**PASS/FAIL**: errors = 0 → PASS、errors > 0 → FAIL。warnings はカウントしない。

### Phase 3: Lint Check
```bash
npm run lint 2>&1 | head -30   # JS/TS
ruff check . 2>&1 | head -30   # Python
```
**PASS/FAIL**: errors = 0 → PASS（warnings のみなら PASS だが Issues to Fix に載せる）。errors > 0 → FAIL。

### Phase 4: Test Suite `[critical]`
```bash
npm run test -- --coverage 2>&1 | tail -50
```
**PASS/FAIL**: failed = 0 **かつ** coverage >= 80% → PASS。いずれか欠けたら FAIL。Report:
- Total tests: X / Passed: X / Failed: X / Coverage: X%

### Phase 5: Security Scan
```bash
grep -rn "sk-\|api_key\|AKIA[0-9A-Z]\{16\}" --include="*.ts" --include="*.js" . 2>/dev/null | head -10
grep -rn "console.log" --include="*.ts" --include="*.tsx" src/ 2>/dev/null | head -10
```
**PASS/FAIL**: secret 系 hit = 0 → PASS。`console.log` は warnings 扱いで Issues to Fix へ。人間判定が必要な誤検出は除外可（理由を Report に記載）。

### Phase 6: Diff Review
```bash
git diff --stat
git diff HEAD~1 --name-only
```
**PASS/FAIL なし**（informational phase）。変更ファイルごとに「意図しない変更 / エラーハンドリング欠落 / edge case 未考慮」を目視で確認し、気になる点は Issues to Fix に載せる。

### Stack Adaptation

skill のコマンドは TS / Python 前提。他 stack では同等に置換する:

| Stack | Phase 1 (Build) | Phase 2 (Types) | Phase 3 (Lint) | Phase 4 (Tests) |
|---|---|---|---|---|
| **Go** | `go build ./...` | `go vet ./...` (型検査は build に統合、意味検査として vet を使用) | `golangci-lint run ./...` | `go test ./... -cover -race` |
| **Rust** | `cargo build` | `cargo check` | `cargo clippy --all-targets -- -D warnings` | `cargo test -- --nocapture` |
| **Python** | `python -m build` or n/a | `pyright .` or `mypy .` | `ruff check .` | `pytest --cov` |

Security scan の `grep` 拡張子も stack に合わせて置換（Go: `*.go`, Rust: `*.rs` 等）。

## Overall 判定アルゴリズム

最終判定 `READY` / `NOT READY`:

- **NOT READY** if any `[critical]` phase = FAIL（Phase 1 / Phase 2 / Phase 4）
- **READY with warnings** if all `[critical]` phases PASS but Phase 3 / Phase 5 に警告あり → Issues to Fix に列挙の上、ユーザー判断
- **READY** if 全 `[critical]` phase PASS かつ warnings なし

## 出力フォーマット

全 phase 実行後、以下の検証レポートを生成する:

```
VERIFICATION REPORT
==================

Build:     [PASS/FAIL]
Types:     [PASS/FAIL] (X errors)
Lint:      [PASS/FAIL] (X warnings)
Tests:     [PASS/FAIL] (X/Y passed, Z% coverage)
Security:  [PASS/FAIL] (X issues)
Diff:      [X files changed]

Overall:   [READY/NOT READY] for PR

Issues to Fix:
1. ...
2. ...
```

## 継続モード

長時間セッションでは、15 分ごと、または大きな変更のたびに検証を走らせる:

```markdown
以下の節目でチェックポイントを取る:
- 各関数の完成時
- 各コンポーネントの完成時
- 次タスクに進む前

実行: /verify
```

## Hook との統合

この skill は PostToolUse hook を補完するが、より深い検証を提供する。
hook は即時に問題を捕捉し、この skill は包括的なレビューを行う。
