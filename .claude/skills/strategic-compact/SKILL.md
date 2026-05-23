---
name: strategic-compact
description: 任意タイミングで走る auto-compaction ではなく、論理的な区切りで手動 /compact を促すことで、タスクフェーズ間のコンテキストを保全する
model: haiku
---

# Strategic Compact Skill

任意タイミングの auto-compaction に任せるのではなく、ワークフローの戦略的ポイントで手動 `/compact` を促す。

## なぜ戦略的 Compaction が必要か

auto-compaction は任意のタイミングで発火する:
- しばしばタスクの途中で走り、重要なコンテキストを失う
- 論理的なタスク境界を認識できない
- 複雑なマルチステップ操作を中断しうる

論理的な区切りで行う戦略的 compaction:
- **調査のあと、実行の前** - 調査コンテキストを compact し、実装プランは残す
- **マイルストーン完了のあと** - 次フェーズを新しい状態で始める
- **大きなコンテキスト切り替えの前** - 別タスクに入る前に探索コンテキストを整理する

## 仕組み

`suggest-compact.sh` スクリプトは PreToolUse (Edit/Write) で動作し、以下を行う:

1. **tool 呼び出しを追跡する** - セッション内の tool 呼び出し回数をカウント
2. **閾値検出** - 設定可能な閾値（デフォルト 50 回）で提案を出す
3. **周期的リマインダー** - 閾値到達後は 25 回ごとに再通知

## Hook の設定

`~/.claude/settings.json` に以下を追加:

```json
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "Edit|Write",
      "hooks": [{
        "type": "command",
        "command": "~/.claude/skills/strategic-compact/suggest-compact.sh"
      }]
    }]
  }
}
```

Claude Code の hooks matcher は正規表現 (`Edit|Write`) を取る。古い例では `tool == "Edit" || tool == "Write"` 形式を見かけるが、現行仕様は regex 形式を使うこと。

## 設定

環境変数:
- `COMPACT_THRESHOLD` - 最初の提案までの tool 呼び出し回数（デフォルト 50）

## Counter State と `/compact` 後のリセット

`suggest-compact.sh` は `/tmp/claude-tool-count-<session-id>` にカウンタを保存する。

- **セッション境界**: 新セッションを始めたら手動で `rm /tmp/claude-tool-count-*` するか、次の再起動で自動的に古いファイルは掃除される（OS 依存、tmp cleanup の扱い）。
- **`/compact` 後のリセット**: `/compact` 自体はこのカウンタをリセットしない。リセットしたい場合は `rm /tmp/claude-tool-count-*` を実行するか、shell alias として `alias compact-reset='rm -f /tmp/claude-tool-count-* && echo reset'` を登録する。
- **古い `$$` 実装**: 以前は `/tmp/claude-tool-count-$$` を使っていたが、hook は呼び出しごとに新プロセスで起動するため PID が毎回変わり、カウンタが常に 1 にリセットされてしまう既知バグがあった。現行は session id ベース。

## Best Practices

1. **計画後に compact する** - プラン確定後は compact して新しい状態で始める
2. **デバッグ後に compact する** - エラー解決のコンテキストを整理してから次へ進む
3. **実装の途中では compact しない** - 関連変更のためにコンテキストを保持する
4. **提案を読む** - hook は *いつ* を教え、*実行するか* は自分で判断する

## 関連

- [The Longform Guide](https://x.com/affaanmustafa/status/2014040193557471352) - トークン最適化の節
- メモリ永続化 hook - compaction を跨いで残すべき状態向け
