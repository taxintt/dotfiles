---
name: cleanup-dead-code
description: JS / TS プロジェクトで不要なコード / 依存を削除したいとき、またはユーザーが `/cleanup-dead-code` として明示呼び出ししたときに起動する。knip / depcheck / ts-prune で検出し、テスト駆動で段階削除する。Go / Python など他言語には適用しない。
---

# Cleanup Dead Code Skill

JS / TS エコシステム（knip / depcheck / ts-prune）前提のデッドコード検出と安全削除。

## 発火タイミング

- JS / TS プロジェクトで不要な export / 依存を削除したい
- ユーザーが明示的に `/cleanup-dead-code` と呼んだとき

**対象外**: Go / Python / Rust 等の非 JS / TS プロジェクト。これらは言語別の手順が必要。

## 引数

`[report-path]` — あればレポート出力先。未指定なら `.reports/dead-code-analysis.md`。

## 手順

### 1. ツール導入確認

`knip` / `depcheck` / `ts-prune` が利用可能か確認。**未導入のツールは勝手にインストールしない**。インストールコマンドを提示してユーザー確認を取る。

### 2. 解析実行

- `knip`: 未使用 export / ファイル
- `depcheck`: 未使用依存
- `ts-prune`: 未使用 TS export

### 3. レポート生成

出力先は引数 or デフォルト（`.reports/dead-code-analysis.md`）。

3 カテゴリに分類:

| カテゴリ | 基準 | 扱い |
|---|---|---|
| **SAFE** | テストファイル、未使用ユーティリティ | 自動適用可 |
| **CAUTION** | API ルート、コンポーネント | **ユーザー確認必須** |
| **DANGER** | 設定ファイル、エントリポイント | **ユーザー確認必須** |

### 4. 安全削除候補の提示

SAFE のみ削除候補として提示。CAUTION / DANGER は理由付きで注意喚起。

### 5. テスト駆動の削除サイクル

SAFE のみ自動適用、CAUTION / DANGER はユーザー確認:

1. `package.json` の test スクリプトを検出（無ければユーザーに確認）
2. **フルテストを実行 → 緑を確認**（赤なら中断）
3. 対象を削除
4. **テスト再実行**
5. 失敗したらロールバック（`git restore` / `git checkout` で戻す）

### 6. サマリ提示

削除済みアイテム一覧、成功数、ロールバック数、残残件（CAUTION / DANGER）。

## Iron Law

- **テスト実行せずに削除しない**
- CAUTION / DANGER をユーザー確認なしに触らない
- ロールバック失敗時は即中断（更なる破壊を防ぐ）
- ツールの勝手インストール禁止

### 典型的な rationalization

| Rationalization | 対処 |
|---|---|
| 「明らかに使ってないからテストなしで削除」 | 必ずテストで確認 |
| 「CAUTION だけど呼び元が 1 箇所だから多分 SAFE」 | ユーザー確認 |
| 「ツール無いから npm i -g で入れとく」 | ユーザー承認後のみ |

## 関連

- 検証: `verification-loop` skill（削除後の全体検証）
