---
description: "変更内容を分析して適切なブランチ名を考え、ブランチを作成する"
argument-hint: "[-d] [-p <prefix>] [description]"
---

## 引数

`$ARGUMENTS` を空白で分割し、先頭から順に以下のオプションを解釈する。残余はブランチ名の候補説明として扱う。

- `-d`, `--dry-run`: ブランチを作成せず、提案のみ行う
- `-p <type>`, `--prefix <type>`: ブランチのプレフィックスを指定（feature / fix / hotfix / release / chore）

## Instructions

1. **現状確認**
   - `git status` / `git branch -a` で現在のブランチと既存ブランチ一覧を取得
   - 同名・類似ブランチが無いかを確認
   - 現在 main / master にいる場合は、当該ブランチの remote から pull して最新化（`git pull origin $(git rev-parse --abbrev-ref HEAD)`）

2. **変更内容の分析**
   - staged / unstaged の差分を確認し、変更の種類（新機能 / バグ修正 / リファクタ等）を特定
   - 推論できない場合はユーザーに prefix と説明を確認する（推測禁止）

3. **ブランチ名の決定**
   - [Conventional Branch](https://conventional-branch.github.io/) に従い、形式は `<prefix>/<簡潔な説明>`
   - prefix: `feature/` / `fix/` / `hotfix/` / `release/` / `chore/`
   - 説明部分はケバブケース（kebab-case）、日本語不可、50 文字以内
   - チケット番号がある場合は `feature/TICKET-123-add-login` のように含める
   - `--prefix` 指定があればそれを優先

4. **ブランチの作成**
   - `--dry-run` 指定時は提案のみ
   - それ以外は `git switch -c <branch-name>` で作成

5. **結果の報告**
   - 作成したブランチ名と命名理由を提示
   - 代替案が有意ならあわせて提示
