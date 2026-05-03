# Coding Style

## File Organization

MANY SMALL FILES > FEW LARGE FILES:
- High cohesion, low coupling
- 200-400 lines typical, 800 max
- Extract utilities from large components
- Organize by feature/domain, not by type

## Error Handling

ALWAYS handle errors explicitly. Never ignore errors silently.

### Go
```go
result, err := riskyOperation()
if err != nil {
    return fmt.Errorf("operation failed: %w", err)
}
```

### JavaScript/TypeScript
```typescript
try {
  const result = await riskyOperation()
  return result
} catch (error) {
  throw new Error(`Operation failed: ${error.message}`)
}
```

## Input Validation

ALWAYS validate user input at system boundaries.

## Code Quality Checklist

Before marking work complete:
- [ ] Code is readable and well-named
- [ ] Functions are small (<50 lines)
- [ ] Files are focused (<800 lines)
- [ ] No deep nesting (>4 levels)
- [ ] Proper error handling
- [ ] No debug statements (console.log, fmt.Println for debugging)
- [ ] No hardcoded secrets or credentials
- [ ] Language-specific formatter applied (gofmt, prettier)
