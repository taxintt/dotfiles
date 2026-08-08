---
name: codex-delegation
description: 実装タスクを Codex CLI に委譲する。Claude Code が orchestrator (計画・レビュー・検証ゲート) を担い、`codex exec` で実装を実行させる。「Codex に投げて」「Codex で実装して」と依頼されたとき、または `/delegate <task>` として明示呼び出しされたときに起動する (`/codex` は openai-codex プラグイン側のコマンドなので使わない)。
---

# Codex Delegation Skill

Claude Code = orchestrator (計画 / タスク分解 / レビュー / 検証ゲート)、Codex = implementer (コード実装) の分業を行う。

## 前提

- `codex` CLI がインストール済み (BrewFile) で、`codex login` による ChatGPT 認証済みであること
- 未認証・未インストールなら委譲せず、その旨をユーザーに伝えて中断する

## 委譲粒度の判断基準

| 条件 | 方式 |
|---|---|
| 影響 1-2 ファイル / 仕様が一意に定まる | **小タスク単位**: そのまま 1 タスクとして委譲し、都度 diff レビュー |
| 影響 3 ファイル以上 / 設計判断を含む | **分解して逐次委譲**: `implementation-planning` で計画 → 小タスク列に分解 → 1 つずつ委譲 |
| 独立した feature 一式 / 雛形生成 | **feature 丸ごと委譲**: 1 プロンプトで委譲し、最後にまとめてレビュー |

迷ったら小タスク単位。レビュー不能な巨大 diff を作らせないことを優先する。

## 実行パターン

1. **計画** — タスクを分解し、各タスクの完了条件 (通るべきテスト / 期待される変更) を定義する
2. **委譲** — 下記フォーマットのプロンプトで `codex exec` を実行する
3. **レビュー** — `git diff` を確認し、規約違反 / 過剰実装 (slop) / セキュリティ問題をチェックする
4. **検証** — lint / test を明示的に実行する (下記「検証ゲートの注意」)
5. **修正** — 問題があれば修正指示を添えて再委譲する。軽微なら Claude が直接修正する
6. 全タスク完了まで 2-5 を繰り返す

### コマンド

```bash
codex exec --sandbox workspace-write --cd <repo-root> "<prompt>"
```

- `--cd` には対象リポジトリのルートを指定する
- 長時間かかるタスクは Bash の `run_in_background` で実行し、完了を待って次に進む

### 委譲プロンプトフォーマット

```
## Task
<やること 1 文>

## Context
<前提 / 関連ファイル / 踏襲すべき既存パターンへの参照>

## Constraints
- 最小限の実装。依頼外のリファクタ・機能追加・ドキュメント追加禁止
- <タスク固有の制約>

## Done when
<完了条件: 通るべきテスト / 期待される変更>
```

## 検証ゲートの注意 (Iron Law)

Codex による編集は Claude 側からは Bash 実行にしか見えず、`PostToolUse (Edit|Write)` の lint hook を**通らない**。したがって委譲後は必ず:

1. `git diff --stat` + `git diff` で全変更をレビューする
2. 言語別の lint / test を明示的に実行する (Go → `golang-build-fixing` / Terraform → `terraform-validation`)
3. デバッグコード残置・ハードコードされたシークレットがないか `rg` で確認する

これを省略して「Codex がやったので OK」とすることを禁止する。完了報告前は `verification-before-completion` skill の対象。

## 関連

- 長時間の自走実装 (Goal mode + agmsg advisor): `codex-goal-handoff` skill
- 計画: `implementation-planning` skill
- レビュー振り分け: `code-review-routing` skill
- agent 連鎖に組み込む場合: `agent-orchestration` skill (実装フェーズを本 skill に置換できる)
- Codex 側の規約: `AGENTS.md` (CLAUDE.md から `make rule-sync` で生成)
