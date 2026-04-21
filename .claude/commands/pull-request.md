---
description: 現ブランチの変更内容で Pull Request を作成する。保護ブランチ（main / master / release/vX.Y.Z / develop）では中断する
argument-hint: "[title-override]"
---

## 引数

`$ARGUMENTS` が与えられていれば PR タイトルの候補として扱う。未指定なら会話文脈とコミット履歴から生成する。

## Instructions

### ステップ1: ブランチ検証

`git rev-parse --abbrev-ref HEAD` で現ブランチを取得し、以下のいずれかに該当するなら **中断してユーザーに別ブランチへの切り替えを促す**:

- `main` / `master` / `develop`
- `release/vN.N.N` 形式（例: `release/v1.2.3`。正規表現: `^release/v\d+\.\d+\.\d+$`）

### ステップ2: 変更差分の把握

base ブランチ（通常は `main`）との差分を取得:

- `git log <base>..HEAD --oneline` で commit 履歴
- `git diff <base>...HEAD` で全差分

差分ゼロなら中断。

### ステップ3: PR テンプレート

`.github/PULL_REQUEST_TEMPLATE.md` を読み込む。

- 存在する場合: テンプレートのセクション構造に従って記入。`<!-- -->` コメントは開発者向けメモなので出力に含めない
- 存在しない場合: 次の汎用構造でボディを作成
  - `## Summary`（1-3 箇条書き）
  - `## Test plan`（検証手順の checkbox リスト）

### ステップ4: コミット / Push

- 未コミットの変更がある場合: ユーザーに確認してから `/commit` に委譲（または即コミット）
- ローカル HEAD が upstream より進んでいる場合: `git push -u origin HEAD` で push
- 既に push 済みなら何もしない

### ステップ5: PR 作成

`gh pr create --title "<title>" --body "$(cat <<'EOF' ... EOF)"` の形式で実行。タイトルは 70 文字以内、本文に詳細を寄せる。

作成後、PR URL を表示。

## 禁止事項

- 保護ブランチ（上記）での PR 作成
- テンプレートの `<!-- -->` コメントを本文に残す
- 差分がないのに PR を作る
