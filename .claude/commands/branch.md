---
description: "変更内容を分析して適切なブランチ名を考えて、ブランチを作成します"
---

## 引数

$ARGUMENTS

## オプション

- `-d`, `--dry-run`: ブランチを実際に作成せず、提案のみ行う
- `-p`, `--prefix <type>`: ブランチのプレフィックスを指定（feature, fix, hotfix, release, chore）

## Instructions

次の手順に従って深く考えてブランチを作成してください。

1. **現在の状況を確認**
   - `git status` で現在のブランチと変更状況を確認
   - `git branch -a` で既存のブランチ一覧を確認
   - 同名または類似のブランチが存在しないかチェック

2. **変更内容を分析**
   - ステージングされた変更、または作業ディレクトリの変更内容を確認
   - 変更の目的と種類を特定（新機能、バグ修正、リファクタリングなど）

3. **ブランチ名の決定**
   - [Conventional Branch](https://conventional-branch.github.io/) に従った命名を行う
   - プレフィックスは変更の種類に応じて選択：
     - `feature/`: 新機能追加
     - `fix/`: バグ修正
     - `hotfix/`: 緊急修正
     - `release/`: リリース準備
     - `chore/`: メンテナンス作業
   - 形式: `<prefix>/<簡潔な機能説明>`
   - 日本語は使用せず、ケバブケース（kebab-case）で記述

4. **ブランチの作成**
   - `--dry-run` オプションがある場合は、提案のみ行い作成しない
   - `--prefix` オプションがある場合は、指定されたプレフィックスを使用
   - `git checkout -b <branch-name>` でブランチを作成

5. **結果の報告**
   - 作成したブランチ名と、その名前を選んだ理由を説明
   - 必要に応じて、代替案も提示

## Notes

- 既に存在するブランチ名は避ける
- 長すぎるブランチ名は避け、50文字以内を目安にする
- チケット番号がある場合は `feature/TICKET-123-add-login` のように含める

## Examples

```
feature/add-user-authentication
fix/resolve-login-timeout-issue
hotfix/security-patch-xss
chore/update-dependencies
release/v1.2.0
```