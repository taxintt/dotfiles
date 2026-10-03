# Terraform Validation Harness

この skill は Terraform の検証の実行・ゲート判定に専念する。

## 使うタイミング

- `*.tf` / `*.tftest.hcl` / `*.tfvars` を編集した直後
- ユーザーが `/tf-verify` と呼んだとき
- PR 作成直前

## 検証フロー (3 Step)

### Step 1 — Static checks

モジュール全体に対して以下を実行する:

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

## Failure protocol

すべての失敗は `ERROR: / WHY: / FIX: / EXAMPLE:` の 4 行形式で報告する:

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

PR 前は Step 1〜3 の完全検証を必ず通すこと。

## Out of scope

- Terraform Cloud / Enterprise の TFE API 連携 → `terraform` CLI のみで完結させる
- ドリフト検出 / state lock の調整 → 別途 ops 手順
- マルチクラウド統合テスト (Terratest) → 必要になったら別 skill として追加
