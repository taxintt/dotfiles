---
name: implementation-planning
description: 新機能の開始、大きなアーキテクチャ変更、複雑リファクタ、複数ファイルに跨る変更など、要件が曖昧または広いタスクに取り組む前に起動する。planner エージェントを呼び出して段階計画を作成し、ユーザーが明示承認するまでコードを書かない。`/plan` として明示呼び出しされたときも起動する。
---

# Implementation Planning Skill

コードを書く前に要件・リスク・段階計画を整理し、**承認ゲート**を必ず通す規律。

## この skill の責務と限界

- **責務**: 承認ゲートの保持 + 出力フォーマットの固定化 + `planner` agent への委譲
- **限界**: 実際の planning ロジックは `planner` agent が担う。この skill は再帰的に自分自身を呼び返してはならない

## 発火タイミング

- 新機能の開始
- 大きなアーキテクチャ変更
- 複雑なリファクタ
- 複数ファイル / コンポーネントに跨る変更
- 要件が曖昧なとき
- ユーザーが明示的に `/plan` と呼んだとき

## 手順

1. **要件の言い直し** — 実装すべきものを明確化
2. **リスクの抽出** — 潜在的なブロッカーを表面化
3. **段階計画の作成** — フェーズ単位で分解（各フェーズは具体アクション）
4. **承認待ち** — 以下のホワイトリストに一致する応答を受け取るまで待機

`planner` agent (`~/.claude/agents/planner.md`) を起動し、上記手順を委譲する。agent 呼び出しプロンプトにホワイトリストと変更プロトコルを明示する。

## 承認ホワイトリスト

`yes` / `ok` / `proceed` / `go` / `approve` / 「承認」 / 「進めて」

**それ以外は再確認する**。曖昧な応答で自動承認したと解釈してはならない（Iron Law）。

## 変更依頼プロトコル

- `modify: <変更内容>` — 計画を部分修正
- `different approach: <代替案>` — 方針転換
- `skip phase N` / `reorder: N, M, ...` — フェーズ操作

## 出力フォーマット

```text
# Implementation Plan: <タイトル>

## Requirements Restatement
- <要件 1>
- <要件 2>

## Implementation Phases

### Phase 1: <名前>
- <アクション 1>
- <アクション 2>

### Phase 2: <名前>
...

## Dependencies
- <外部サービス / ライブラリ / 既存モジュール>

## Risks
- HIGH: <リスク>
- MEDIUM: <リスク>
- LOW: <リスク>

## Estimated Complexity: HIGH / MEDIUM / LOW

**WAITING FOR CONFIRMATION**: 上記プランで進めてよいか？
```

## Iron Law: 承認前にコードを書かない

**計画が承認されるまでコードには一切触れない**。「計画と同時に少しだけ試す」「明らかに必要だから先に書く」といった rationalization を許さない。

### 典型的な rationalization とその対処

| Rationalization | 対処 |
|---|---|
| 「計画は頭の中で済ませた」 | skill 発火タイミングに合致するなら必ず明文化する |
| 「小さい変更だから skip」 | 複数ファイル / 不慣れなコードなら必ず起動 |
| 「承認は暗黙で OK」 | ホワイトリスト一致以外は再確認 |
| 「ユーザーが早く始めたがっている」 | 承認プロトコルを示すことで結果的に速くなる |

## 連携 skill

- 承認後の実装: `tdd-workflow`（`/ts-tdd` / `/go-tdd`）
- ビルド修復: `golang-build-fixing`（Go プロジェクトでビルドが失敗したとき）
- レビュー: `code-review-routing` / `golang-patterns` の Review Workflow

## 関連

- Agent: `~/.claude/agents/planner.md`
