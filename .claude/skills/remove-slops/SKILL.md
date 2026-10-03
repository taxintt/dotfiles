---
name: remove-slops
description: AI 生成コードに混入しがちな冗長なコード (slop) を除去する。ユーザーが「slop 除去」「不要コメント削除」と依頼したとき、または `/remove-slops` として明示呼び出しされたときに起動する。
model: sonnet
---

[共通本文](shared/instructions.md) を読み、手順に従う。本文中の参考資料は `shared/` を基準に解決する。

## Claude Codeでの連携

## 関連

- `cleanup-dead-code` skill — 未使用コード・import の除去
- `code-review-routing` skill — コード品質のより広いレビュー
