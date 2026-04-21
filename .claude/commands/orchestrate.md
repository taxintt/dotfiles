---
description: 複雑タスクを複数エージェントの順次連鎖で実行する。workflow 種別に応じて agent を直列呼び出しし、handoff でコンテキストを受け渡す
argument-hint: "<workflow-type> <task-description>"
---

# /orchestrate

複雑タスクを事前定義された agent 連鎖で実行する。

## 引数

`$ARGUMENTS` は `<workflow-type> <task-description>` 形式で解釈する。

- `feature <desc>` — 機能実装
- `bugfix <desc>` — バグ調査 + 修正
- `refactor <desc>` — リファクタリング
- `security <desc>` — セキュリティレビュー
- `custom <agents> <desc>` — カスタム連鎖（`agents` はカンマ区切り、例: `architect,tdd-guide,code-reviewer`）

## workflow 種別と agent 連鎖

| 種別 | 連鎖 |
|------|------|
| feature | planner → tdd-guide → code-reviewer → security-reviewer |
| bugfix | planner → tdd-guide → code-reviewer |
| refactor | architect → tdd-guide → code-reviewer |
| security | security-reviewer → code-reviewer → architect |

深い調査が必要なら、planner の前に Task ツールで `subagent_type=Explore` を起動して調査結果を持ち込むこと。

## 実行パターン

各 agent に対して次を繰り返す:

1. **agent 起動** — 前段の handoff を context として渡す
2. **出力を収集** — 構造化 handoff ドキュメントとして保持
3. **次の agent に渡す**
4. **最終 agent は Final Report を生成**

中間の受け渡しは HANDOFF 形式、最終成果物のみ Final Report 形式。ファイル化はせず、会話上のメッセージとして扱う。

## HANDOFF フォーマット（中間）

```markdown
## HANDOFF: <previous-agent> → <next-agent>

### Context
<前段の作業要約>

### Findings
<鍵となる発見 / 決定>

### Files Modified
<変更ファイル一覧>

### Open Questions
<次の agent に委ねる未解決事項>

### Recommendations
<次のアクション候補>
```

## Final Report フォーマット（最終）

```markdown
ORCHESTRATION REPORT
====================
Workflow: <type>
Task: <description>
Agents: <chain>

SUMMARY
-------
<1 段落の総括>

AGENT OUTPUTS
-------------
<各 agent の要約>

FILES CHANGED
-------------
<変更ファイル>

TEST RESULTS
------------
<テスト成否>

SECURITY STATUS
---------------
<セキュリティ所見>

RECOMMENDATION
--------------
SHIP / NEEDS WORK / BLOCKED
```

## 並列実行（オプション）

ユーザーが明示的に「並列で」と指示した場合、または独立性が明らかな場合のみ並列化できる:

```markdown
### Parallel Phase
以下を同時起動:
- code-reviewer（品質）
- security-reviewer（セキュリティ）
- architect（設計）

### Merge
結果を統合して単一レポートにする
```

暗黙の並列化は禁止（コンテキスト齟齬の温床）。

## 運用のヒント

- 複雑機能は **planner で開始**
- merge 前に **code-reviewer を必ず含める**
- 認証 / 決済 / PII を触るなら **security-reviewer を必ず含める**
- HANDOFF は簡潔に：次の agent が必要なものだけ
- agent 間で検証（テスト / ビルド）を挟むと齟齬を早く検知できる
