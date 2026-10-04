---
name: git-workflow-chain
description: 変更から PR までを一気通貫で行うとき、ユーザーが「ブランチ切ってコミットして PR 作って」のように連鎖依頼したとき、または `/git-create-branch-commit-pr` として明示呼び出しされたときに起動する。`git-branching` → `git-commit` → `git-pull-request` を順次実行する composition skill。
model: haiku
---

[共通本文](shared/instructions.md) を読み、手順に従う。本文中の参考資料は `shared/` を基準に解決する。

## 関連

- 上流連鎖: `issue-to-pr-chain` / `idea-to-pr-chain` skill（本 skill をデリバリー段として利用）
