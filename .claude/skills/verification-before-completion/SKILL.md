---
name: verification-before-completion
description: 「完了」「修正済み」「テスト合格」「問題なし」と主張する直前、commit / PR 作成の直前に発火する。検証コマンドを fresh に実行し出力を確認した上でしか主張させない。`/verify-claim` として明示呼び出しされたときも起動する。
model: sonnet
---

[共通本文](shared/instructions.md) を読み、手順に従う。本文中の参考資料は `shared/` を基準に解決する。

## Claude Codeでの連携

- TodoWriteで `completed` に更新する前にも、共通本文の5-Step Gateを通す。
- 想定pressure scenarioは `skill-create` のIron Lawに従う。実subagent baselineは `empirical-prompt-tuning` で取得し、観察されたrationalizationを共通本文のRationalization Tableに追記して強化する。

## 関連

- **デバッグ起点**: `systematic-debugging` のPhase 4完了主張前に必ず本skillを発火
- **Goビルド対象**: `golang-build-fixing` の出力をStep 3-4で確認
- **コードレビュー対象**: `code-review-routing` 起動前に本skillのゲートを通す
