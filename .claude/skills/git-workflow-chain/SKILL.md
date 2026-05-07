---
name: git-workflow-chain
description: 変更から PR までを一気通貫で行うとき、ユーザーが「ブランチ切ってコミットして PR 作って」のように連鎖依頼したとき、または `/git-create-branch-commit-pr` として明示呼び出しされたときに起動する。`git-branching` → `git-commit` → `git-pull-request` を順次実行する composition skill。
model: haiku
---

# Git Workflow Chain Skill

ブランチ作成 → コミット → PR 作成を一気通貫で実行する composition skill。各ステップの実体は個別 skill に委ねる。

## 発火タイミング

- 実装完了、main に戻る前に「ブランチ作ってコミットして PR 出して」の流れを一括で
- `/git-create-branch-commit-pr` として明示呼び出し

## 手順

次を順次実行。いずれかで失敗したら **停止してユーザーに報告**:

1. **`git-branching` skill を起動** — 現ブランチが main / master なら新ブランチを作る
2. **`git-commit` skill を起動** — 変更を atomic 粒度でコミット
3. **`git-pull-request` skill を起動** — 保護ブランチでない現ブランチから PR を作る

各 skill のルールはそれぞれを参照する。この skill は orchestration 責務のみ持つ。

## 引数の分配

`$ARGUMENTS` が渡された場合、各 skill が自分の引数を認識する前提で分配:

- `-d` / `--dry-run` / `-p` → `git-branching`
- `-y` / `-a` / `-s` / `-e` → `git-commit`
- タイトル候補文字列 → `git-pull-request`

判別できない引数はユーザーに確認する。

## Iron Law

- 途中失敗時は **続行しない**。次の skill を起動する前に必ず検証
- 本 skill は composition のみ。実処理は個別 skill に委ねる（重複定義しない）
- 個別 skill の Iron Law（main 中断、保護ブランチ拒否等）はすべて継承される

## 関連

- `git-branching` / `git-commit` / `git-pull-request`
