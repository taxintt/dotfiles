---
name: git-branching
description: 新規ブランチの作成が必要なとき、特に main / master で作業を始めようとしたとき、あるいはユーザーが「ブランチ切って」「新ブランチで作業したい」と言ったとき、または `/branch` として明示呼び出しされたときに起動する。Conventional Branch 規約に従った命名を生成する。
model: haiku
---

# Git Branching Skill

変更内容を分析し、Conventional Branch 規約に従った適切なブランチ名を決定・作成する。

## 発火タイミング

- コミット / PR 作成前に main / master にいることを検出した
- ユーザーが「ブランチ作って」「新しいブランチで」と依頼
- `/branch` として明示呼び出し

## 引数

`[-d] [-p <prefix>] [description]` 形式:

- `-d` / `--dry-run`: ブランチを作成せず、提案のみ
- `-p <type>` / `--prefix <type>`: prefix を指定（feature / fix / hotfix / release / chore）
- 残余: ブランチ名の候補説明

## 手順

1. **現状確認**
   - `git status` / `git branch -a` で現ブランチと既存ブランチ一覧
   - 同名・類似ブランチの有無を確認
   - main / master にいる場合は remote から pull して最新化:
     ```bash
     git pull origin $(git rev-parse --abbrev-ref HEAD)
     ```

2. **変更内容の分析**
   - staged / unstaged の差分から変更種別（新機能 / バグ修正 / リファクタ等）を特定
   - **推論できない場合はユーザーに prefix と説明を確認**（推測禁止）

3. **ブランチ名の決定**
   - [Conventional Branch](https://conventional-branch.github.io/) 準拠: `<prefix>/<簡潔な説明>`
   - prefix: `feature/` / `fix/` / `hotfix/` / `release/` / `chore/`
   - 説明: kebab-case、日本語不可、50 文字以内
   - チケット番号あり: `feature/TICKET-123-add-login`
   - `--prefix` 指定があればそれを優先

4. **ブランチ作成**
   - `--dry-run`: 提案のみ
   - それ以外: `git switch -c <branch-name>`

5. **結果報告**
   - 作成ブランチ名と命名理由
   - 代替案が有意ならあわせて提示

## Iron Law

- 推測で prefix を決めない。diff から判断できないならユーザーに聞く
- kebab-case 必須。camelCase / snake_case は不可
- 日本語ブランチ名は作らない（ツール互換性）

## 関連

- コミット: `git-commit` skill
- PR 作成: `git-pull-request` skill
- 連鎖: `git-workflow-chain` skill（branch → commit → PR 一気通貫）
