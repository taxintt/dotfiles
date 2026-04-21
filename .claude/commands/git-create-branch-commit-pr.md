---
description: 変更内容を分析し、ブランチ作成 → コミット作成 → プルリクエスト作成までを一気通貫で行う
---

## Instructions

次の 3 コマンドを順次実行する。いずれかで失敗した場合は停止してユーザーに報告する。

1. `/branch` を実行
2. `/commit` を実行
3. `/pull-request` を実行

各コマンドは `@.claude/commands/<name>.md` に定義されたルールに従う。オプションを渡す必要がある場合は `$ARGUMENTS` から分配する。
