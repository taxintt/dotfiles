---
name: issue-to-pr-chain
description: GitHub issue を起点に実装から PR 作成までを一気通貫で進めたいとき、「issue #N を実装して PR まで出して」のような依頼を受けたとき、または `/issue-to-pr` として明示呼び出しされたときに起動する。issue 読解 → 計画 → 実装 → レビュー → 検証 → `git-workflow-chain` を順次実行する composition skill。
model: sonnet
---

<!-- 2026-07-19: dispatch 不能環境のため hypothetical RED で作成。dispatch 可能環境で pressure scenario の実検証を行うこと (skill-create の Iron Law 参照) -->

# Issue to PR Chain Skill

GitHub issue を起点に、計画 → 実装 → レビュー → 検証 → PR 作成を一気通貫で実行する composition skill。各ステップの実体は個別 skill / agent に委ねる。

## 発火タイミング

- 「issue #N を実装して PR まで」のような、issue 起点の一括依頼
- `/issue-to-pr <issue 番号または URL>` として明示呼び出し

issue の調査だけ・実装だけなら該当する個別 skill を使う。本 skill は使わない。

## 手順

次を順次実行。いずれかで失敗・承認却下・検証 FAIL となったら **停止してユーザーに報告**:

1. **Issue 読解** — GitHub MCP で issue 本文・コメントを取得し、要件と受け入れ条件を言語化してユーザーに提示する。不明点は質問する。推測で補完しない
2. **計画** — issue 種別で分岐:
   - バグ報告 → `systematic-debugging` skill（Phase 1-3 で原因特定後、Phase 4 から実装へ）
   - 機能・改善 → `implementation-planning` skill（承認ホワイトリストに一致するまで実装しない）
3. **実装** — `tdd-workflow` skill。言語特化があれば委譲: Go → `golang-testing`、`*.tf` 編集後 → `terraform-validation`
4. **レビュー** — `code-review-routing` skill。CRITICAL が残っていたら修正してから次へ
5. **検証** — `verification-loop` skill を `pre-pr` モードで実行
6. **デリバリー** — `git-workflow-chain` skill（branch → commit → PR）。PR 本文に `Closes #<issue 番号>` を含める

## 引数の分配

- 第 1 引数: issue 番号または URL（必須。なければユーザーに確認）
- `-y` / `-a` 等の git 系引数 → `git-workflow-chain` へ透過

## Iron Law

- **計画の承認前に実装しない**（`implementation-planning` の Iron Law を継承）
- **ステップの省略禁止**。「issue が小さい」は各ステップを速く通過する理由にはなるが、飛ばす理由にはならない
- 途中失敗・検証 FAIL 時は続行しない
- 本 skill は composition のみ。計画・テスト・検証の基準を重複して持たない

### 典型的な rationalization

| 言い訳 | 現実 |
|---|---|
| 「issue 本文が明確だから計画は不要」 | 明確なのは症状や要望であって、受け入れ条件と実装方針ではない。計画はそれを言語化する工程 |
| 「小さい修正だからテスト先行は過剰」 | テストの粒度は `tdd-workflow` が判断する。チェーンが先回りして省略しない |
| 「検証は CI がやるからローカルは省略」 | `pre-pr` はローカルゲート。CI 失敗後の往復コストのほうが高い |
| 「レビューは PR 上で人間がやるから skip」 | `code-review-routing` は PR 前の自己レビュー。人間レビューの代替ではなく前提 |
| 「バグの原因は自明だから調査不要」 | 自明に見える原因は `systematic-debugging` Phase 1 で数分で裏が取れる。取れないなら自明ではなかった |

## 関連

- 計画: `implementation-planning` / `systematic-debugging`
- 実装: `tdd-workflow`（Go: `golang-testing` / Terraform: `terraform-validation`）
- レビューと検証: `code-review-routing` / `verification-loop`
- デリバリー: `git-workflow-chain`
- アイデア起点の同型チェーン: `idea-to-pr-chain`
