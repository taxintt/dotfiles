---
description: 未コミット変更に対するセキュリティ / 品質レビュー。言語別に適切な専用コマンド / エージェントに委譲する
---

# /code-review

未コミットの変更に対して包括的レビューを行う。CRITICAL / HIGH は警告として報告するが、commit をプログラム的にブロックはしない（権限外）。

## 動作

1. **変更ファイルの取得**
   - `git diff --name-only HEAD` で対象ファイル一覧を取得
   - staged / unstaged の両方を対象（空なら「変更なし」を報告して終了）

2. **言語分岐**
   - `.go` ファイルが含まれる → `/go-review` または `go-reviewer` エージェントの使用を推奨
   - `.ts` / `.tsx` / `.js` / `.jsx` が中心 → 下記の TS/JS 観点でレビュー
   - `.py` / `.rb` 等その他言語 → 言語非依存の項目のみ適用
   - 複数言語が混在 → 言語ごとに分割して適切なレビュー経路を提示

3. **エージェント委譲**
   - 包括的レビューは `code-reviewer` エージェントに委譲
   - セキュリティ観点は `security-reviewer` エージェントに委譲
   - どちらかを使うべきなのに未起動なら、明示的に「起動推奨」を返す

4. **レビュー実行**（委譲先がない場合の直接レビュー）
   - 下記チェックリストを適用
   - 結果を重篤度別にレポート

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
- デバッグ文の残留（言語別: `console.log` / `fmt.Println` / `print` 等）
- 公開 API の docstring / godoc / JSDoc 欠落
- テスト欠如（新規 / 変更された公開 API）

### MEDIUM（検討）
- 命名 / 可読性
- 重複コード
- 既存パターンとの不整合
- a11y（ブラウザ UI 変更時のみ）
- mutation パターン（JS/TS で immutable 推奨が有効な場合）
- Emoji 使用（ユーザーが明示しない限り禁止という CLAUDE.md 原則あり）

## 出力フォーマット

```markdown
## 対象
- 変更ファイル: <path 1> / <path 2> / ...
- 言語: <検出結果>
- 委譲推奨: <code-reviewer / security-reviewer / go-review 等>

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
- CRITICAL / HIGH が検出された場合は、コミット前に修正を強く推奨する（警告。権限上ブロックはできない）
- 該当エージェント / 専用コマンドの使用を提案
```

## 禁止事項

- 発生していない問題の推測報告
- `/go-review` 相当の Go 固有チェックをこのコマンドでやろうとしない（race condition の指摘は CRITICAL として言及してよいが、深堀りは `/go-review` に送る）
- ユーザーに確認せず `git commit` 等を勝手に実行する

## 関連

- `/go-review` — Go コード専用
- エージェント: `~/.claude/agents/code-reviewer.md`、`~/.claude/agents/security-reviewer.md`
