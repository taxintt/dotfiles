---
name: terraform-validation
description: Terraform module 変更後に static checks / Conftest(OPA) ポリシー検証 / `terraform test` を実行してゲート判定する。プラグイン提供の terraform-test skill が「テストの書き方」を担当するのに対し、本 skill は「実行とゲート」を担当する。`*.tf`/`*.tftest.hcl` を編集した後、PR 前、`/tf-verify` 呼び出し時に起動する
model: sonnet
---

# Terraform Validation Harness

`terraform-code-generation@hashicorp` プラグインがテストの**記述・スタイル**を提供するのに対し、この skill は**実行・ゲート判定**に専念する。重複は持たない。

## 使うタイミング

- `*.tf` / `*.tftest.hcl` / `*.tfvars` を編集した直後
- `verification-loop` skill から委譲されたとき
- ユーザーが `/tf-verify` と呼んだとき
- PR 作成直前

## 役割分担

| 役割 | 担当 |
|---|---|
| HCL 生成・スタイル | `terraform-code-generation:terraform-style-guide` |
| `*.tftest.hcl` の書き方・mock | `terraform-code-generation:terraform-test` |
| Azure 特化モジュール | `terraform-code-generation:azure-verified-modules` |
| state import / discovery | `terraform-code-generation:terraform-search-import` |
| **実行・ゲート・OPA 統合** | **本 skill (terraform-validation)** |

## 検証フロー (3 Step)

### Step 1 — Static checks

PostToolUse hook (`post-tool-terraform-lint.sh`) が編集後に `terraform fmt -check` と `tflint` を自動実行している前提。skill 起動時はモジュール全体に対して再走査する:

```bash
# モジュール直下で
terraform fmt -check -recursive
terraform validate
tflint --recursive --format=compact   # tflint 未インストール時はスキップ
```

`terraform validate` は init 必須。未 init なら `terraform init -backend=false` を先行。

### Step 2 — Policy as Code (Conftest / OPA)

ポリシー配置: リポジトリルートの `policy/*.rego`。

ない場合は以下のテンプレートを `policy/baseline.rego` に提案する (ユーザー承認後に作成):

```rego
package main

# S3 バケットは暗号化必須
deny[msg] {
  resource := input.resource_changes[_]
  resource.type == "aws_s3_bucket"
  not resource.change.after.server_side_encryption_configuration
  msg := sprintf("S3 bucket %q must have encryption configured", [resource.address])
}

# IAM "*:*" 禁止
deny[msg] {
  resource := input.resource_changes[_]
  resource.type == "aws_iam_policy"
  doc := json.unmarshal(resource.change.after.policy)
  stmt := doc.Statement[_]
  stmt.Action == "*"
  stmt.Resource == "*"
  msg := sprintf("IAM policy %q must not allow *:*", [resource.address])
}
```

実行:

```bash
terraform plan -out=plan.tfplan
terraform show -json plan.tfplan > plan.json
conftest test --all-namespaces -p policy plan.json
```

### Step 3 — Functional tests

各 `*.tftest.hcl` を `terraform test` で実行:

```bash
terraform test -verbose
```

Mock provider の使い方やテスト記法は `terraform-code-generation:terraform-test` skill を参照。

## Failure protocol

すべての失敗は `ERROR: / WHY: / FIX: / EXAMPLE:` の 4 行形式で報告する (PostToolUse hook と統一):

```
ERROR: <何が間違っているか> <ファイル:行番号>
WHY:   <ルールの背景、どんなリスクがあるか>
FIX:   <具体的な修正手順>
EXAMPLE:
  # Bad:
  resource "aws_s3_bucket" "data" { bucket = "x" }
  # Good:
  resource "aws_s3_bucket" "data" {
    bucket = "x"
    server_side_encryption_configuration { ... }
  }
```

ポリシー違反 (Step 2) は **「本番デプロイ前に必ず修正」** と明記してユーザーに返す。

## Stop hook との連携

`stop-verify.sh` (Stop hook) が `terraform validate` を最低限走らせる。本 skill は **Step 2 (OPA) と Step 3 (terraform test) を含む完全検証**を担うので、PR 前は必ず本 skill で 3 Step すべてを通すこと。

## Out of scope

- Terraform Cloud / Enterprise の TFE API 連携 → `terraform` CLI のみで完結させる
- ドリフト検出 / state lock の調整 → 別途 ops 手順
- マルチクラウド統合テスト (Terratest) → 必要になったら別 skill として追加
