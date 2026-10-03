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

検証前にリポジトリの言語・設定・package.jsonのscripts・既存CIを確認し、適用するコマンドを決める。未設定のbuild / type check / lint / testや対象言語のない型チェックは理由付きSKIPとし、存在しないスクリプトを実行しない。設定済みの検証に必要なツールが無い場合や、適用するコマンドが実行に失敗した場合はFAILとする。ツールの不足を理由に検証を黙って省略せず、無断インストールもしない。

### Phase 1: Build Verification `[critical]`
```bash
npm run build   # or: pnpm build
```
**PASS/FAIL**: exit code 0 かつ stderr に `Error:` が含まれない → PASS。FAIL なら **STOP して fix** し全 phase やり直し。

### Phase 2: Type Check `[critical]`
```bash
npx tsc --noEmit   # TS
pyright .           # Python（設定済みの場合のみ。未設定ならSKIP）
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

シークレット検出は[gitleaks](https://github.com/gitleaks/gitleaks)に任せ、独自のrgパターンは使わない。`command -v gitleaks`で利用可否を確認する。未導入ならsecret scanを理由付きSKIPとし、無断インストールしない。この例外はgitleaksに限り、他の設定済み検証のツール不足はFAILのまま。

選択したmodeのコマンドだけを実行する。pre-prではPRのbase repository・remote・branchを確認し、以下のorigin/mainを実際のリモートbase refに置き換える。検証前に `git fetch origin main` でそのrefを更新する。forkのPRではbase repositoryを指すremoteを使う。fetchと `git merge-base origin/main HEAD` の成功を確認してから範囲検査を実行する。取得・基準解決の失敗を空の範囲として通過させずFAILとする。Phase 5と6は同じ更新済みbase refを使う。

```bash
# pre-commit: staged内容。作業ツリーや未追跡ファイルは含めない
gitleaks git --staged --redact=100 --verbose --exit-code=10 .

# pre-pr: PRに含まれる全commit。途中で追加して後で削除したsecretも対象
gitleaks git --log-opts="$(git merge-base origin/main HEAD)..HEAD" --redact=100 --verbose --exit-code=10 .

# full: staged内容の検査（HEAD・作業ツリーの検査は次の手順）
gitleaks git --staged --redact=100 --verbose --exit-code=10 .
```

fullでは全履歴を検査しない。上記のstaged検査に加え、次の2つのスナップショットをそれぞれ `gitleaks dir --redact=100 --verbose --exit-code=10 .` で検査する:

- **HEAD**: `git ls-tree -r -z HEAD`で列挙した通常ファイルのblobを `git cat-file blob <object-id>`で読み、元の相対パスに配置する。履歴のpatchではなくHEADのtreeだけを使う。初回commit前でHEADが無い場合のみ理由付きSKIP。
- **作業ツリー**: `git ls-files -z`で列挙した通常ファイルの現在の内容を元の相対パスに配置する。削除済みファイルはコピーせず、symlinkをたどってリポジトリ外を読み込まない。未追跡ファイルはコピーしない。

一時ディレクトリの作成・配置・スキャン・終了コードの保持・削除は、単一のBash呼び出し内で完結させ、`trap`で失敗時も削除する。呼び出しをまたいでシェル変数を再利用しない。スナップショットをcwdにして実行し、元リポジトリのgitleaks設定を明示する（既存の`.gitleaks.toml`は絶対パスの`--config`、`.gitleaksignore`は`--gitleaks-ignore-path`）。候補の相対パス・行番号・ruleを値を伏せて保持し、後続の確認は元リポジトリの同じ対象（HEADならblob、stagedならindex、作業ツリーなら現在の内容）を使う。配置・走査・削除の失敗はFAILとする。

`gitleaks dir .`を元リポジトリで直接実行しない。gitignoreされた未追跡ファイルも読み込むため、上記のtrackedファイルだけを配置する。fullの未追跡ファイルは対象外として `git ls-files --others --exclude-standard`で列挙し、warningsに記載する。強制stageされたファイルやignore後もtrackedのファイルは検査対象とする。削除済みsecretを含む履歴の検査はpre-prのmerge-base..HEADに限定する。

gitleaksの終了コードは0 = 検出なし、10 = 検出あり、それ以外 = 実行失敗。各コマンドの終了コード・stdout / stderrを確認する。検出・実行失敗・未解決候補はFAIL。既存の`.gitleaks.toml` / `.gitleaksignore`による除外を尊重する。誤検知と確認した場合は理由とfingerprintを報告し、除外設定を変更するならユーザーの依頼範囲で行って再実行する。secretの値は表示せず、ファイル名・行番号・commit・ruleだけを報告する。

```bash
# Debug statements: 作業ツリーの警告。gitignoreを尊重し隠しディレクトリも見る
rg --hidden -g '!.git' -n 'console\.log|console\.debug' -g '*.ts' -g '*.tsx' -g '*.js' -g '*.jsx' .   # JS/TS
rg --hidden -g '!.git' -n 'fmt\.Println|log\.Println' -g '*.go' .   # Go (log パッケージ運用例外を除く)
rg --hidden -g '!.git' -n '^\s*print\(' -g '*.py' .                # Python

# pre-commit / full: 秘匿ファイル (.env / credentials.json / id_rsa) のstaging確認
git diff --cached --name-only --diff-filter=ACMR

# full: 現在trackedの秘匿ファイルも確認（HEADが無い場合はls-filesのみ）
git ls-tree -r --name-only HEAD
git ls-files

# pre-pr: 途中で追加・改名・変更後に削除された秘匿ファイルも確認
git log --format= --name-only --diff-filter=ACMR "$(git merge-base origin/main HEAD)..HEAD"
```

debug scanは作業ツリーの警告として報告し、commit / PR内容の検証済みとは表現しない。`rg`の終了コードは0 = 検出、1 = 検出なし、2以上 = 走査失敗。走査失敗やgitコマンドの失敗、対象範囲に含まれる秘匿ファイルはPhase 5をFAILとする。debug文のみはwarnings扱い（testファイルは理由付きで除外可）。出力を切り詰めず全件確認する。gitleaks未導入時はSecurityをSKIPと表示するが、他のPhase 5チェックに失敗があればFAILを優先する。

### Phase 6: Diff Review
```bash
# pre-commit: staged diffを確認（初回commitでも実行可能）
git diff --cached --stat
git diff --cached

# pre-pr: Phase 5と同じ更新済みリモートbase refを使用
git diff origin/main...HEAD --stat
git diff origin/main...HEAD

# full: HEADからの作業ツリー全体（staged / unstaged）を確認
git diff HEAD --stat
git diff HEAD
```
未追跡ファイルは `git status --short` で確認し、commit / PRに含める予定のファイルも読む。pre-prでは未コミット変更をPR差分に含まれるものとして報告しない。fullでHEADがまだ無い場合はpre-commitの差分と未追跡ファイルを確認する。

**PASS/FAIL なし**（informational phase）。変更ファイルごとに「意図しない変更 / エラーハンドリング欠落 / edge case 未考慮」を目視で確認し、気になる点は Issues to Fix に載せる。

### Stack Adaptation

skill のコマンドは TS / Python 前提。他 stack では同等に置換する:

| Stack | Phase 1 (Build) | Phase 2 (Types) | Phase 3 (Lint) | Phase 4 (Tests) |
|---|---|---|---|---|
| **Go** | `go build ./...` | `go vet ./...` (型検査は build に統合、意味検査として vet を使用) | `golangci-lint run ./...` | `go test ./... -cover -race` |
| **Rust** | `cargo build` | `cargo check` | `cargo clippy --all-targets -- -D warnings` | `cargo test -- --nocapture` |
| **Shell / Markdown** | N/A（build設定なし） | N/A | 設定済みlintと変更したshellの構文チェック | 設定済みのテストのみ。未設定ならN/A |
| **未設定の検証** | build設定なしならN/A | 型チェッカー未設定・対象なしならN/A | lint設定なしならN/A | テスト設定なしならN/A |
| **Python** | `python -m build` or n/a | 設定済みの `pyright .` / `mypy .`。未設定ならN/A | `ruff check .` | `pytest --cov` |

secret scanは言語の拡張子で制限せず、modeごとのGit対象をgitleaksで検査する。debug scanだけリポジトリに存在する言語の拡張子を指定し、存在するリポジトリ直下を対象とする。固定のsrc/を前提にしない。該当言語のファイルが無ければその言語のdebug scanは適用外。

## Overall 判定アルゴリズム

最終判定 `READY` / `NOT READY`:

- **NOT READY** if 実行対象のPhase 1〜5のいずれかがFAIL。lintエラー・secret検出・秘匿ファイルのstagingも通過扱いにしない。
- **READY with warnings** if 適用する検証がすべてPASSで、lint warning・debug文・Diff Reviewの指摘がある → Issues to Fixに列挙の上、ユーザー判断。
- **READY** if 適用する検証がすべてPASSで、warningsなし。gitleaks未導入やfullの未追跡ファイルによる未検証範囲がある場合はREADY with warningsとし、secret検査済みとは報告しない。

選択したmodeで対象外のPhaseはSKIPと表示する。READYは選択したmodeについての判定であり、quick / pre-commitの結果をfull / pre-prの検証済みとして報告しない。リポジトリで未設定・適用外の検証も理由付きSKIPとする。設定済みの検証をツール不足などで実行できなかった場合はFAILとし、成功扱いにしない。SKIP項目をPASSと表示せず、READYには実施した検証と未実施の理由を併記する。

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
