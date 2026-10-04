---
name: pbi-breakdown
description: スクラムの PBI (Product Backlog Item) を SBI (Sprint Backlog Item) に分割するとき、スプリントプランニングやリファインメントでバックログアイテムをタスク分解したいとき、「この PBI をタスクに割って」「スプリントのタスクに分割したい」のような依頼を受けたとき、または `/pbi-breakdown` として明示呼び出しされたときに起動する。
model: opus
---

[共通本文](shared/instructions.md) を読み、手順に従う。本文中の参考資料は shared/ を基準に解決する。

## Claude Codeでの連携

Claude Codeでは共有本文のissue化後のhandoffを以下に置き換えて推奨する（実行しない）。issue化しない場合は共通本文に従う:

- issue 化した場合 → `issue-to-pr-chain`（**`実施順序` の先頭の SBI の issue URL** を渡す。一覧の並びは着手順とは限らず、依存を残したまま実装が走る。番号だけ渡すと cwd のリポジトリの同番号 issue に解決される。同 skill は issue 1 件を PR 1 本に通すため、親 PBI issue を渡すと分割が 1 PR に潰れる）
  - 対象リポジトリが cwd と違うなら、**先に cwd を対象リポジトリへ移すようユーザーに伝える**。URL を渡して切り替わるのは issue の読み取りだけで、同 skill の実装・PR 作成（`tdd-workflow` / `git-workflow-chain`）は cwd のリポジトリで動く
