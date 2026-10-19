# taxin の dotfiles

macOS 向けの個人設定ファイルです。
シェル、Git、tmux、ターミナルに加え、Claude Code と Codex CLI の設定を管理します。

## 内容

| パス | 説明 |
|---|---|
| `.zshrc` `.gitconfig` `.tmux.conf` `.config/` | シェル、Git、ターミナルの設定 |
| `.claude/skills/` | Claude Code のスキル（30件） |
| `.claude/agents/` | サブエージェントの定義（6件） |
| `.claude/hooks/` | PreToolUse、PostToolUse、Stop の各検証フック（5件） |
| `.claude/settings.json` | 権限、サンドボックス、プラグインの設定 |
| `.codex/` | Codex CLI の設定 |
| `agent-assets/skills/` | 共通スキルの本文とCodex用の入口 |
| `AGENTS.md` | Claude Code と Codex CLI で共用する開発規約。`~/.claude/CLAUDE.md` と `~/.codex/AGENTS.md` から参照 |
| `BrewFile` | Homebrew のパッケージ一覧 |

## 共通スキル

共通スキルの本文は `agent-assets/skills/<skill-name>/` に置きます。
各スキルの `SKILL.md` はCodex用の入口で、`instructions.md` は両方のエージェントが共用する指示本文です。
補助ファイルも同じディレクトリに置きます。

Claude Code用の入口とClaude固有の設定は `.claude/skills/<skill-name>/SKILL.md` に置きます。
このディレクトリの `shared` シンボリックリンクは `agent-assets/skills/` 内の共通本文を参照します。
`make link` を実行すると、Claude Code用のスキルを配置し、共通スキルをCodex用の `~/.agents/skills/` にリンクします。
Claude Code専用のスキルは `.claude/skills/` に置き、`agent-assets/skills/` には対応するディレクトリを作りません。

## スキルの使い分け

実装前のスキルは担当範囲ごとに分かれています。
スキルは説明文をもとに選ばれるため、それぞれの説明文に担当しない範囲も示します。

| スキル | 担当 | 次に連携するスキル |
|---|---|---|
| `grill-me` | アイデア、計画、要件を検討する。成果物は作らない | アーキテクチャを選び設計書を書く場合は `design-interview` |
| `design-interview` | 2〜3案を比較し、設計書を書く | 要件を固める場合は `grill-me` |
| `pbi-breakdown` | ユーザー価値、完了条件、受け入れ基準、対象外の4段階でPBIをSBIに分割する | アイデア出しは `grill-me`、技術設計は `design-interview`、実装計画は `implementation-planning` |
| `idea-to-pr-chain` | `grill-me` → `design-interview` → `implementation-planning` → 実装 → レビュー → 検証 → `git-workflow-chain` の流れを組み立てる | 各工程の具体的な作業は、それぞれのスキルが担当する |

`pbi-breakdown` は `idea-to-pr-chain` の工程ではなく、独立した入口です。
依存順で最初のSBI issueを指定して `issue-to-pr-chain` に進むか、`implementation-planning` を使うよう案内して終了します。

## セットアップ

### 1. パッケージをインストールする

```bash
make brew
```

### 2. `.gitconfig.local` を作成する

Gitのユーザー情報はGit管理対象外の `.gitconfig.local` に保存します。
`.gitconfig` は `~/.gitconfig.local` を読み込み、`make link` はリポジトリ内の `.gitconfig.local` をホームディレクトリにシンボリックリンクします。
リポジトリのルートで、`make link` の前に作成してください。

```bash
cat > .gitconfig.local <<'EOF'
[user]
	name = <git_username>
	email = <git_email_address>
EOF
```

### 3. シンボリックリンクを作成する

```bash
make link
```

各設定ファイルをホームディレクトリにシンボリックリンクします。
同じ名前のファイルがすでにある場合は上書きします。
`make link` は不要になったリンクを自動削除しません。削除済みスキル・エージェントへの既存リンクは、次の手順で整理します。

### 4. 削除済みスキル・エージェントへのリンクを掃除する

まずリポジトリのルートで確認コマンドを実行します。この段階では削除しません。

```bash
sh scripts/cleanup-retired-links.sh
```

`CHECK` に表示されたリンク先を確認し、削除する場合は次を実行します。

```bash
sh scripts/cleanup-retired-links.sh --apply
sh scripts/cleanup-retired-links.sh
```

最後の確認で `Matched links: 0` になれば掃除完了です。`SKIP` は削除せず残した対象です。
対象は `golang-patterns`、`golang-testing`、`golang-build-fixing`、`iterative-retrieval`、`git-branching` のClaude/Codex用リンクと、`go-build-resolver`、`go-reviewer` のエージェント用リンクです。
このチェックアウト内の削除済みパスを直接指す絶対パスのリンクだけを削除し、実ファイル・ディレクトリ・別のリンク先は保持します。相対パスや別チェックアウトを指すリンクは `SKIP` となるため、個別に確認してください。
確認先を変更する場合は `--home-dir /path/to/home` を指定できます。

## pstack plugin

[pstack](https://github.com/michael-denyer/pstack-claude)をClaude CodeとCodexで使用します。
汎用的な開発タスクは `poteto-mode` を入口にし、必要なワークフローへ振り分けます。

### 前提ツール

PR監視の `watch-pr` とスタック管理の `orch` はBunを使用します。
Bunは `.config/mise/config.toml` で管理します。`make brew` と `make link` の後にインストールしてください。

```bash
mise install bun
mise exec -- bun --version
```

これらのスクリプトは初回実行時に依存パッケージを取得するため、ネットワークアクセスも必要です。

### Claude Code

`make link` で配置する `.claude/settings.json` にmarketplaceとpluginの有効化設定を含めています。
新しいセッションで `/plugin` からインストール状態を確認し、未導入なら次を実行します。

```text
/plugin marketplace add michael-denyer/pstack-claude
/plugin install pstack@pstack-claude
```

`/pstack:poteto-mode` で呼び出せます。初期設定や自動ルーティングの変更は `/pstack:setup-pstack` を使用します。

### Codex

`make link` で配置する `.codex/config.toml` にmarketplaceとpluginの有効化設定を含めています。
plugin本体は別途インストールが必要です。未導入の環境では次のコマンドで登録・導入します。

```bash
codex plugin marketplace add michael-denyer/pstack-claude
codex plugin add pstack@pstack-claude
```

新しいセッションでpluginの読み込みを確認し、`/hooks` でpstackのSessionStart hookを確認・信頼すると自動ルーティングが有効になります。
hookの定義が更新された場合は再確認が必要です。`poteto-mode` を名前で指定して呼び出すこともできます。
並列エージェントを使うため、管理対象の `.codex/config.toml` で `multi_agent` を有効にしています。

### 動作確認

Claude CodeとCodexの両方で `poteto-mode` を明示し、読み取り専用のリポジトリ調査を依頼して、スキルが読み込まれることを確認します。
自動ルーティングは新しいセッションで複数工程の調査を依頼して確認します。
pluginの登録・インストールだけでは、セッションでの読み込みやhookの実行確認は完了しません。

## その他のコマンド

```bash
make help
```

## ライセンス

[LICENSE](LICENSE) に記載のMITライセンスです。
一部の内容は次の第三者資料をもとにしています。

- `agent-assets/skills/japanese-tech-writing/`：k16shikano氏のgist（Unlicense）
- `agent-assets/skills/systematic-debugging/` と `agent-assets/skills/verification-before-completion/`：[obra/superpowers](https://github.com/obra/superpowers)（MIT）をもとに作成
