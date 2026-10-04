---
name: implementation-planning
description: 新機能の開始、大きなアーキテクチャ変更、複雑リファクタ、複数ファイルに跨る変更など、要件が曖昧または広いタスクに取り組む前に起動する。planner エージェントを呼び出して段階計画を作成し、ユーザーが明示承認するまでコードを書かない。`/plan` として明示呼び出しされたときも起動する。
model: sonnet
---

[共通本文](shared/instructions.md) を読み、手順に従う。本文中の参考資料は shared/ を基準に解決する。

## Claude Codeでの連携

Claude Codeでは共通本文の「自ら計画を作成する」の代わりに、`planner` agent (`~/.claude/agents/planner.md`) を起動し、共通本文の計画作成手順を委譲する。agent呼び出しプロンプトに承認ホワイトリストと変更プロトコルを明示する。承認ゲートは委譲後も維持する。

## 関連

- ビルド修復: `golang-build-fixing`（Goプロジェクトでビルドが失敗したとき）
- レビュー: `code-review-routing`
- 連鎖: `issue-to-pr-chain` / `idea-to-pr-chain` skill
