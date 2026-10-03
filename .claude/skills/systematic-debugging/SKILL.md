---
name: systematic-debugging
description: テスト失敗 / 本番バグ / 想定外挙動 / パフォーマンス問題 / ビルド失敗 / integration 問題に直面したとき、修正前に体系的な根本原因調査を強制する。「原因を調査して」「エラーになった（ので調べて）」「CI が落ちている / 失敗している」「apply が失敗した」のような調査依頼や、CI / GitHub Actions のジョブ失敗ログ（URL 付き）を渡された調査依頼でも起動する。terraform / CI / apply の失敗は本 skill が原因切り分け（調査フェーズ）を担い、原因特定後の検証ゲートは terraform-validation に委ねる。`/debug` として明示呼び出しされたときも起動する。
model: opus
---

[共通本文](shared/instructions.md) を読み、手順に従う。本文中の参考資料は `shared/` を基準に解決する。

## Claude Codeでの連携

- 想定pressure scenarioは `skill-create` のIron Lawに従う。実subagent baselineは `empirical-prompt-tuning` で取得し、観察されたrationalizationを共通本文のRationalization Tableに追記して強化する。

## 関連

- `code-review-routing` — Phase 1で他者レビューが必要なときのルーティング
