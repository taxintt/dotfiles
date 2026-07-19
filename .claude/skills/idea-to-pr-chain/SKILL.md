---
name: idea-to-pr-chain
description: 生のアイデアを起点に設計・実装から PR 作成までを一気通貫で進めたいとき、「こういうものを作りたい、PR まで持っていって」のような依頼を受けたとき、または `/idea-to-pr` として明示呼び出しされたときに起動する。`grill-me` → `design-interview` → `implementation-planning` → 実装 → レビュー → 検証 → `git-workflow-chain` を順次実行する composition skill。
model: opus
---

<!-- 2026-07-19: dispatch 不能環境のため hypothetical RED で作成。dispatch 可能環境で pressure scenario の実検証を行うこと (skill-create の Iron Law 参照) -->

# Idea to PR Chain Skill

生のアイデアを stress-test（`grill-me`）してから設計 → 計画 → 実装 → PR 作成まで一気通貫で実行する composition skill。各ステップの実体は個別 skill に委ねる。

## 発火タイミング

- 「こういうツール / 機能を作りたい。PR まで持っていって」のような、アイデア起点の一括依頼
- `/idea-to-pr <アイデアの概要>` として明示呼び出し

アイデアの検証だけなら `grill-me` 単体、要件が既に明確なら `issue-to-pr-chain` または `implementation-planning` から始める。本 skill は使わない。

## 手順

次を順次実行。いずれかで失敗・承認却下・検証 FAIL となったら **停止してユーザーに報告**:

1. **`grill-me` skill を起動** — アイデアを stress-test し、確定した理解 / 未確定の論点を要約する（この段階で成果物は書かない）
2. **`design-interview` skill を起動** — 次のいずれかに該当するとき: 複数コンポーネント / データ永続化 / 外部連携 / 妥当なアーキテクチャが複数ある。いずれにも該当しない小規模なら skip 可（skip したことと理由を明示する）
3. **`implementation-planning` skill を起動** — 承認ホワイトリストに一致するまで実装しない
   - 数時間〜日単位の自走実装を指示されたときは、承認済み計画を `codex-goal-handoff` skill に渡す。受け入れレビュー（同 skill Phase 6）完了後、ステップ 7 のデリバリーから再合流する
4. **実装** — `tdd-workflow` skill。言語特化があれば委譲: Go → `golang-testing`、`*.tf` 編集後 → `terraform-validation`
   - ユーザーが Codex 委譲を指示したときは本ステップを `codex-delegation` skill に置換する（ステップ 5-6 は省略しない）
5. **レビュー** — `code-review-routing` skill。CRITICAL が残っていたら修正してから次へ
6. **検証** — `verification-loop` skill を `pre-pr` モードで実行
7. **デリバリー** — `git-workflow-chain` skill（branch → commit → PR）

## 引数の分配

- 第 1 引数以降の自由文（アイデアの概要）→ `grill-me` の初期コンテキスト
- `-y` / `-a` 等の git 系引数 → `git-workflow-chain` へ透過

## Iron Law

- **`grill-me` の確定 / 未確定の切り分けなしに設計・実装へ進まない**。未確定論点を推測で埋めるのは推測禁止原則の違反
- **計画の承認前に実装しない**（`implementation-planning` の Iron Law を継承）
- ステップ 2 以外の省略禁止。省略できるのは条件を明示した `design-interview` のみ。Codex への置換・handoff（ステップ 3-4 の分岐）は省略ではなく、同等の検証ゲート（受け入れレビューまたはステップ 5-6）を通すことが条件
- 途中失敗・検証 FAIL 時は続行しない
- 本 skill は composition のみ

### 典型的な rationalization

| 言い訳 | 現実 |
|---|---|
| 「アイデアは十分明確だから grill は不要」 | 明確に感じているのは書き手だけ。確定 / 未確定の切り分けは書いてみるまで分からない |
| 「質問はいいと言われたので推測で設計する」 | 絞れるのは質問の数であって、切り分けの省略ではない。`grill-me` は少数の急所質問に絞って実施する |
| 「プロトタイプだから TDD もレビューも不要」 | 品質基準の緩和は各 skill 内の判断。チェーンが先回りしてステップごと飛ばさない |
| 「grill-me の流れでそのまま実装したほうが速い」 | `grill-me` は成果物を書かない skill。承認ゲートを通らない実装は Iron Law 違反 |
| 「Codex がテスト込みで実装したからレビュー・検証は済んでいる」 | Codex の編集は PostToolUse hook を通らない（`codex-delegation` の Iron Law）。委譲時こそステップ 5-6 が唯一のゲートになる |
| 「goal mode に渡したので本チェーンは終了」 | 自走はデリバリーを含まない。受け入れレビュー後にステップ 7 で PR まで到達して初めて完了 |

## 関連

- 上流: `grill-me` / `design-interview` / `implementation-planning`
- 実装以降: `tdd-workflow` / `code-review-routing` / `verification-loop` / `git-workflow-chain`
- Codex 委譲: `codex-delegation`（同期・小タスク）/ `codex-goal-handoff`（長時間自走）
- issue 起点の同型チェーン: `issue-to-pr-chain`
