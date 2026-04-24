---
name: agent-orchestration
description: 複雑タスクを複数 agent の連鎖で実行する。`/orchestrate <workflow-type> <task>` として明示呼び出しされたとき、または feature / bugfix / refactor / security のような multi-phase 作業を一括で進めたいときに起動する。
---

# Agent Orchestration Skill

複雑タスクを事前定義された agent 連鎖で実行し、HANDOFF で context を受け渡す。

## 発火タイミング

- 機能実装（planner → tdd-guide → code-reviewer → security-reviewer）を一括実行したい
- バグ調査 + 修正を段階的に進めたい
- リファクタで設計 → 実装 → レビューを連鎖させたい
- セキュリティレビューを多視点で実施したい
- ユーザーが明示的に `/orchestrate` と呼んだとき

## 引数解釈

`<workflow-type> <task-description>` 形式:

- `feature <desc>` — 機能実装
- `bugfix <desc>` — バグ調査 + 修正
- `refactor <desc>` — リファクタリング
- `security <desc>` — セキュリティレビュー
- `custom <agents> <desc>` — カスタム連鎖（`agents` はカンマ区切り、例: `architect,tdd-guide,code-reviewer`）

## workflow 種別と agent 連鎖

| 種別 | 連鎖 |
|---|---|
| feature | planner → tdd-guide → code-reviewer → security-reviewer |
| bugfix | planner → tdd-guide → code-reviewer |
| refactor | architect → tdd-guide → code-reviewer |
| security | security-reviewer → code-reviewer → architect |

深い調査が必要なら planner の前に `Task(subagent_type=Explore)` を挟むこと。

## 実行パターン

各 agent に対して:

1. **agent 起動** — 前段の HANDOFF を context として渡す
2. **出力を収集** — 構造化 HANDOFF ドキュメントとして保持
3. **次の agent に渡す**
4. **最終 agent は Final Report を生成**

中間: HANDOFF 形式 / 最終: Final Report 形式。ファイル化はせず、会話上のメッセージとして扱う。

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

**暗黙の並列化は禁止**（context 齟齬の温床）。

ユーザーが明示的に「並列で」と指示した場合、または独立性が明らかな場合のみ並列化:

```markdown
### Parallel Phase
以下を同時起動:
- code-reviewer（品質）
- security-reviewer（セキュリティ）
- architect（設計）

### Merge
結果を統合して単一レポートにする
```

## 運用のヒント

- 複雑機能は **planner で開始**
- merge 前に **code-reviewer を必ず含める**
- 認証 / 決済 / PII を触るなら **security-reviewer を必ず含める**
- HANDOFF は簡潔に: 次の agent が必要なものだけ
- agent 間で検証（テスト / ビルド）を挟むと齟齬を早く検知できる

## Iron Law: HANDOFF を省略しない

「速く終わらせたい」という rationalization で HANDOFF を省くと、次 agent が前提を取り違えて手戻りが増える。**HANDOFF は短くても書く**。

## 関連

- Planning: `implementation-planning` skill
- Review routing: `code-review-routing` skill
