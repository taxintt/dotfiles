---
name: git-pull-request
description: 現ブランチの変更で PR を作成するとき、ユーザーが「PR 作って」と依頼したとき、または `/pull-request` として明示呼び出しされたときに起動する。保護ブランチ（main / master / develop / release/vX.Y.Z）では即中断する。
---

# Git Pull Request Skill

現ブランチの変更内容で PR を作成する。保護ブランチ上では **絶対に PR を作らない**。

## 発火タイミング

- 実装完了後、レビュー依頼を出したい
- ユーザーが「PR 作って」「プルリク作成」と依頼
- `/pull-request` として明示呼び出し

## 引数

`[title-override]` — 指定があれば PR タイトル候補。未指定なら会話文脈とコミット履歴から生成。

## 手順

### ステップ 1: ブランチ検証（Iron Law）

`git rev-parse --abbrev-ref HEAD` で現ブランチを取得。以下に該当するなら **中断**、別ブランチへ切り替えるよう促す:

- `main` / `master` / `develop`
- `release/vN.N.N` 形式（正規表現: `^release/v\d+\.\d+\.\d+$`、例: `release/v1.2.3`）

### ステップ 2: 変更差分の把握

base ブランチ（通常 `main`）との差分:

```bash
git log <base>..HEAD --oneline   # commit 履歴
git diff <base>...HEAD            # 全差分
```

差分ゼロなら中断。

### ステップ 3: PR テンプレート

`.github/PULL_REQUEST_TEMPLATE.md` を読み込む:

- **存在する場合**: セクション構造に従って記入。`<!-- -->` コメント（開発者向けメモ）は出力に含めない
- **存在しない場合**: 汎用構造
  - `## Summary`（1-3 箇条書き）
  - `## Test plan`（検証手順の checkbox リスト）

### ステップ 4: コミット / Push

- 未コミット変更がある場合: ユーザー確認後、`git-commit` skill に委譲または即コミット
- ローカル HEAD が upstream より進んでいる場合: `git push -u origin HEAD`
- 既に push 済みなら何もしない

### ステップ 5: PR 作成

```bash
gh pr create --title "<title>" --body "$(cat <<'EOF'
<body>
EOF
)"
```

- タイトル: 70 文字以内
- 本文に詳細を寄せる
- 作成後 PR URL を表示

## Iron Law

- 保護ブランチでの PR 作成は **絶対禁止**
- `<!-- -->` コメントを body に残さない
- 差分ゼロで PR を作らない
- `--force-with-lease` / `--force` は本 skill のスコープ外（ユーザー明示指示がある場合のみ別途検討）

### 典型的な rationalization

| Rationalization | 対処 |
|---|---|
| 「テスト用 PR だから main で OK」 | 中断。test ブランチを切る |
| 「release/v1.2 の typo 修正だけだから」 | release/vX.Y.Z は保護。別ブランチへ |
| 「PR template の `<!-- -->` は残してもいい」 | 常に除去 |
| 「差分ゼロだけど PR だけ先に作っておく」 | 差分が出てから作る |

## 関連

- ブランチ作成: `git-branching` skill
- コミット: `git-commit` skill
- 連鎖: `git-workflow-chain` skill
- 検証: `verification-loop` skill（PR 前の `pre-pr` モード）
