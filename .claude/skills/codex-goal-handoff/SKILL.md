---
name: codex-goal-handoff
description: 壁打ちで固めたプランを Codex Goal mode (GPT-5.6 Sol) に渡して自走実装させ、Claude (Fable) は agmsg 経由の advisor 兼品質ゲートとして常駐する。プラン完成後に「Codex に自走させて」「goal に渡して」と依頼されたとき、または `/goal-handoff` として明示呼び出しされたときに起動する。
---

# Codex Goal Handoff Skill

役割分担: Claude (Fable) = 要件壁打ち・プラン策定・advisor・品質ゲート / Codex (GPT-5.6 Sol) = `/goal` による自走実装。

短時間・同期的な委譲は `codex-delegation` skill を使う。本 skill は数時間〜日単位の自走が対象。

## 前提チェック (起動時に必ず確認)

1. `~/.codex/config.toml` に `[features] goals = true` があること (dotfiles 管理済み)
2. `~/.codex/sol.config.toml` が存在すること (`codex --profile sol` 用)
3. agmsg がインストール済みであること (`make agmsg-install`)。未導入ならユーザーに導入を依頼して中断する
4. Goal mode は ChatGPT 認証モード限定。GPT-5.6 Sol はプランによって使えない場合がある — 起動時にエラーになったらモデルをユーザーに確認する

## フロー

### Phase 1: プラン策定 (Claude)

- 壁打ち: `design-interview` / `grill-me` skill
- 計画化: `implementation-planning` skill
- 完成条件: 各要件に**検証可能な受け入れ条件**が付いていること。Goal mode の成否は停止条件の検証可能性でほぼ決まる

### Phase 2: goal プロンプト作成 (Claude)

以下のフォーマットでプロンプトをファイルに書き出し、ユーザーに提示する:

```
## Goal
<1 文の目標>

## Plan
<Phase 1 のプラン全文 or 参照パス>

## Constraints
- 最小限の実装。プラン外のリファクタ・機能追加禁止
- AGENTS.md の規約に従う

## Stop conditions (すべて検証可能であること)
- <例: `go test ./...` が pass / 受け入れ条件 X が満たされる>

## Consultation protocol
- 設計判断に迷ったら、プランと矛盾する事実を見つけたら、プランから逸れそうになったら、
  agmsg で <Fable のエージェント名> に質問し、回答を待ってから進む
- 各マイルストーン完了時に agmsg で進捗を報告する
```

### Phase 3: agmsg チーム設営

- Claude 側: `/agmsg` で join (配信モード: monitor = リアルタイム受信)
- Codex 側は起動後に `$agmsg` で join させる (turn 配送。monitor は beta なので使わない)
- チーム名・エージェント名をユーザーと合意してプロンプトに記載する

### Phase 4: 起動 (ユーザー操作)

`/goal` は対話セッションのコマンドなので起動はユーザーが行う。Claude は正確な手順を提示する:

```bash
codex --profile sol
# セッション内で:
#   $agmsg          (チーム join)
#   /goal <Phase 2 のプロンプト>
```

### Phase 5: 常駐 advisor (Claude)

agmsg でメッセージを受信したら:

1. **質問** — 元プランを唯一の判断基準として回答する。プラン変更が必要な内容なら、勝手に承認せずユーザーに確認してから回答する
2. **進捗報告** — プランとの整合を確認し、逸脱の兆候があれば即座に指摘を返す
3. **逸脱検知** — 報告内容がプランにない作業を含むとき: 作業を止めさせ、理由を質問し、必要ならユーザーにエスカレーションする

### Phase 6: 受け入れレビュー (Claude)

自走完了の報告を受けたら:

1. `git diff` 全量レビュー (規約違反 / slop / セキュリティ)
2. 要件トレース — プランの受け入れ条件を 1 件ずつ検証コマンドを実行して確認する
3. lint / test を明示的に実行 (Codex の編集は PostToolUse hook を通らない — `codex-delegation` skill の Iron Law と同じ)
4. 不合格項目は agmsg で差し戻すか、軽微なら `codex-delegation` で修正委譲する
5. 全条件クリアを確認してからユーザーに完了報告する (`verification-before-completion` の対象)

## Iron Law: 停止条件のないプランを /goal に渡さない

検証不能な目標で自走させると「完了した風」の状態で止まる。受け入れ条件が検証コマンドに落ちていないプランは Phase 1 に差し戻す。

## 関連

- 同期・小タスク委譲: `codex-delegation` skill
- プラン策定: `design-interview` / `grill-me` / `implementation-planning` skill
- Codex 側の規約: `AGENTS.md` (`make rule-sync` で生成)
