# Core Philosophy

- **Agent-First**: Delegate complex tasks to specialized agents in `.claude/agents/`
- **Plan Before Execute**: Use Plan Mode for multi-file changes or unfamiliar code
- **TDD**: Write tests before implementation
- **Security-First**: Never compromise on security; use security-reviewer agent before commits

# Build & Test Commands

```bash
# Go projects
go build ./...
go test ./... -v
go test ./... -cover
golangci-lint run
gofmt -w .

# JavaScript/TypeScript projects
npm install
npm run build
npm run test
npm run lint
```

# Rules

@.claude/rules/coding-style.md
@.claude/rules/git-workflow.md
@.claude/rules/testing.md
@.claude/rules/security.md
@.claude/rules/agents.md

# Language-Specific Guidelines

@.claude/memories/go-cli.md

# Architecture Principles

- Organize code by feature, not by file type
- Keep related files close together
- Use dependency injection for better testability
- Follow single responsibility principle

# Success Metrics

- All tests pass
- Lint errors: 0
- Test coverage: 80%+
- No security vulnerabilities
- Code is readable and well-documented
