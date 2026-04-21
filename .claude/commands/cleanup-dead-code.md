---
description: JS / TS プロジェクトのデッドコードをテスト検証付きで段階的に削除する
argument-hint: "[report-path]"
---

# /cleanup-dead-code

JS / TS エコシステム（knip / depcheck / ts-prune）を前提とした、デッドコード検出と安全削除のワークフロー。Go / Python など他言語には適用しない。

## 引数

- `$ARGUMENTS` が与えられていればレポート出力先として使用
- 未指定なら `.reports/dead-code-analysis.md` をデフォルト採用

## 手順

1. **ツール導入確認**
   - `knip` / `depcheck` / `ts-prune` が利用可能か確認
   - 未導入のツールがあれば、インストールコマンドを提示してユーザーに確認（勝手に入れない）

2. **デッドコード解析を実行**
   - knip: 未使用 export / ファイル
   - depcheck: 未使用依存
   - ts-prune: 未使用 TS export

3. **レポート生成**
   - 出力先は引数 or デフォルト（`.reports/dead-code-analysis.md`）
   - 3 カテゴリに分類:
     - **SAFE**: テストファイル、未使用ユーティリティ
     - **CAUTION**: API ルート、コンポーネント
     - **DANGER**: 設定ファイル、エントリポイント

4. **安全な削除候補のみ提示**

5. **テスト駆動の削除サイクル**（SAFE のみ自動適用、CAUTION / DANGER はユーザー確認）
   - `package.json` の test スクリプトを検出（無ければユーザーに確認）
   - フルテストを実行 → 緑を確認
   - 対象を削除
   - テスト再実行
   - 失敗したらロールバック

6. **削除済みアイテムのサマリを提示**

## 禁止事項

- テスト実行せずに削除しない
- CAUTION / DANGER をユーザー確認なしに触らない
