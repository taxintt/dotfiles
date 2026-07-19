# Personal Coding Conventions

## Core principles (non-negotiable)
- `?` で終わる入力は作業せず質問に回答するだけ
- 質問には質問で答える / 推測禁止 / 出来ないことは「出来ない」と明言
- 最小限の実装 — 依頼外のリファクタ・機能追加・ドキュメント追加禁止
- 既存パターン踏襲 / フォールバック禁止 (発生しないシナリオへの過剰防御)
- TDD: RED → GREEN → REFACTOR
- Latest feature 優先、後方互換は不要
- デバッグコード残置禁止 (PostToolUse hook が検出)
- 批判的思考: 技術的に問題のある提案は理由を添えて代替案を出す

## 推奨 CLI ツール
- `rg` (ripgrep) — grep の代替。高速・gitignore 対応
- `fd` — find の代替。シンプルな構文
- `gojq` / `jq` — JSON 処理 (gojq 優先)

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
- Codex への実装委譲 (Claude = orchestrator / Codex = implementer) → `codex-delegation` skill
- Codex Goal mode での自走実装 + agmsg advisor 常駐 → `codex-goal-handoff` skill
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

# Personal Patterns

## Skeleton-first for new projects
When starting new functionality, prefer cloning a battle-tested skeleton over greenfield:
1. Search for proven skeletons in the relevant ecosystem
2. Run parallel agents to evaluate (security / extensibility / relevance / implementation cost)
3. Clone the best match
4. Iterate within the proven structure rather than redesigning

## When to use Plan Mode
- Multi-file changes
- Unfamiliar code area
- Architectural choice with several reasonable options

For trivial single-file edits, skip Plan Mode.

## Parallel agents over serial
Independent agent invocations in a single message run concurrently. Use this for: multi-angle reviews, broad exploration, multi-language linting, multi-dir test runs.

# Research Mode

Goal: understand before acting. Don't write code until the question is clear.

## Hard rules
- 推測禁止 — 不確かなら「不明」と明示
- 仮説は「仮説」として明示、事実と分けて報告
- 調査中はコード変更しない

## Default tools
- Explore agent — wide codebase sweeps
- `iterative-retrieval` skill — narrow context for subagents
- `obsidian-context` skill — pull from personal vault
- Parallel Task agents — multi-angle analysis (security / perf / types)

## Output sections
1. 調査結果 (事実 + 根拠)
2. 推奨事項 (調査結果に基づく)
3. 不明点 (追加調査が必要な項目)

# Security Guidelines

## Pre-commit checks (must pass)
- No hardcoded secrets (API keys, passwords, tokens)
- All user inputs validated at boundaries
- SQL injection: parameterized queries only
- XSS: sanitized HTML output
- AuthN/AuthZ: verified for every protected path
- Error messages: no sensitive-data leakage

## Secret rule
- Never hardcode. Read from env vars; throw at startup if absent.

## Incident protocol
1. STOP — do not push, do not commit further
2. Hand off to `security-reviewer` agent
3. Fix CRITICAL issues first
4. Rotate any exposed secret
5. Sweep codebase for similar patterns
