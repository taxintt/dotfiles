---
name: terraform-validation
description: Terraform module 変更後に static checks / Conftest(OPA) ポリシー検証 / `terraform test` を実行してゲート判定する。プラグイン提供の terraform-test skill が「テストの書き方」を担当するのに対し、本 skill は「実行とゲート」を担当する。本 skill は「検証ゲートの実行」であり「失敗原因の調査」ではない。CI / apply の失敗原因の切り分けは systematic-debugging が担当し、本 skill は原因特定後・*.tf 編集後の検証ゲートに専念する。`*.tf`/`*.tftest.hcl` を編集した後、PR 前、`/tf-verify` 呼び出し時に起動する
model: sonnet
---

[共通本文](shared/instructions.md) を読み、手順に従う。本文中の参考資料は `shared/` を基準に解決する。

## Claude Codeでの連携

`terraform-code-generation@hashicorp` プラグインがテストの**記述・スタイル**を提供するのに対し、この skill は**実行・ゲート判定**に専念する。重複は持たない。

## 役割分担

| 役割 | 担当 |
|---|---|
| HCL 生成・スタイル | `terraform-code-generation:terraform-style-guide` |
| `*.tftest.hcl` の書き方・mock | `terraform-code-generation:terraform-test` |
| Azure 特化モジュール | `terraform-code-generation:azure-verified-modules` |
| state import / discovery | `terraform-code-generation:terraform-search-import` |
| **実行・ゲート・OPA 統合** | **本 skill (terraform-validation)** |

`verification-loop` からの委譲時にも起動する。Mock providerやテスト記法は `terraform-code-generation:terraform-test` を参照する。

PostToolUseの `post-tool-terraform-lint.sh` が編集後にfmt・tflintを実行し、Stopの `stop-verify.sh` がvalidateを実行する。共通本文の完全検証は省略しない。失敗報告形式はPostToolUseと統一する。
