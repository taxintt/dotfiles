---
name: tdd-workflow
description: Use this skill when writing new features, fixing bugs, or refactoring code. Enforces test-driven development with 80%+ coverage including unit, integration, and E2E tests.
---

# Test-Driven Development Workflow

Ensures all code development follows TDD principles with comprehensive test coverage.

## When to Activate

- Writing new features or functionality
- Fixing bugs or issues
- Refactoring existing code
- Adding API endpoints

## TDD Cycle: RED → GREEN → REFACTOR

1. **RED** - Write a failing test that describes the desired behavior
2. **GREEN** - Write minimal code to make the test pass
3. **REFACTOR** - Improve code while keeping tests green
4. **REPEAT** - Continue with next requirement

## Coverage Requirements

- Minimum 80% coverage (unit + integration + E2E)
- All edge cases covered
- Error scenarios tested
- Boundary conditions verified

## Test Types

| Type | Scope | Examples |
|------|-------|---------|
| Unit | Individual functions, utilities | Pure functions, helpers |
| Integration | API endpoints, DB operations | Service interactions |
| E2E | Critical user flows | Browser automation |

## Workflow Steps

1. Write user journey: `As a [role], I want to [action], so that [benefit]`
2. Generate test cases from the journey
3. Run tests - verify they FAIL (RED)
4. Implement minimal code (GREEN)
5. Run tests - verify they PASS
6. Refactor while keeping tests green
7. Verify 80%+ coverage

## Best Practices

- **Test behavior, not implementation** - Test what users see, not internal state
- **One assert per test** - Focus on single behavior
- **Arrange-Act-Assert** - Clear test structure
- **Independent tests** - Each test sets up its own data, no dependencies
- **Semantic selectors** - Use `data-testid` or text content, not CSS classes

## Language-Specific Patterns

- For **Go** testing patterns: use the `golang-testing` skill
- For **TypeScript** testing patterns: read `patterns-ts.md` in this directory
