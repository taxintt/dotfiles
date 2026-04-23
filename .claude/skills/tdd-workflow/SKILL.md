---
name: tdd-workflow
description: 新機能の実装、バグ修正、リファクタリングを行う際に使用する。テスト先行開発を強制し、unit / integration / E2E を含む 80% 以上のカバレッジを求める。`/ts-tdd` / `/go-tdd` として明示呼び出しされたときも起動する。
---

# Test-Driven Development ワークフロー

すべてのコード開発が TDD 原則と包括的なテストカバレッジに従うことを保証する。

## 発火タイミング

- 新機能・新しい機能性の実装
- バグ修正
- 既存コードのリファクタリング
- API エンドポイントの追加

## TDD サイクル: RED → GREEN → REFACTOR

1. **RED** - 望む挙動を記述する、失敗するテストを書く
2. **GREEN** - テストを通す最小限のコードを書く
3. **REFACTOR** - テストを緑に保ったままコードを改善する
4. **REPEAT** - 次の要件へ続ける

## カバレッジ要件

- 最小 80% カバレッジ（unit + integration + E2E）
- すべてのエッジケースをカバー
- エラーシナリオをテスト済み
- 境界条件を検証済み

## テストの種類

| 種別 | スコープ | 例 |
|------|-------|---------|
| Unit | 個別の関数・ユーティリティ | 純関数、helper |
| Integration | API エンドポイント、DB 操作 | サービス間連携 |
| E2E | 重要なユーザーフロー | ブラウザ自動化 |

## ワークフロー

1. ユーザーストーリーを書く: `[role] として [action] したい。なぜなら [benefit] だから`
2. ストーリーからテストケースを生成する
3. テストを実行し、**失敗**することを確認（RED）
4. 最小限のコードを実装（GREEN）
5. テストを実行し、**成功**することを確認
6. テストを緑に保ちながらリファクタリング
7. 80% 以上のカバレッジを確認

## Best Practices

- **挙動をテストし、実装をテストしない** - ユーザーが見るものをテストする。内部状態はテストしない
- **テスト 1 本につき assert は 1 つ** - 単一の挙動にフォーカス
- **Arrange-Act-Assert** - 明確なテスト構造
- **独立したテスト** - 各テストが自分でデータを用意。依存しない
- **意味のあるセレクタ** - CSS クラスではなく `data-testid` やテキストで指定

## 言語別パターン

言語別パターンは **必ず併読**（参考ではなく必須）:

- **Go** (`/go-tdd` 含む): `golang-testing` skill を併読。table-driven test, subtest 命名, `tt := tt` キャプチャ, `go test -cover -race` を採用。初回は `errNotImplemented` stub でコンパイル可能な RED を作る。
- **TypeScript** (`/ts-tdd` 含む): 同ディレクトリの `patterns-ts.md` を併読。pure util / React コンポーネント / API integration / E2E / モック の 5 カテゴリからシナリオに該当するものを選ぶ。初回は `throw new Error('Not implemented')` stub で RED を作る。
- **他言語**: 言語固有 skill が無ければ、本 SKILL.md の原則（RED → GREEN → REFACTOR、AAA、80% coverage、behavior テスト）をそのまま適用。

## スカフォールドの基本形

### TypeScript

```typescript
// lib/target.ts
export interface Input { /* ... */ }
export interface Output { /* ... */ }

export function target(input: Input): Output {
  throw new Error('Not implemented')
}
```

### Go

初回は「コンパイルエラー」で RED を取るのが Go 流。関数を先に必要とするときは明示的にエラーを返す stub を使う。

```go
package validator

import "errors"

var errNotImplemented = errors.New("not implemented")

func ValidateEmail(email string) error {
    return errNotImplemented
}
```

## DO / DON'T

**DO**
- テストを先に書く
- RED を確認してから実装
- 振る舞いをテスト（実装詳細は避ける）
- エッジケース（空 / nil / 最大値 / 境界）を含める
- 各変更後にテストを走らせる

**DON'T**
- 実装を先に書く
- RED フェーズを飛ばす
- flaky テストを放置する
- 非公開関数を直接テストする（Go）
- モック過多（統合テスト優先）
- `time.Sleep` に依存する
