# Core Philosophy

## 基本原則
- **Agent-First**: 複雑なタスクは `.claude/agents/` の専門エージェントに委譲
- **Plan Before Execute**: 複数ファイル変更や不慣れなコードにはPlan Modeを使用
- **TDD**: テスト先行開発 (RED → GREEN → REFACTOR)
- **Security-First**: コミット前に必ずセキュリティチェック
- **YAGNI, KISS, DRY**: ユーザーからの指示がない限り、いたずらに行数を増やさずにシンプルに実装
- **Latest feature**: より最新の書き方や最新の機能を使って、後方互換を考慮する必要はない

## 振る舞い制御

### 誠実性と対話
- **質問には質問で答える**: ユーザーが質問したとき（特に疑問符で終わっているとき）は、勝手に作業を開始せず、質問に答える
- **出来ないことは明言する**: 技術的に不可能なことや実装困難なことは「出来ない」「不可能です」と正直に返答
- **推測を禁止**: 不明な点や曖昧な要件がある場合は推測で進めず、必ずユーザーに質問して確認する
- **批判的思考**: ユーザーの提案や指示が技術的に問題がある場合は無条件に受け入れず、理由を説明し代替案を提示する

### 実装の制約
- **最小限の変更**: 依頼された機能のみを実装し、勝手に機能追加・リファクタリング・ドキュメント追加をしない
- **既存パターンの踏襲**: 新規実装時は既存のコードベースのパターンとスタイルに従う
- **フォールバック禁止**: 発生しないシナリオに対するエラー処理、フォールバック、または検証を追加しない

# Rules

詳細なルールは以下のファイルを参照：

## コンテキスト別の振る舞い
@.claude/rules/dev.md - 開発モード（実装重視、TDD必須）
@.claude/rules/research.md - 調査モード（理解優先、推測禁止）
@.claude/rules/review.md - レビューモード（品質・セキュリティ重視）

## ワークフロー・スタイル
@.claude/rules/git-workflow.md
@.claude/rules/coding-style.md
@.claude/rules/testing.md

## セキュリティ・品質
@.claude/rules/security.md
@.claude/rules/performance.md
@.claude/rules/patterns.md

## システム
@.claude/rules/agents.md
@.claude/rules/hooks.md
