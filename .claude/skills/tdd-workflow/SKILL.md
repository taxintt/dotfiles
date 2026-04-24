---
name: tdd-workflow
description: 新機能の実装、バグ修正、リファクタリングを行う際に使用する。テスト先行開発を強制し、unit / integration / E2E を含む 80% 以上のカバレッジを求める。`/ts-tdd` / `/go-tdd` として明示呼び出しされたときも起動する。
---

# Test-Driven Development ワークフロー

すべてのコード開発が TDD 原則と包括的なテストカバレッジに従うことを保証する。

## Iron Law

> **「失敗するテストが存在しないプロダクションコードは書かない」**

この原則には例外がない:

- テストより先に書かれたコードは **すべて削除** する。「参考として残す」「少し手を加えれば使える」は許されない
- 「RED を見なかった」= そのテストが何をテストしているか証明できていない
- 未検証コードを残すことは技術的負債を増やすだけで、決して節約にならない

## 発火タイミング

- 新機能・新しい機能性の実装
- バグ修正 → 加えて `regression-testing.md` を併読（逆フェーズ検証必須）
- 既存コードのリファクタリング
- API エンドポイントの追加

## TDD サイクル: RED → GREEN → REFACTOR

各フェーズは **verification checkpoint** を伴う。チェックポイントを省略した時点で TDD ではなくなる。

1. **RED — 失敗するテストを書く**
   - 望む挙動を 1 つだけ記述するテストを書く（複数挙動を詰め込まない）

2. **Verify RED — 失敗を目で確認する**（必須）
   - テストを実行し、**失敗することを確認**
   - 失敗理由が期待通りか検査する（タイプミス / import ミスではなく、実装がないから失敗しているか）
   - 自問: 「このテストがなぜ失敗するのか 1 文で説明できるか？」 No なら進まない

3. **GREEN — 最小実装**
   - テストを通す最小コードだけ書く。余計な機能 / エラーハンドリングを足さない

4. **Verify GREEN — 成功を目で確認する**（必須）
   - テストを実行し、**成功することを確認**
   - 他のテストが壊れていないかも同時に確認

5. **REFACTOR — 緑を保ったまま改善**
   - テストを走らせながら内部構造を整える

6. **REPEAT — 次の要件へ**

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

## 典型的な Rationalization と反論

pressure 下で TDD を skip したくなったとき、下記のどれかで正当化しようとしている可能性が高い。**すべて rationalization**。

| 言い訳 | 反論 |
|---|---|
| 「シンプルだからテスト不要」 | シンプル ≠ バグがない。テストして。 |
| 「テスト後でも結果は同じ」 | テスト後はすでに pass する。何も証明しない。テスト先行は「何が必要か」を問う。テスト後は「今何をしているか」を追認するだけ |
| 「手動で動作確認した」 | 手動検証は体系的ではなく、再現性がない。リグレッション検知に使えない |
| 「今回だけ実装が先」 | それこそバグが混入する瞬間。止めて、やり直し |
| 「既に動くコードがある。テストは後で整える」 | 未検証コード = 技術負債。削除して TDD で再実装 |
| 「RED 確認は省いた、たぶん落ちるはず」 | 「たぶん」はエビデンスではない。RED を見なかったテストは無価値 |
| 「テスト 1 本で複数の振る舞いを検証」 | テスト名に `and` が含まれるなら分割。1 テスト 1 振る舞い |
| 「モック入れれば外部依存が消える」 | モックの振る舞いをテストするな。実コードをテストせよ（詳細は `testing-anti-patterns.md`） |
| 「時間がない」 | TDD は節約手段。スキップは後で 2 倍返ってくる |

これらが頭に浮かんだら、**書きかけのコードを削除して RED から再開** する。

## 補助ドキュメント

- **`patterns-ts.md`** — TypeScript / Jest / React / API / E2E / モックパターン
- **`testing-anti-patterns.md`** — モック / テストオンリーメソッド / 不完全モックデータ等の落とし穴
- **`regression-testing.md`** — バグ修正時の逆フェーズ検証（修正 revert → テストが fail することまで確認）

Go 固有: `golang-testing` skill を併読。
