---
name: git-commit
description: 変更をコミットするとき、ユーザーが「コミットして」と依頼したとき、または `/commit` として明示呼び出しされたときに起動する。atomic 粒度と「なぜ」を書くメッセージ規約を強制し、main / master では中断する。
---

# Git Commit Skill

変更を分析し、適切な粒度と「なぜ」を書くコミットメッセージで commit する。ブランチ作成は **スコープ外**（`git-branching` skill を使う）。

## 発火タイミング

- 実装 / 修正を一区切りさせてコミットしたい
- ユーザーが「コミットして」「commit」と依頼
- `/commit` として明示呼び出し

## 引数

`[-y] [-a] [-s] [-e]` 形式:

- `-y` / `--yes`: 確認なしで即コミット（デフォルトは確認モード）
- `-a` / `--all`: 追跡中ファイルの変更を全ステージ（`git add -u` 相当。未追跡は対象外）
- `-s` / `--split`: 変更を論理単位で複数コミットに分割
- `-e` / `--english`: メッセージを英語で記述

## 手順

### ステップ 1: 現状把握（並列実行）

- `git status`（`-uall` は使わない）
- `git diff --staged`
- `git diff`
- `git log --oneline -5`（prefix スタイル参照）
- `git branch --show-current`

変更がなければ通知して終了。

### ステップ 2: ブランチ判定（Iron Law）

**main / master にいる場合: 即中断**。`git-branching` skill か `git-workflow-chain` skill の使用を促す。

ブランチ命名ルールは `git-branching` skill を参照。

### ステップ 3: ステージング判定

- `-a` 指定: `git add -u`
- staged ファイルあり: そのまま続行
- staged ファイルなし: 会話文脈から候補を提示。**判断不能ならユーザーに質問**（推測禁止）
- `.env` / credentials 等の機密ファイルが含まれる場合: **警告して中断**

### ステップ 4: メッセージ生成

#### 「なぜ」を中心に書く

diff は「何を」を語る。メッセージでしか伝えられないのは「なぜ」。会話文脈から背景・課題・目的を読み取って主軸にする。

typo / lint 修正など理由が自明なときのみ本文を省略。「不要コード削除」のような主観を含む場合は、判断根拠（grep 結果 / issue / 技術的事実）を本文に記載。

#### 構造

```
<type>: 変更の要約（50 文字以内推奨、最大 72 文字）

変更理由の説明（自明なら省略可）
```

- 1 行目は命令形、末尾に句読点なし
- 本文は 72 文字で改行、issue / PR 番号や数値があれば含める

#### prefix（Conventional Commits）

直近のコミットログで prefix が使われていればそのスタイルに合わせる。使われていなければ付けない。

- `feat`: ユーザーから見た新機能 / 振る舞い追加
- `fix`: ユーザーが困る不具合の修正
- `chore`: 裏方作業（より具体的な `refactor` / `perf` / `test` / `docs` / `ci` があればそちらを優先）

破壊的変更は `!`（例: `feat!: APIレスポンスの形式を変更`）。

#### その他

- **日本語**で記述（`-e` なら英語）。技術用語は英語のまま可
- 公式表記を遵守（GitHub, TypeScript, Next.js, PostgreSQL 等）
- **アトミック**: 独立してリバート可能な単位。複数論理変更が混ざるなら分割を提案

### ステップ 5: 実行

#### 確認モード（デフォルト）

以下を **1 回だけ** まとめて確認:

- ブランチ: 現ブランチ名
- ステージ対象: ファイル一覧
- メッセージ: 生成全文

承認後に実行。

#### `-y` 指定時

即実行。

#### 実行コマンド

HEREDOC 形式必須:

```bash
git commit -m "$(cat <<'EOF'
コミットメッセージ1行目

本文（必要な場合）
EOF
)"
```

複数コミットなら順次実行。完了後 hash と message を表示。

## Iron Law

- `git push` は **実行しない**（`git-pull-request` skill のスコープ）
- `--amend` 禁止
- `--no-verify` 禁止（hook 失敗は根本原因を直す）
- `.env` / credentials は警告で中断
- main / master では中断

### 典型的な rationalization

| Rationalization | 対処 |
|---|---|
| 「1 回だけ main に直接」 | 即中断。`git-branching` へ誘導 |
| 「hook が遅いから --no-verify」 | 根本原因を直す。スキップしない |
| 「前の commit に amend で足せば楽」 | 新コミットを作る |
| 「.env は .gitignore 漏れだけど小さいから OK」 | 中断。rotate 必要かも |

## 関連

- ブランチ作成: `git-branching` skill
- PR 作成: `git-pull-request` skill
- 連鎖: `git-workflow-chain` skill
