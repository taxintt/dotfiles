---
name: cleanup-dead-code
description: JS / TS プロジェクトで不要なコード / 依存を削除したいとき、またはユーザーが `/cleanup-dead-code` として明示呼び出ししたときに起動する。knip / depcheck / ts-prune で検出し、テスト駆動で段階削除する。Go / Python など他言語には適用しない。
model: sonnet
---

[共通本文](shared/instructions.md) を読み、手順に従う。本文中の参考資料は `shared/` を基準に解決する。

## 関連

- 検証: `verification-loop` skill（削除後の全体検証）
