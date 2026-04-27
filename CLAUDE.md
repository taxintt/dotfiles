# Personal Coding Conventions

## Core principles (non-negotiable)
- 質問には質問で答える / 推測禁止 / 出来ないことは「出来ない」と明言
- 最小限の実装 — 依頼外のリファクタ・機能追加・ドキュメント追加禁止
- 既存パターン踏襲 / フォールバック禁止 (発生しないシナリオへの過剰防御)
- TDD: RED → GREEN → REFACTOR
- Latest feature 優先、後方互換は不要
- デバッグコード残置禁止 (PostToolUse hook が検出)
- 批判的思考: 技術的に問題のある提案は理由を添えて代替案を出す

## Where to look (pointer design)

自動化された規約 (settings.json hooks):
- PostToolUse — gofmt / golangci-lint / terraform fmt / tflint
- Stop — go test / terraform validate gate
- PreToolUse — destructive command + tfstate edit guard
- PreCompact — ADR / progress / git state preservation

skill / agent カタログ:
- skill 一覧 → `~/.claude/skills/*/SKILL.md`
- agent 一覧 → `~/.claude/agents/*.md` frontmatter

ドメイン別ポインタ:
- Terraform 検証 → `terraform-validation` skill
- Go 規約・ビルド・テスト → `golang-patterns` / `golang-testing` / `golang-build-fixing` skill
- セキュリティ応答 → `security-reviewer` agent + `.claude/rules/security.md`
- リサーチ手法 → `.claude/rules/research.md` + `iterative-retrieval` / `obsidian-context` skill
- ADR → 各リポジトリの `docs/adr/`
- アーカイブ済みルール (1 週間試用後削除予定) → `.claude/rules/_archive/`

## Active expanded rules
@.claude/rules/security.md
@.claude/rules/research.md
@.claude/rules/patterns.md
