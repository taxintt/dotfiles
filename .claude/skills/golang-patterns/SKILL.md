---
name: golang-patterns
description: Idiomatic Go patterns, best practices, and conventions for building robust, efficient, and maintainable Go applications.
---

# Go Development Patterns

Idiomatic Go patterns and best practices for building robust, efficient, and maintainable applications.

## When to Activate

- Writing new Go code
- Reviewing Go code
- Refactoring existing Go code
- Designing Go packages/modules

## Core Principles

1. **Simplicity and Clarity** - Go favors simplicity over cleverness. Code should be obvious and easy to read.
2. **Make the Zero Value Useful** - Design types so their zero value is immediately usable without initialization.
3. **Accept Interfaces, Return Structs** - Functions should accept interface parameters and return concrete types.
4. **Errors are Values** - Treat errors as first-class values, not exceptions.
5. **Return Early** - Handle errors first, keep happy path unindented.

## Quick Reference: Go Idioms

| Idiom | Description |
|-------|-------------|
| Accept interfaces, return structs | Functions accept interface params, return concrete types |
| Errors are values | Treat errors as first-class values, not exceptions |
| Don't communicate by sharing memory | Use channels for coordination between goroutines |
| Make the zero value useful | Types should work without explicit initialization |
| A little copying is better than a little dependency | Avoid unnecessary external dependencies |
| Clear is better than clever | Prioritize readability over cleverness |
| gofmt is no one's favorite but everyone's friend | Always format with gofmt/goimports |
| Return early | Handle errors first, keep happy path unindented |

## Detailed Pattern References

For detailed code examples and patterns, read the corresponding reference file:

- `error-handling.md` - Error wrapping, custom error types, errors.Is/As
- `concurrency.md` - Worker pools, context, graceful shutdown, errgroup
- `interfaces.md` - Small interfaces, consumer-side definition, type assertions
- `performance.md` - Slice preallocation, sync.Pool, string building, package organization
