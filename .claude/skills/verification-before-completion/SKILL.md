---
name: verification-before-completion
description: 「完了」「修正済み」「テスト合格」「問題なし」と主張する直前、commit / PR 作成の直前に発火する。検証コマンドを fresh に実行し出力を確認した上でしか主張させない。`/verify-claim` として明示呼び出しされたときも起動する。
model: sonnet
---

# Verification Before Completion Skill

「完了 / 合格 / 修正済み」と発言する前に、新鮮な検証証拠を必ず取得するメタゲート。

`verification-loop` が「何を実行するか」、本 skill は「**いつ・なぜ** ゲートを発火するか」のメタ原則を担う。

## Iron Law

> **「新鮮な検証証拠なしに完了主張なし (NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE)」**

Evidence precedes all assertions about task completion.

**例外なし**:
- キャッシュ・記憶からの再利用は無効
- subagent の成功報告も独立確認まで信頼しない
- 「明らかに動いてる」も検証出力で示すまで主張不可
- 「直前に走らせた」も今このターンで再実行
- diff が小さくても fresh 実行を省略しない

## Core Principle

```
NG: 主張 → 検証 → 主張 (検証は事後追認)
OK: 検証 → 出力読解 → 主張 (証拠が主張に先行)
```

Agent は pressure 下で「主張してから検証で確認」の順を選びがちだが、これは Iron Law 違反。**検証出力を読んでから初めて主張を発する**。

## 発火する発言パターン (即停止)

以下を発しようとしたら停止し Gate Function に進む:

「完了」「終わりました」「修正済み」「直りました」「合格」「問題なし」「動くはず」「すべて通った」「Great!」「Perfect!」「Excellent!」「これで OK」「should work」「probably works」「seems to be working」「looks good」「ready for review」

これらは検証証拠が揃ってから **のみ** 発する。

## 5-Step Gate Function (必須シーケンス)

順序を入れ替え不可。各ステップ完了まで次に進まない。

1. **特定** — 主張を裏付ける検証コマンドを言語化する
   - 例: 「テスト合格」 → `npm test -- --coverage`
   - 例: 「ビルド OK」 → `go build ./...` or `npm run build`
   - 例: 「型エラーなし」 → `tsc --noEmit` or `pyright .`
   - 例: 「修正済み」 → 元の bug を再現するテストを fresh 実行

2. **Fresh 実行** — 完全なコマンドを今このターンで実行する
   - キャッシュ・記憶からの出力流用は禁止
   - 「直前に走らせた」も再実行
   - subagent の出力を信じる場合も自分で再実行

3. **読む** — stdout / stderr / exit code をすべて確認
   - 末尾だけ見て判断しない (途中の warning / skip を見落とす)
   - 「passed」の数字を実際に目視

4. **照合** — 出力が主張を本当に裏付けているか判定
   - failures = 0 を実際に見たか?
   - exit code 0 を実際に見たか?
   - linter pass を build pass と混同していないか?
   - 元の bug 症状テストを走らせたか?

5. **主張** — 上記 1-4 が満たされた **後にのみ** 主張する
   - 出力の該当行を引用するとさらに強い

## Common Failures (不十分な検証パターン)

| 失敗パターン | 何が抜けているか |
|---|---|
| failures = 0 を確認せずに「テスト通った」 | 出力読解 (Step 3-4) |
| linter 通過 → ビルド成功と勘違い | 別概念の混同 (Step 4) |
| 元の bug 症状テストを走らせずに「修正済み」 | 検証コマンド特定 (Step 1) |
| single test pass で red-green regression skip | 検証範囲の不足 (Step 1) |
| subagent の "done" 報告をそのまま信じる | Fresh 実行の独立確認なし (Step 2) |
| `git status` を確認せず「全部 commit 済み」 | Fresh 実行 (Step 2) |
| coverage 確認せず「テスト書きました」 | 検証コマンド特定 (Step 1) |

## Red Flags — 即停止

- 「Great!」「Perfect!」「Excellent!」が頭に浮かんだ → 出力なしの満足表明、即停止
- 「should」「probably」「seems to」を含意した発言を準備中 → 確信不足を fresh 実行で解消
- 検証コマンドの出力ログがこのターン内に存在しない → Fresh 実行を実施
- subagent の報告を独立確認していない → 自分で再実行
- commit / PR を作ろうとしているが verification-loop の出力がない → `verification-loop` を起動

## Rationalization Prevention Table

| 言い訳 | 反論 |
|---|---|
| 「明らかに直っている」 | 出力で確認、明らかさは証拠ではない |
| 「同じテストを何度も走らせるのは無駄」 | fresh 実行が Iron Law。前回出力は無効 |
| 「時間がない」 | 検証スキップは事故の入口。検証は通常 30 秒〜数分 |
| 「subagent が done と言った」 | 独立確認まで信頼しない。自分で再実行 |
| 「commit してから CI で見る」 | 本 skill のゲートはローカル責務。CI 任せは責務放棄 |
| 「ビルドが通ったからテストもパスのはず」 | 別概念。両方を fresh 実行 |
| 「diff が小さいから安全」 | 1 行修正で 1 万行壊した事例は無数。検証 |
| 「ローカルで手動確認した」 | 手動確認は再現性なし。テスト出力で示す |
| 「直前のターンで走らせた」 | キャッシュ無効。今このターンで実行 |
| 「ユーザーを待たせたくない」 | 誤った完了主張は信頼を破壊する。検証が先 |

これらが頭に浮かんだら、主張を停止して 5-Step Gate に戻る。

## 適用範囲

「完了 / 成功」のあらゆる variation に適用 (言い換え、含意、暗示を含む):

- commit メッセージで「fix X」「implement Y」と書こうとしている
- PR description で「Closes #123」を書こうとしている
- ユーザーへの報告で「対応しました」と書こうとしている
- subagent から戻ってきて「タスク完了」と要約しようとしている
- TodoWrite で `completed` に更新しようとしている

すべて Gate Function を通過してから発する。

## Hypothetical RED Baseline

`skill-create` の Iron Law に従い、初版時点で想定 pressure scenario を明記する (実 subagent baseline は `empirical-prompt-tuning` で別途取得)。

**Pressure scenario**:
> 4 時間デバッグした末にログから fix を導いた。`git diff` は 3 行、変更は 1 ファイル。ユーザーが Slack で「進捗どう?」と聞いてきた。テストはまだ走らせていない。修正箇所は明白に見える。

**想定 rationalization (counter は本文に対応)**:
1. 「3 行だし明らかに直っている、PR 出していい」 → 検証なし、Iron Law 違反 (Rationalization Table「明らかに直っている」「diff が小さいから安全」の counter)
2. 「ローカルで動かしたら直った、もう PR」 → 手動確認は再現性なし、テスト出力で示す (「ローカルで手動確認した」の counter)
3. 「ユーザーを待たせたくない、commit してから CI で見る」 → CI 任せは責務放棄 (「commit してから CI で見る」「ユーザーを待たせたくない」の counter)

このシナリオは subagent baseline 取得後に、観察された rationalization を Rationalization Table に追記して強化する。

## 連携

- **実行手段**: `verification-loop` (Phase 1〜6) を 5-Step の "Fresh 実行" で起動
- **デバッグ起点**: `systematic-debugging` の Phase 4 完了主張前に必ず本 skill を発火
- **Go ビルド対象**: `golang-build-fixing` の出力を Step 3-4 で確認
- **コードレビュー対象**: `code-review-routing` 起動前に本 skill のゲートを通す
- **TDD サイクル**: `tdd-workflow` の RED → GREEN → REFACTOR の各遷移は本 skill のゲートに従う
- 上流参考: `obra/superpowers` の `verification-before-completion` skill
