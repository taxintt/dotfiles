---
name: session-pattern-extraction
description: セッションで non-trivial な問題を解決した直後、将来の再利用価値を感じたとき、またはユーザーが `/learn` として明示呼び出ししたときに起動する。session から再利用可能なパターンを抽出し、ユーザー承認後に `~/.claude/skills/learned/` へ保存する。
model: sonnet
---

# Session Pattern Extraction Skill

現在のセッションで解決した non-trivial な問題から、将来のセッションで使える再利用パターンを抽出して skill 化する。

## 発火タイミング

- 非自明な問題（ライブラリの癖、バージョン依存の挙動、複雑なデバッグ）を解決した直後
- 「これは他でも使えそう」と感じたとき
- ユーザーが明示的に `/learn` と呼んだとき

## 本 skill と `skill-create` の違い

| 観点 | この skill (`session-pattern-extraction`) | `skill-create` |
|---|---|---|
| トリガー | 事後抽出（解けた問題から） | 事前計画（作りたい規律から） |
| 検証 | 軽量（ユーザー確認のみ） | RED/GREEN/REFACTOR 必須 |
| 保存先 | `~/.claude/skills/learned/` | `.claude/skills/` |
| 用途 | メモ的な再利用ノート | 本格的な規律 skill |

**本格的な skill 化が必要なら `skill-create` を使う**。本 skill は軽量な「学びメモ」に徹する。

## 抽出対象

1. **エラー解決パターン** — どんなエラーで、根本原因は何で、何が効いたか
2. **デバッグ手法** — 非自明な手順、ツールの組合せ
3. **回避策** — ライブラリの癖、API の制約、バージョン依存の挙動
4. **プロジェクト固有パターン** — 既存コードベースの規約、設計判断、統合手順

## 除外対象

- typo / 単純な構文エラー
- 一度きりの事象（特定 API 障害など）
- 他 skill / CLAUDE.md / rules で既にカバー済み
- 既存 `~/.claude/skills/learned/` 配下と重複するもの（事前に grep 確認）

## 手順

1. セッションを振り返り、抽出可能なパターンを特定
2. **最も価値の高い 1 つに絞る**（複数ファイル化しない）
3. `~/.claude/skills/learned/` 配下に同名 / 類似パターンが無いか grep で確認
4. 下記フォーマットでドラフトを書く
5. **保存前にユーザーに確認**（承認は `yes` / `ok` / `approve` / 「承認」のみ。それ以外は破棄）
6. 承認後、`~/.claude/skills/learned/<kebab-case-name>.md` に保存（ディレクトリが無ければ作成）

ファイル名は kebab-case、3-5 語が目安。

## 出力フォーマット

```markdown
# <パターン名>

**Extracted:** <ISO 日付>
**Context:** <適用される状況を 1-2 行>

## Problem
<何を解決するか>

## Solution
<パターン / 技法 / 回避策>

## Example
<コード例があれば>

## When to Use
<トリガー条件>
```

## Iron Law

- **保存前承認**: ホワイトリスト以外の応答は破棄（skill ファイル作成しない）
- **1 セッション 1 パターン**: 複数抽出は別セッションに回す
- **重複回避**: 保存前に既存 `learned/` を必ず確認

## 関連

- 本格的な skill 作成: `skill-create` skill
