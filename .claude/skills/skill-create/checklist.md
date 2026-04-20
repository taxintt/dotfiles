# Skill 品質チェックリスト (TDD 適応版)

Skill をデプロイする前に、以下を順に検証する。

## RED Phase (baseline test を先に、dispatch 不能時は hypothetical RED 可)

- [ ] Pressure scenario を 3+ pressure 組み合わせで書いた (時間 + sunk cost + 疲労 など)
- [ ] Scenario に具体的な制約 (時刻、行数、deadline) を入れた
- [ ] A/B/C など concrete options を提示した (open-ended にしない)
- [ ] Skill なしで subagent に実行させた **または** dispatch 不能環境で hypothetical RED (想定 rationalization 3+ 列挙) を実施し、本文に「hypothetical 実施」と明記した
- [ ] Agent の選択と rationalization を逐語記録した (hypothetical の場合は「想定 rationalization」として列挙)
- [ ] Rationalization の pattern を identify した

**「作らない」判断の場合**: SKILL.md「When to Create」の「作らない」条件に合致するなら、この RED Phase の列挙のみで完了してよい。GREEN / REFACTOR は skip 可。判断根拠をレポートに明示すること。

## GREEN Phase (skill を書く)

### Frontmatter
- [ ] `name`: letters / numbers / hyphens のみ
- [ ] `name`: 動詞ベース / gerund (`creating-skills`, `condition-based-waiting`)
- [ ] `description`: 三人称
- [ ] `description`: 「Use when...」/「〜のとき使う」で始まる
- [ ] `description`: skill の workflow を要約していない
- [ ] `description`: 具体的な trigger / 症状 / 文脈を含む
- [ ] `description`: ≤ 500 文字を目安

### Body
- [ ] SKILL.md ≤ 500 行
- [ ] Overview で核心原則を 1-2 文
- [ ] Claude が既知の内容を説明していない
- [ ] 等価な選択肢を複数並べていない (1 つ推奨)
- [ ] 一貫した用語
- [ ] 抽象でなく concrete example
- [ ] Code は 1 言語で excellent な 1 例
- [ ] RED で観察した具体的 failure を address している

### Skill Type 判別
- [ ] Technique / Pattern / Reference / Discipline のどれか判別した
- [ ] Discipline skill なら Rationalization Table + Red Flags を入れた

### 検証
- [ ] 同じ scenario を skill ありで subagent 実行した
- [ ] Agent が compliance した

## REFACTOR Phase (loophole を塞ぐ、dispatch 不能時は想定 rationalization で代替可)

- [ ] 新 rationalization が出たか確認した (hypothetical の場合は想定 rationalization に対して counter が当たっているか自己 review)
- [ ] 各 rationalization に explicit counter を追加した
- [ ] Rationalization Table に 1 行追加した (discipline skill)
- [ ] Red Flags list を更新した (discipline skill)
- [ ] Description に違反 symptom を反映した
- [ ] 再テストで compliance を維持した (hypothetical の場合は counter 適用後の draft に対して想定 rationalization を再度当てて自己 review)
- [ ] Meta-test (「skill をどう書き換えれば明確だったか」) を実施した
- [ ] 新 rationalization が出なくなるまで繰り返した

## File Organization

- [ ] Flat namespace (1 level nesting まで)
- [ ] Heavy reference (100+ 行) のみ別ファイル化
- [ ] Reusable script のみ別ファイル化
- [ ] 50 行未満のコードは inline
- [ ] 100+ 行の reference に目次 (table of contents) がある
- [ ] ファイル名が descriptive (`error-handling.md`、`doc2.md` ではない)
- [ ] パスは常に forward slash (`/`)

## Commands (該当する場合)

- [ ] `allowed-tools` が必要なものだけ
- [ ] Description が実挙動と一致
- [ ] 配置場所が正しい (`.claude/commands/` or skill の `commands/`)

## STOP Gate

- [ ] Batch 作成していない (1 skill ずつデプロイ完了)
- [ ] 検証前に次 skill に着手していない
- [ ] Untested な content を残していない

## Red Flags — この checklist 自身に対して

- [ ] 「テストは省略していい、なぜなら…」 → Iron Law 違反
- [ ] 「rationalization table は空でもいい」 → baseline をサボった証拠
- [ ] 「description に workflow 書いたほうが分かりやすい」 → 本文がスキップされる
