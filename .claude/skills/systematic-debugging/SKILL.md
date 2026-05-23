---
name: systematic-debugging
description: テスト失敗 / 本番バグ / 想定外挙動 / パフォーマンス問題 / ビルド失敗 / integration 問題に直面したとき、修正前に体系的な根本原因調査を強制する。`/debug` として明示呼び出しされたときも起動する。
model: opus
---

# Systematic Debugging Skill

修正に手をつける前に、4 フェーズの root cause 調査を強制する。言語・stack 非依存。

## Iron Law

> **「修正前に常に root cause を特定する。症状の対症療法は失敗である。」**

Phase 1 完了前の修正提案・実装は禁止。

**例外なし**:
- 「明らかな typo だから直す」 → Phase 1 を 1 分で完了して根拠を確認してから
- 「先に直してダメなら戻す」 → 因果が追えなくなる、禁止
- 「症状を消せば十分」 → 再発する、root cause を特定
- 「過去にも同じ修正で直した」 → 同じ症状でも別 root cause の場合がある

## 発火タイミング

- テスト失敗 (新規・regression 問わず)
- production / staging のバグ報告
- 想定外の挙動 (silent failure 含む)
- パフォーマンス問題 (latency / memory / CPU)
- ビルド失敗 (Go なら `golang-build-fixing` を Phase 4 で併用)
- integration 問題 (複数サービス間)
- 過去 3 回以上同じ問題で修正失敗 — architecture 議論に切替

時間プレッシャー下、問題が単純に見えるとき、過去の修正が失敗したときに **特に必須**。

## 4 Phase Workflow

各 Phase は **完了条件** を満たすまで次に進めない。

### Phase 1: Root Cause Investigation

- エラーメッセージを 1 字 1 句精読 (省略・要約しない)
- 再現手順を確立、最小再現コードを得る
- 直近の変更 (`git log --since`, `git diff`) をレビュー
- 複数コンポーネント系では各層のログ・状態を収集
- データフローを問題地点から起点まで **逆追跡**
- 環境差分 (local / staging / prod) を列挙

**完了条件**: 「なぜこの症状が出るか」を 1 文で説明できる。説明できないなら Phase 1 継続。

### Phase 2: Pattern Analysis

- コードベース内の動作例を `grep` で特定
- 動作版 (古い commit / 別ブランチ) と壊れた版の差分を抽出
- 参照実装 (公式 doc, library example) と比較
- 暗黙の前提・依存を明示化

**完了条件**: 同じパターンの他箇所が同じ問題を起こしうるか判定できる。

### Phase 3: Hypothesis & Testing

- 「X が原因なら Y が真のはず」というテスト可能な仮説を立てる
- 各仮説に対して **最小変更** を作る (本番コードは変えない、ローカル検証)
- 結果を観察、仮説を確認 / 棄却
- 知識のギャップを認める (「ここは想定で動いていた」を口に出す)

**完了条件**: 1 つの仮説が決定的に確認された。

### Phase 4: Implementation

- 失敗するテストを **先に作成** (`tdd-workflow` + `regression-testing.md` を併読)
- 1 件ずつ修正、各修正後に test を走らせる
- 主張 (「修正済み」「直りました」) の前に必ず **`verification-before-completion`** を発火
- 3 件以上の修正が必要な場合は STOP し architecture 議論に切替

## Red Flags — STOP せよ

- 調査せずに「とりあえず直す」
- 複数の変更を同時投入 (1 commit で 5 箇所変更している)
- テスト作成をスキップ
- 「動いてるからヨシ」(完全に理解できていない)
- 同じ修正を 3 回以上試行している
- 「なぜそれで直ったか分からないが直った」
- 「本番では再現しないからローカルで OK」

これらが出たら: 削除して Phase 1 からやり直す。

## Rationalization Table

Pressure 下で出やすい言い訳と反論。

| 言い訳 | 反論 |
|---|---|
| 「単純そうだから調査不要」 | 単純さは原因特定の根拠にならない。Phase 1 を実施 |
| 「直せば原因がわかる」 | 因果が追えなくなる。Phase 1 完了が先 |
| 「症状を消せば十分」 | 再発する。root cause を特定 |
| 「3 回直したのにまだ落ちる」 | architecture を疑い議論に切替。patching 継続は禁止 |
| 「typo だから速攻で直す」 | typo に見えても Phase 1 を 1 分で完了。例外を作らない |
| 「時間がない」 | 推測で複数回直すほうが時間を浪費する。4 Phase は最短経路 |
| 「過去の同じバグの修正をコピペ」 | 同じ症状でも別 root cause の場合がある。Phase 1-2 を実施 |
| 「production だけで再現、ローカルでは出ない」 | 環境差分を Phase 1 で列挙。憶測の修正は禁止 |
| 「コードレビュアーが見るからとりあえず PR」 | 本 skill のゲートはレビュー前。PR は Phase 4 完了後 |

これらが頭に浮かんだら、書きかけの修正を削除して Phase 1 からやり直す。

## 出力フォーマット

```text
# Systematic Debugging

## Phase 1: Root Cause
- Symptom: <1 文で症状>
- Reproduction: <最小再現手順>
- Recent changes: <怪しい commit / PR>
- Data flow trace: <逆追跡の結果>
- Cause hypothesis: <1 文で root cause>

## Phase 2: Pattern Analysis
- Working example: <参照箇所>
- Diff with broken version: <差分要約>
- Other potentially affected sites: <grep 結果>

## Phase 3: Hypothesis Testing
- Hypothesis 1: <仮説> / Test: <検証方法> / Result: <確認 / 棄却>
- ...

## Phase 4: Implementation
- Failing test: <テストファイル>
- Fix: <最小修正内容>
- Verification: verification-before-completion ゲート通過を確認
```

## Hypothetical RED Baseline

`skill-create` の Iron Law に従い、初版時点で想定 pressure scenario を明記する (実 subagent baseline は `empirical-prompt-tuning` で別途取得)。

**Pressure scenario**:
> Production で API がランダムに 500 を返している。SRE オンコールから「1 時間以内に直してくれ」と要求。直近 24 時間で merge された PR が 3 件ある。テストはローカルで全部 pass。あなたは別タスクの途中で、context switch 直後。

**想定 rationalization (counter は本文に対応)**:
1. 「直近 PR 3 件のうち怪しい 1 件をまず revert、それで直れば原因特定」 → revert は Phase 1 完了後の Phase 3 仮説検証として位置づける。最初の手段にしない (Rationalization Table「直せば原因がわかる」の counter)
2. 「ログに NullPointerException があるから null チェックを足せば直る」 → 症状対処、root cause 不明のまま (「症状を消せば十分」の counter)
3. 「とりあえず再起動で復旧、原因は後で調査」 → 再現性・データフロー追跡なし、Phase 1 違反 (発火タイミング「過去 3 回以上失敗」の前段階で root cause 必須)

このシナリオは subagent baseline 取得後に、観察された rationalization を Rationalization Table に追記して強化する。

## 関連

- **`tdd-workflow`** + `regression-testing.md` — Phase 4 の失敗テスト先行 / 逆フェーズ検証
- **`verification-before-completion`** — Phase 4 完了主張前の必須ゲート
- **`golang-build-fixing`** — Go ビルドエラー時の Phase 4 修正手順を当該 skill に委譲
- **`code-review-routing`** — Phase 1 で他者レビューが必要なときのルーティング
- 上流参考: `obra/superpowers` の `systematic-debugging` skill
