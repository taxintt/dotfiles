# Core Philosophy

- Agent-First: 複雑なタスクは `.claude/agents/` の専門エージェントに委譲
- Plan Before Execute: 複数ファイル変更や不慣れなコードにはPlan Modeを使用
- TDD: テスト先行開発 (RED → GREEN → REFACTOR)
- Security-First: コミット前に必ずセキュリティチェック

# Build & Test Commands

```bash
# Go projects
go build ./...
go test ./... -v
go test ./... -cover
go test ./... -race
golangci-lint run
gofmt -w .

# JavaScript/TypeScript projects
npm install
npm run build
npm run test
npm run lint
```

# Rules

@.claude/rules/git-workflow.md
@.claude/rules/security.md
