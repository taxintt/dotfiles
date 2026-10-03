# Verification Loop Skill

コード変更後の包括的な検証手順。

## 使うタイミング

以下の場面でこの skill を起動する:
- 機能実装や大きなコード変更の完了後
- PR 作成の直前
- commit 前の品質ゲート
- 品質ゲートの通過を確認したいとき
- リファクタリングの直後
- ユーザーが明示的に `verification-loop` と呼んだとき

## Modes

引数で実行する Phase を絞れる:

| モード | 実行 Phase | 用途 |
|---|---|---|
| `quick` | 1, 2 | 変更後の即時チェック |
| `full`（デフォルト） | 1-6 すべて | 一般的な包括検証 |
| `pre-commit` | 1, 2, 3, 5, 6 | コミット直前（テスト除く） |
| `pre-pr` | 1-6 + git status | PR 作成直前の完全検証 |

## Verification Phases

各 Phase には **PASS/FAIL 判定基準** がある。検証コマンドはパイプで出力を切り詰めずに実行し、元コマンドの終了コードとstdout / stderr全体を確認する。表示だけを要約して、元の終了コードを別のコマンドの終了コードで置き換えない。コマンド例は stack 既定 (TS / Python) で、他 stack では**同等コマンドに置換**する（例は Phase 末尾の Stack Adaptation 節）。

### Phase 1: Build Verification `[critical]`
```bash
npm run build   # or: pnpm build
```
**PASS/FAIL**: exit code 0 かつ stderr に `Error:` が含まれない → PASS。FAIL なら **STOP して fix** し全 phase やり直し。

### Phase 2: Type Check `[critical]`
```bash
npx tsc --noEmit   # TS
pyright .           # Python
```
**PASS/FAIL**: exit code 0 かつ errors = 0 → PASS。それ以外は FAIL。warnings はエラー数にカウントしない。

### Phase 3: Lint Check
```bash
npm run lint   # JS/TS
ruff check .   # Python
```
**PASS/FAIL**: exit code 0 かつ errors = 0 → PASS（warnings のみなら PASS だが Issues to Fix に載せる）。それ以外は FAIL。

### Phase 4: Test Suite `[critical]`
```bash
npm run test -- --coverage
```
**PASS/FAIL**: exit code 0 **かつ** failed = 0 **かつ** coverage >= 80% → PASS。いずれか欠けたら FAIL。Report:
- Total tests: X / Passed: X / Failed: X / Coverage: X%

### Phase 5: Security & Debug Statement Scan
```bash
# Secrets: 値を表示せず、該当ファイル名だけを確認
rg -l 'sk-|api_key|AKIA[0-9A-Z]{16}' -g '*.ts' -g '*.js' .

# Debug statements（言語別）
rg -n 'console\.log|console\.debug' -g '*.ts' -g '*.tsx' -g '*.js' -g '*.jsx' src/   # JS/TS
rg -n 'fmt\.Println|log\.Println' -g '*.go' .   # Go (log パッケージ運用例外を除く)
rg -n '^\s*print\(' -g '*.py' .                # Python

# 秘匿ファイル (.env / credentials.json / id_rsa) のstaging有無を一覧から確認
git diff --cached --name-only
```
`rg` の終了コードは 0 = 検出、1 = 検出なし、2以上 = 走査失敗。検出なしは正常だが、走査失敗やgitコマンドの失敗はPhase 5をFAILとする。出力を切り詰めず全件確認し、secretの値はレポートに載せない。
**PASS/FAIL**: secret 系 hit = 0 **かつ** 秘匿ファイル staged = 0 → PASS。debug 文は warnings 扱いで Issues to Fix へ（test ファイルは除外可）。人間判定が必要な誤検出は除外可（理由を Report に記載）。

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

Security scan の `rg` 拡張子も stack に合わせて置換（Go: `*.go`, Rust: `*.rs` 等）。

## Overall 判定アルゴリズム

最終判定 `READY` / `NOT READY`:

- **NOT READY** if 実行対象のPhase 1〜5のいずれかがFAIL。lintエラー・secret検出・秘匿ファイルのstagingも通過扱いにしない。
- **READY with warnings** if 実行対象がすべてPASSで、lint warning・debug文・Diff Reviewの指摘がある → Issues to Fixに列挙の上、ユーザー判断。
- **READY** if 実行対象がすべてPASSで、warningsなし。

選択したmodeで対象外のPhaseはSKIPと表示する。READYは選択したmodeについての判定であり、quick / pre-commitの結果をfull / pre-prの検証済みとして報告しない。実行対象を実行できなかった場合はFAILとし、成功扱いにしない。Stack Adaptationで適用外とされる処理はSKIPとし、その理由を記載する。

## 出力フォーマット

選択したmodeの実行後、以下の検証レポートを生成する:

```
VERIFICATION REPORT
==================

Mode:      [quick/full/pre-commit/pre-pr]
Build:     [PASS/FAIL/SKIP]
Types:     [PASS/FAIL/SKIP] (X errors)
Lint:      [PASS/FAIL/SKIP] (X warnings)
Tests:     [PASS/FAIL/SKIP] (X/Y passed, Z% coverage)
Security:  [PASS/FAIL/SKIP] (X issues)
Diff:      [X files changed]

Overall:   [READY/READY with warnings/NOT READY] for selected mode

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
```

各チェックポイントで、mode に応じて `quick` → `full` → `pre-pr` と段階を上げていく。
