---
name: codex-review
description: Runs code review using Codex CLI (codex exec review). Use when the user wants a code review of uncommitted changes, a specific commit, or changes against a base branch. Triggers on requests like "codexでレビュー", "codex review", "review with codex", or "コードレビューをcodexで".
argument-hint: "[--uncommitted | --base <branch> | --commit <sha>] [prompt]"
allowed-tools: Bash
disable-model-invocation: true
model: haiku
---

# Codex Review

Codex CLI (`codex exec review`) を使ってコードレビューを実行するスキル。

## When to Activate

- ユーザーが「codexでレビュー」「codex review」と言ったとき
- 未コミットの変更のレビューを依頼されたとき
- 特定のコミットやブランチとの差分レビューを依頼されたとき

## Quick Reference

| シナリオ | コマンド |
|----------|----------|
| 未コミット変更のレビュー | `codex exec review --uncommitted` |
| ベースブランチとの差分 | `codex exec review --base main` |
| 特定コミットのレビュー | `codex exec review --commit <SHA>` |
| カスタム観点でレビュー | `codex exec review "Focus on error handling"` |
| ヘルプ | `codex exec review --help` |

## Workflow

### Step 1: スコープの確認

引数が指定されていない場合、以下を確認する:

1. **対象**: 未コミット変更 / ブランチ差分 / 特定コミット
2. **観点**: エラーハンドリング・セキュリティ・パフォーマンスなど特定の観点があるか
3. **ベースブランチ**: `--base` を使う場合は `main` か他か

曖昧な場合は `--uncommitted` をデフォルトとして使用する。

### Step 2: レビュー実行

```bash
# 未コミット変更（デフォルト）
codex exec review --uncommitted

# ブランチ全体の変更
codex exec review --base main

# 特定コミット
codex exec review --commit <SHA>

# カスタム観点を追加
codex exec review --uncommitted "セキュリティとエラーハンドリングに注目してレビューしてください"
```

### Step 3: 結果の提示

レビュー結果を以下の形式で整理して提示する:

```
## Codex Review 結果

### Critical / High
- ファイル:行番号 — 問題の説明

### Medium
- ファイル:行番号 — 問題の説明

### Suggestions
- 改善提案

### 良い点
- 評価できる実装
```

修正が必要な場合は、ユーザーの確認を得てから実装に着手する。

## Notes

- codex CLI は `~/.codex/config.toml` の設定を使用する
- モデルを変更したい場合は `-m <model>` オプションを追加する（例: `-m o4-mini`）
- `--full-auto` は低摩擦な自動実行モード（サンドボックス付き）
