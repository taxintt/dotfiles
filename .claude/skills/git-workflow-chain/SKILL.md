---
name: git-workflow-chain
description: ブランチ作成だけを依頼されたとき、または変更からPRまでを一気通貫で行うとき、ブランチ作成後にgit-commit・git-pull-requestを順次実行する。`/git-create-branch-commit-pr` として明示呼び出しされたときも起動する。
model: haiku
---

[共通本文](shared/instructions.md) を読み、手順に従う。本文中の参考資料は `shared/` を基準に解決する。

## 関連

- 上流連鎖: `issue-to-pr-chain` / `idea-to-pr-chain` skill（本 skill をデリバリー段として利用）
