---
description: Go の TDD ワークフローを強制する。table-driven テストを先に書き、最小実装、80%+ カバレッジを検証。tdd-guide エージェントを呼び出す
---

# Go TDD Command

このコマンドは **tdd-guide** エージェントを呼び出し、Go における TDD（RED → GREEN → REFACTOR）を強制する。Task ツール経由で `subagent_type=tdd-guide` を起動する想定。

## 動作

1. **型/関数シグネチャを定義**: まずスカフォールドする
2. **table-driven テストを書く**: 失敗する状態で作成（RED）
3. **テスト実行**: 正しい理由で失敗することを確認
4. **最小実装**: テストを通す最小コード（GREEN）
5. **リファクタ**: テストが緑のまま改善
6. **カバレッジ確認**: `go test -cover`（目標 80%+、未達の場合は警告として報告し、追加テストを提案）

## 使うタイミング

- Go の関数を新規実装する
- 既存コードにカバレッジを足す
- バグ修正（再現テストを先に書く）
- 中核ビジネスロジックを構築する

## TDD サイクル

```
RED      失敗する table-driven テストを書く
GREEN    テストを通す最小コードを実装
REFACTOR テストを緑のまま改善
REPEAT   次のケースへ
```

## スカフォールドの基本形

初回は「コンパイルエラー」で RED を取るのが Go 流。どうしても関数が先に必要なら、`panic` ではなく明示的にエラーを返す stub を使う。

```go
package validator

import "errors"

var errNotImplemented = errors.New("not implemented")

func ValidateEmail(email string) error {
    return errNotImplemented
}
```

## table-driven テストの骨格

```go
tests := []struct {
    name    string
    input   InputType
    want    OutputType
    wantErr bool
}{
    {"happy path", in1, out1, false},
    {"edge: empty", "", zeroOut, true},
}

for _, tt := range tests {
    t.Run(tt.name, func(t *testing.T) {
        got, err := Target(tt.input)
        if (err != nil) != tt.wantErr {
            t.Fatalf("err = %v, wantErr = %v", err, tt.wantErr)
        }
        if got != tt.want {
            t.Errorf("got %v, want %v", got, tt.want)
        }
    })
}
```

## 並列・ヘルパー

```go
// 並列化（tt をキャプチャ）
for _, tt := range tests {
    tt := tt
    t.Run(tt.name, func(t *testing.T) {
        t.Parallel()
        // ...
    })
}

// t.Helper() + t.Cleanup() でセットアップ分離
func setupDB(t *testing.T) *sql.DB {
    t.Helper()
    db := newDB()
    t.Cleanup(func() { db.Close() })
    return db
}
```

## カバレッジ関連

```bash
go test -cover ./...
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out
go tool cover -func=coverage.out
go test -race -cover ./...
```

## カバレッジ目標

| 種別                     | 目標 |
|--------------------------|------|
| 重要ビジネスロジック     | 100% |
| 公開 API                 | 90%+ |
| 一般コード               | 80%+ |
| 生成コード               | 除外 |

80% 未満の場合は「不足」として報告し、追加テストケースの候補を提示する（自動ブロックはしない）。

## DO / DON'T

**DO**
- テストを先に書く
- 各変更後にテストを回す
- table-driven で網羅する
- 振る舞いをテスト（実装詳細は避ける）
- エッジケース（空 / nil / 最大値）を含める

**DON'T**
- 実装を先に書く
- RED フェーズを飛ばす
- 非公開関数を直接テストする
- `time.Sleep` に依存する
- flaky テストを放置する

## 関連

- Agent: `~/.claude/agents/tdd-guide.md`
- Skills: `~/.claude/skills/golang-testing/` / `~/.claude/skills/tdd-workflow/`
- Commands: `/go-build` / `/go-review` / `/verify`
