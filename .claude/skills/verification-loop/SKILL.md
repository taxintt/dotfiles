---
name: verification-loop
description: PR / commit 作成前にビルド / 型チェック / lint / テスト / シークレット / デバッグ文 / git 状態を網羅的に検証する。ユーザーが「検証して」「PR 前チェックして」と依頼したとき、または `/verify` として呼ばれたときに起動する
model: sonnet
---

[共通本文](shared/instructions.md) を読み、手順に従う。本文中の参考資料は `shared/` を基準に解決する。

## Hook との統合

この skill は PostToolUse hook を補完するが、より深い検証を提供する。
hook は即時に問題を捕捉し、この skill は包括的なレビューを行う。
