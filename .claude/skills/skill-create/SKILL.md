---
name: skill-create
description: skill の新規作成、既存 skill の編集、デプロイ前の検証を行うときに使う。pressure scenario で baseline を観察していないなら発火する。
---

# Skill Creation

## Overview

**Skill を書くことは、process documentation に対する Test-Driven Development である。**

Pressure scenario を subagent で走らせ (test case)、baseline 挙動が失敗することを観察し (RED)、その失敗を潰す skill を書き (GREEN)、新たな rationalization を見つけたら loophole を塞ぐ (REFACTOR)。

**核心原則**: skill なしで agent が失敗する様を見ていないなら、その skill が正しいことを教えているかどうか分からない。

**必須背景**: `tdd` / `tdd-workflow` skill が定義する RED-GREEN-REFACTOR サイクルを理解していることが前提。この skill はその方法論を documentation に適用する。

## What is a Skill?

Skill は「再利用可能なテクニック・パターン・ツール・リファレンス」である。将来の agent が effective なアプローチを発見・適用できるよう書かれた reference guide。

- **Skill である**: reusable technique / pattern / tool / reference
- **Skill ではない**: 「一度問題を解いたときの narrative」「session ログ」

## TDD Mapping for Skills

| TDD Concept | Skill Creation |
|---|---|
| Test case | Pressure scenario with subagent |
| Production code | SKILL.md |
| RED (test fails) | Skill なしで agent が rule 違反 |
| GREEN (test passes) | Skill ありで agent が遵守 |
| REFACTOR | Loophole を塞ぎつつ compliance を維持 |
| Write test first | Skill を書く前に baseline scenario を実行 |
| Watch it fail | Agent が使う rationalization を逐語的に記録 |
| Minimal code | その rationalization を潰すだけの skill を書く |
| Watch it pass | Agent が遵守することを確認 |
| Refactor cycle | 新 rationalization → counter 追加 → 再検証 |

Skill 作成プロセス全体が RED-GREEN-REFACTOR に従う。

## When to Create a Skill

**作る**:
- 自分にとって intuitively obvious ではなかったテクニック
- 複数プロジェクトで再参照する
- パターンが広く適用可能 (project-specific ではない)
- 他の agent にも役立つ

**作らない**:
- 一回限りの解決策
- 既に標準プラクティスとして well-documented なもの
- Project-specific な規約 (CLAUDE.md に置く)
- Mechanical constraint: regex / hook / validation で強制可能なら、そちらで自動化する (skill は判断を要する内容に限る)

## Skill Types

| Type | 内容 | テスト方法 | 成功基準 |
|---|---|---|---|
| **Technique** | 手順化された具体手法 (condition-based-waiting) | Application scenario | 新 scenario に正しく適用できる |
| **Pattern** | 思考モデル (flatten-with-flags) | Recognition + counter-example | いつ適用するか / しないか判別できる |
| **Reference** | API / syntax doc | Retrieval + gap test | 求める情報を見つけて正しく適用できる |
| **Discipline** | 規律 (TDD, verify-before-commit) | Pressure scenario (time + sunk cost 等) | 最大 pressure 下でも遵守する |

## The Iron Law

```
NO SKILL WITHOUT A FAILING TEST FIRST
```

新規 skill にも、**既存 skill への edit** にも等しく適用される。

テストなしで skill を書いた? → **削除してやり直せ**。

**例外なし**:
- 「簡単な追加」でも ×
- 「section を一つ足すだけ」でも ×
- 「documentation 更新」でも ×
- テストせず書いたものを「reference」として残すのも ×
- テストを書きながら既存ドラフトを "adapt" するのも ×
- 削除は削除。見るな。

**「letter の違反は spirit の違反」** — この原則が「spirit に従っていればいい」系の rationalization を全部潰す。

### Dispatch 不能環境での Iron Law 適用

新規 subagent を dispatch できない環境 (既に subagent として動作している、Task tool 無効化、time-box で dispatch コスト過剰など) では、以下を **明示した上で** hypothetical RED で代替してよい:
- **Baseline pressure scenario 文** を具体的に書く (3+ pressure 組み合わせ、real constraints、concrete options)
- **想定 rationalization を 3 個以上** 列挙する (「こう言い訳するだろう」を verbatim 風に)
- 本文に「今回は dispatch 不能のため hypothetical RED で実施」と明記する

**依然として NG**:
- 自己再読で代替する (書き手バイアスで loophole を見逃す)
- 手動で実プロジェクトに適用して「動いた」で代替する (書き手は意図を知っているので曖昧文言を補完してしまう)
- 「構造審査クリアしたから empirical 不要」

**「作らない」判断をした場合**: SKILL.md「When to Create」の「作らない」条件 (Mechanical constraint / 既知の標準プラクティス等) に合致するなら、baseline pressure scenario + 想定 rationalization の列挙だけで十分。GREEN / REFACTOR は skill 成果物向けなので skip 可。判断根拠は「該当条項の特定 + 1-2 文の具体理由」の粒度で明示する (例: 「Mechanical constraint に該当。`gofmt` は決定論的 formatter で exit code で強制可能、agent 判断不要」)。条項参照だけでは不十分。

### Hypothetical GREEN / REFACTOR の終了条件

「作る」「refactor する」判断をした場合は hypothetical RED だけでなく GREEN / REFACTOR も実施する:

- **hypothetical GREEN の終了条件**: 列挙した想定 rationalization **全てに対して、draft 内のどこで counter が当たっているか** を対応表で明示できる。1 個でも「draft 内に counter 無し」の rationalization が残っていたら未完了。
- **hypothetical REFACTOR の終了条件**: counter 対応表の各行が Rule negation / Rationalization Table / Red Flags / Description symptom のどれに落ちているか明示できる。単一箇所への counter は「文言が埋もれる」リスクがあるので、discipline skill では 2 箇所以上に重ねる。
- **追加 vs 潰しの自己判別**: refactor の場合、各変更が「元 rationalization を潰す」か「機能追加」かを二値で判別する。機能追加は YAGNI 違反として却下する。

Hypothetical モードは empirical の代替ではなく **縮退運転**。dispatch 可能な環境に戻ったら同じ scenario で実 subagent を走らせ直す。

## File Organization

```
skill-name/
  SKILL.md                    # 必須。Overview + core 内容
  <supporting>.md             # 100+ 行の heavy reference のみ別ファイル化
  <tool>.{sh,py,js}           # Reusable script のみ別ファイル化
```

**Flat namespace**: 1 level までのネスト。検索可能な単一空間に置く。

**Inline で保つ**:
- 原則・概念
- 50 行未満のコードパターン
- それ以外すべて

**別ファイル化する**:
- 100+ 行の heavy reference (API 仕様、syntax 集)
- Reusable tool / script / template

## SKILL.md Structure

### Frontmatter (YAML)

必須フィールド: `name`, `description`

- `name`: letters / numbers / hyphens のみ。動詞ベース (`creating-skills`, `condition-based-waiting`)
- `description`: 三人称、**「いつ使うか」のみ記述する**。**skill の workflow を要約しない**

#### Description の致命的アンチパターン

description に workflow を要約すると、agent は description だけを読んで skill 本文をスキップする。

```yaml
# ❌ 悪い: workflow を要約している
description: plan 実行時、タスクごとに subagent を dispatch して code review する

# ❌ 悪い: process の詳細を入れている
description: TDD — テストを先に書き、失敗を見て、最小実装、refactor する

# ✅ 良い: trigger のみ
description: 実装 plan を session 内で independent task 単位で実行するとき使う

# ✅ 良い: 症状ベース
description: テストに race condition / timing 依存があり、pass / fail が不安定なとき使う
```

### Body Template

```markdown
# Skill Title

## Overview
これは何? 核心原則を 1-2 文で。

## When to Use
- 症状 / trigger の bullet
- 適用してはいけない場面

## Core Pattern (technique / pattern skill の場合)
Before / After のコード比較 (1 つの excellent な例)

## Quick Reference
スキャン用 table / bullet

## Implementation
シンプルな内容は inline、heavy reference は別ファイル link

## Common Mistakes
間違い例 + 修正

## Red Flags (discipline skill の場合)
Rationalization を stop する self-check list

## Rationalization Table (discipline skill の場合)
Baseline で agent が出した言い訳の辞書
```

## Claude Search Optimization (CSO)

### 1. Description は trigger 専用

Agent は description を読んで「この skill を今 load すべきか」を判断する。description が workflow を要約すると、本文を読まずに description に従って行動してしまう。

**「Use when...」/「〜のとき使う」で始める。workflow は body に書く。**

**日本語 skill の場合**: 英語の "Use when..." に等価な接頭は「〜するとき使う」「〜したとき使う」「〜のとき使う」。これで始めれば letter 要件を満たす。"Use when..." の英語前置詞そのものは不要。重要なのは **trigger / 症状のみを述べ workflow を要約しないこと**。

### 2. Keyword カバレッジ

Agent が検索する語を含める:
- Error message: "Hook timed out", "ENOTEMPTY"
- 症状: "flaky", "hanging", "race condition"
- 同義語: "timeout / hang / freeze"
- Tool: コマンド名 / ライブラリ名

### 3. Naming

動詞ベース (active voice, gerund):
- ✅ `creating-skills`, `condition-based-waiting`, `flatten-with-flags`
- ❌ `skill-creation`, `async-helpers`, `data-refactoring` (抽象 / 名詞ベース)

### 4. Token Efficiency

- `getting-started` 系 / 頻繁に load される skill: `<200 words`
- その他: `<500 words` を目指す
- 詳細は tool の `--help` やサブファイルに逃がす

### 5. Cross-Reference

他 skill を参照するときは名前のみ、要求レベルを明示:

- ✅ `**REQUIRED BACKGROUND:** superpowers:test-driven-development`
- ❌ `@skills/testing/test-driven-development/SKILL.md` (force-load で context を浪費)

## RED-GREEN-REFACTOR の要点

詳細な pressure scenario の書き方は [testing-with-subagents.md](testing-with-subagents.md) を参照。

### RED: Baseline を観察する
Skill なしで pressure scenario を subagent に実行させ、**逐語的に記録**:
- どう行動したか
- Rationalization の exact wording
- どの pressure で違反したか

これをスキップすると、何を防げばいいか分からないまま書くことになる。

### GREEN: 最小限の skill を書く
RED で観察した失敗を潰すコンテンツだけ書く。hypothetical には書かない。
同じ scenario を skill ありで再実行し、遵守するか検証する。

### REFACTOR: Loophole を塞ぐ
新しい rationalization が出たら、明示的 counter を追加する:
1. Rule に explicit negation を足す (「例外なし: …も ×、…も ×」)
2. Rationalization Table に 1 行追加
3. Red Flags list に追加
4. Description に違反の symptom を反映

Bulletproof になるまで繰り返す。

## Bulletproofing Against Rationalization

Discipline skill (TDD 等) は rationalization を予想して潰しておく必要がある。Agent は pressure 下で必ず loophole を探す。

### Close Every Loophole Explicitly

単にルールを言うのではなく、具体的な workaround を禁止する:

```markdown
# ❌ 不十分
テスト前にコードを書いたら削除。

# ✅ Bulletproof
テスト前にコードを書いたら削除。やり直し。
**例外なし**:
- 「reference として残す」も ×
- 「test を書きながら adapt する」も ×
- 「見るな」削除は削除
```

### Rationalization Table

Baseline で agent が出した言い訳を辞書化する:

```markdown
| 言い訳 | 現実 |
|---|---|
| 「簡単すぎてテスト不要」 | 簡単なコードも壊れる。テストは 30 秒。 |
| 「後でテストする」 | Tests-after は「何をするか」の確認。Tests-first は「何をすべきか」の仕様。 |
| 「reference として残す」 | adapt してしまうのが分かっている。それは tests-after だ。削除は削除。 |
```

### Red Flags List

Agent が self-check できるよう、違反直前のサインを列挙する:

```markdown
## Red Flags — STOP せよ

- テストを書く前に実装を書いている
- 「すでに手動でテストした」
- 「spirit ではなく letter の話」
- 「今回は違う、なぜなら…」

これらが出たら: 削除。TDD でやり直す。
```

## Anti-Patterns

| Anti-pattern | なぜ悪いか | 修正 |
|---|---|---|
| Narrative example ("前回 foo を解決したとき...") | Specific すぎて再利用不可 | 抽象パターン + 1 つの excellent な例 |
| 多言語例の並列 (.js / .py / .go) | Mediocre が量産される、メンテ負荷 | 最も関連深い 1 言語で excellent な例 |
| Flowchart の中にコード (`step1 [label="import fs"]`) | Copy-paste できない、読めない | Code block に置く |
| Generic label (`helper1`, `step3`, `utils`) | Semantic meaning なし | 具体的な verb-based 名 |
| Deep nesting (SKILL.md → a.md → b.md → c.md) | Discovery できない | Flat、1 level まで |
| Windows-style path (`\`) | 環境依存 | 常に `/` |

## STOP: 次の skill に行く前に

**Skill を書いたら、必ず STOP してデプロイプロセスを完了させる。**

**してはいけない**:
- 複数 skill を batch 作成し後でまとめてテスト
- 現在の skill を検証する前に次 skill に着手
- 「batching のほうが効率的」で skip

**Untested skill のデプロイ = untested code のデプロイ。** 品質基準違反である。

## Checklist

TodoWrite で各項目を todo 化し、順に消化する。詳細は [checklist.md](checklist.md) を参照。

```
RED:
- [ ] Pressure scenario を 3+ pressure 組み合わせで作成
- [ ] Skill なしで scenario を subagent 実行、baseline を逐語記録
- [ ] Rationalization の pattern を identify

GREEN:
- [ ] Frontmatter (name: hyphen のみ、description: "use when...")
- [ ] Baseline failure に対応する最小 skill を書く
- [ ] 同一 scenario を skill ありで再実行し遵守を確認

REFACTOR:
- [ ] 新 rationalization を identify
- [ ] Explicit counter / rationalization table / red flags 追加
- [ ] Bulletproof になるまで再テスト
```

## Red Flags (この skill 自身に対して)

- 「テストなしで書いたほうが早い」→ Iron Law 違反
- 「writing-skills の原則に従ったから大丈夫」→ 書き手の自信と agent の挙動は別。必ず subagent で検証
- 「description に workflow 書いたほうが分かりやすい」→ Skill 本文がスキップされる。Trigger のみ

## 関連

- `tdd-workflow` — RED-GREEN-REFACTOR の前提となる TDD サイクル
- `empirical-prompt-tuning` — skill を書いた後、subagent で反復改善するプロセス
- [testing-with-subagents.md](testing-with-subagents.md) — pressure scenario の書き方 (詳細)
- [checklist.md](checklist.md) — TDD 適応版の品質チェックリスト
