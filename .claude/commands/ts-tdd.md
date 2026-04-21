---
description: TypeScript / JavaScript 向けの TDD ワークフローを強制する。tdd-guide エージェントを Task ツールで呼び出す
---

# /ts-tdd

TypeScript / JavaScript プロジェクト向けの TDD ワークフロー。Go の場合は `/go-tdd` を使うこと。

このコマンドは `Task` ツール経由で `subagent_type=tdd-guide` を起動し、RED → GREEN → REFACTOR のサイクルを強制する。

## 動作

1. **インターフェースの scaffold** — 入出力の型定義を先に書く
2. **失敗するテストを書く（RED）** — 実装がまだ無い状態で失敗することを確認
3. **最小実装（GREEN）** — テストを通す最小コードだけ書く
4. **リファクタ** — テスト緑のまま改善
5. **カバレッジ確認** — 目標 80%+（未達時は追加テストを提案）

## 使うタイミング

- 新機能の実装
- 既存コードのカバレッジ補完
- バグ修正（再現テストを先に書く）
- 中核ビジネスロジックの構築

## TDD サイクル

```
RED      失敗するテストを書く
GREEN    テストを通す最小実装
REFACTOR テストが緑のまま改善
REPEAT   次のケースへ
```

## スカフォールドの基本形

```typescript
// lib/target.ts
export interface Input {
  // ...
}

export interface Output {
  // ...
}

export function target(input: Input): Output {
  throw new Error('Not implemented')
}
```

## テストの基本形

```typescript
// lib/target.test.ts
import { target } from './target'

describe('target', () => {
  it('happy path', () => {
    const got = target({ /* ... */ })
    expect(got).toEqual({ /* ... */ })
  })

  it('edge: empty input', () => {
    expect(() => target({ /* ... */ })).toThrow()
  })
})
```

テスト実行は プロジェクトのテストコマンド（`npm test` / `vitest` / `jest` 等）に従う。

## カバレッジ目標

| 種別                     | 目標 |
|--------------------------|------|
| 金融 / 認証 / 重要ビジネスロジック | 高く維持（目標 100%） |
| 公開 API                 | 90%+ |
| 一般コード               | 80%+ |
| 生成コード               | 除外 |

80% 未満の場合は警告として報告し、追加テストの候補を提示する（自動ブロックはしない）。

## DO / DON'T

**DO**
- テストを先に書く
- RED を確認してから実装
- 振る舞いをテスト（実装詳細は避ける）
- エッジケースを含める

**DON'T**
- 実装を先に書く
- RED フェーズを飛ばす
- flaky テストを放置する
- モック過多（統合テスト優先）

## 関連

- Agent: `~/.claude/agents/tdd-guide.md`
- Skill: `~/.claude/skills/tdd-workflow/`
- Commands: `/go-tdd`（Go プロジェクト）、`/code-review`、`/verify`
