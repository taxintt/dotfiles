# Git Workflow Chain Skill

ブランチ作成 → コミット → PR 作成を一気通貫で実行する。

## 発火タイミング

- ブランチ作成だけを依頼されたとき
- 「ブランチ作ってコミットして PR 出して」の流れをまとめて依頼されたとき

## ブランチ作成規約

- 作成前に `git status` と現ブランチ・同名ブランチの有無を確認する。
- 名前は `<prefix>/<説明>`。prefix は `feature` / `fix` / `hotfix` / `release` / `chore`、説明は英語のkebab-case（50文字以内）。チケット番号があれば説明の前に付ける。
- 変更内容と依頼から名前を決め、判断できなければ確認する。`-p` / `--prefix` でprefixを指定できる。
- `git switch -c <name>` で作成する。`-d` / `--dry-run` は名前の提案のみで終了し、コミット・PR作成も実行しない。

## 手順

いずれかで失敗したら停止してユーザーに報告する:

1. 現ブランチが main / master、または新規ブランチの作成を依頼された場合は、上記規約に従って作成する。
2. `git-commit` skill で変更をatomicな粒度でコミットする。
3. `git-pull-request` skill で保護ブランチでない現ブランチからPRを作る。

コミット・PRの規約は各skillを参照する。ブランチ作成だけの依頼なら、ブランチ作成後に終了する。

## 引数の分配

- `-d` / `--dry-run` / `-p` / `--prefix` → ブランチ作成
- `-y` / `-a` / `-s` / `-e` → `git-commit`
- タイトル候補文字列 → `git-pull-request`

判別できない引数はユーザーに確認する。

## Iron Law

- 各ステップの結果を確認してから次に進む。
- 個別skillのmain中断・保護ブランチ拒否などの規約を継承する。

## 関連

- `git-commit` / `git-pull-request`
