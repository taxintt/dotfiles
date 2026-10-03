---
name: golang-build-fixing
description: Go の `go build ./...` / `go vet` / `staticcheck` / `golangci-lint` 失敗時、依存が壊れたとき、pull 後にビルドが通らなくなったときに起動する。`go-build-resolver` agent を呼び出し、1 件ずつ最小修正する。`/go-build` として明示呼び出しされたときも起動する。
model: sonnet
---

[共通本文](shared/instructions.md) を読み、手順に従う。本文中の参考資料は `shared/` を基準に解決する。

## Claude Codeでの連携

`go-build-resolver` agent (`~/.claude/agents/go-build-resolver.md`) に委譲するのが基本。停止条件や再試行ポリシーは共通本文とagent側を参照。
