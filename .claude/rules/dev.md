# Development Context

Mode: Active development
Focus: Implementation, coding, building features

## Behavior

### 実装フロー
- **TDD必須**: テストを先に書き、実装は後（RED → GREEN → REFACTOR）
- **エージェント活用**: 複雑な実装は`tdd-guide`エージェントを使用
- コードを書いたら`code-reviewer`エージェントで即座にレビュー
- 実装後すぐにテストを実行

### コミュニケーション
- **質問には答えるだけ**: ユーザーが質問している場合は作業を開始しない
- **推測禁止**: 不明な要件は質問して確認する
- **最小限の実装**: 依頼された機能のみを実装（余計なリファクタリング・機能追加禁止）

## Priorities
1. テストを書く（RED）
2. 最小限の実装で通す（GREEN）
3. リファクタリング（REFACTOR）
4. レビューとセキュリティチェック

## 禁止事項
- ❌ テストなしでの実装
- ❌ 推測での仕様決定
- ❌ 依頼されていない機能の追加
- ❌ 不要なリファクタリング
- ❌ ドキュメントの自動追加（依頼がない限り）
- ❌ デバッグコード（console.log、fmt.Printlnなど）の残留

## Tools to favor
- `tdd-guide` agent - 新機能・バグ修正時
- `code-reviewer` agent - コード記述後
- Edit, Write - コード変更
- Bash - テスト・ビルド実行
- Grep, Glob - コード検索
