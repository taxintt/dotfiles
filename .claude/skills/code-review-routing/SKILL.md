---
name: code-review-routing
description: 未コミット変更に対する包括的レビュー。言語を検出して `code-reviewer` / `security-reviewer` agent または `golang-patterns` (Go) に振り分ける。`/code-review` として明示呼び出しされたときも起動する。
---

# Code Review Routing Skill

未コミット変更に対して適切なレビュー経路を選択し、観点の漏れを防ぐ。

## 発火タイミング

- 変更を commit する直前
- コードを書いた / 変更した直後
- PR を作る前の最終確認
- ユーザーが明示的に `/code-review` と呼んだとき

## 動作

1. **変更ファイル取得**
   ```bash
   git diff --name-only HEAD
   git diff --staged --name-only
   ```
   どちらも空なら「変更なし」と報告して終了。

2. **言語分岐**
   - `.go` を含む → `golang-patterns` skill の Review Workflow を起動（`/go-review` 相当）、`go-reviewer` agent に委譲
   - `.ts` / `.tsx` / `.js` / `.jsx` 中心 → 下記チェックリストを適用、`code-reviewer` agent に委譲
   - `.py` / `.rb` 等 → 言語非依存項目のみ適用、`code-reviewer` agent に委譲
   - 複数言語混在 → 言語ごとに分割してそれぞれ適切経路へ

3. **agent 委譲**
   - 包括レビュー: `code-reviewer` agent (`~/.claude/agents/code-reviewer.md`)
   - セキュリティ: `security-reviewer` agent (`~/.claude/agents/security-reviewer.md`)
   - どちらかが適切なのに未起動なら「起動推奨」を明示して返す

4. **レポート**: 重篤度別に結果を整理

## チェックリスト

### CRITICAL（必ず報告）
- ハードコードされた credentials / API key / token
- SQL injection（パラメタ化されていないクエリ）
- XSS / CSRF / path traversal
- 入力検証の欠落（システム境界）
- 並行安全性の欠陥（race condition、unbounded map、global state）
- Insecure dependencies

### HIGH（強く推奨）
- エラーハンドリングの欠落 / エラーの握り潰し
- 関数 > 50 行 / ファイル > 800 行
- ネスト > 4 階層
- デバッグ文の残留（`console.log` / `fmt.Println` / `print`）
- 公開 API の docstring / godoc / JSDoc 欠落
- テスト欠如（新規 / 変更された公開 API）

### MEDIUM（検討）
- 命名 / 可読性
- 重複コード
- 既存パターンとの不整合
- a11y（ブラウザ UI 変更時のみ）
- mutation パターン（JS/TS）
- Emoji 使用（CLAUDE.md 原則: ユーザーが明示しない限り禁止）

## 出力フォーマット

```markdown
## 対象
- 変更ファイル: <path 1> / <path 2> / ...
- 言語: <検出結果>
- 委譲推奨: <code-reviewer / security-reviewer / golang-patterns 等>

## 重要度: CRITICAL
- <path:line>
  - 問題: <具体>
  - 理由: <根拠>
  - 修正案: <具体>

## 重要度: HIGH
...

## 重要度: MEDIUM
...

## 良い点
- <評価点>

## アクション
- CRITICAL / HIGH は commit 前修正を強く推奨（警告。ブロックは権限外）
- 該当 agent / 専用 skill の使用を提案
```

## 禁止事項

- 発生していない問題の推測報告
- Go 固有チェック（race condition 深掘り等）を本 skill でやろうとしない → `golang-patterns` の Review Workflow に送る
- ユーザー確認なしに `git commit` 等を勝手に実行

## 関連

- Go 専用: `golang-patterns` skill の Review Workflow 節
- Agents: `code-reviewer` / `security-reviewer`
