---
name: doc-workflow-chain
description: ドキュメント作成を計画から本文執筆まで一気通貫で進めたいとき、「ドキュメントを書きたい」という依頼が計画と執筆の両方を含むとき、または `/doc-chain` として明示呼び出しされたときに起動する。`doc-planning` → `japanese-tech-writing` を順次実行する composition skill。
model: opus
---

<!-- 2026-07-19: dispatch 不能環境のため hypothetical RED で作成。dispatch 可能環境で pressure scenario の実検証を行うこと (skill-create の Iron Law 参照) -->

# Doc Workflow Chain Skill

計画（`doc-planning`）→ 本文執筆（`japanese-tech-writing`）を一気通貫で実行する composition skill。各ステップの実体は個別 skill に委ねる。

## 発火タイミング

- 「〜のドキュメントを書きたい」という依頼が、計画立案と本文執筆の両方を含むとき
- `/doc-chain` として明示呼び出し

計画だけなら `doc-planning` 単体、既存文の推敲だけなら `japanese-tech-writing` 単体を使う。本 skill は使わない。

## 手順

次を順次実行。いずれかで失敗・承認却下されたら **停止してユーザーに報告**:

0. **（任意）材料収集** — 題材が vault や外部情報にあるときのみ `obsidian-context` / `deep-research` を使う。デフォルトでは実行しない
1. **`doc-planning` skill を起動** — 読者分析 / Why-What-How / アウトライン / 次アクションを含む計画書を提示し、ユーザーの承認を待つ
2. **`japanese-tech-writing`（作成モード）を起動** — 承認された計画のアウトラインに従い、文章規範を適用して本文を執筆
3. **`japanese-tech-writing`（レビューモード）で自己推敲** — 執筆した本文を文章規範に照らしてレビューし、指摘を反映

## 引数の分配

`$ARGUMENTS`（テーマまたは目的）はそのまま `doc-planning` に渡す。

## Iron Law

- **計画の承認前に本文を書かない**。「読者が自明」も「頭の中に構成がある」も ×
- 本 skill は composition のみ。読者分析や文章規範の定義を重複して持たない
- 途中失敗・承認却下時は続行しない

### 典型的な rationalization

| 言い訳 | 現実 |
|---|---|
| 「読者が明確だから計画は不要」 | 読者分析は計画の一部でしかない。Why-What-How とアウトラインが欠けたまま書くと構成の手戻りが起きる |
| 「書きながら構成を決めたほうが速い」 | 暗黙の計画は承認ポイントを消す。計画書はユーザーが方向を修正できる唯一の機会 |
| 「文章規範は最後に 1 回かければいい」 | 規範違反した草稿の後追い修正は全文リライトになる。作成モードで最初から適用する |
| 「計画と本文を 1 メッセージで出すほうが効率的」 | 承認を経ない計画は計画ではない。`doc-planning` の「本体は書かない」責務の違反 |

## 関連

- `doc-planning` / `japanese-tech-writing`
- 材料収集（任意前段）: `obsidian-context` / `deep-research`
