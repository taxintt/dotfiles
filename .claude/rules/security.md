# Security Guidelines

## Pre-commit checks (must pass)
- No hardcoded secrets (API keys, passwords, tokens)
- All user inputs validated at boundaries
- SQL injection: parameterized queries only
- XSS: sanitized HTML output
- AuthN/AuthZ: verified for every protected path
- Error messages: no sensitive-data leakage

## Secret rule
- Never hardcode. Read from env vars; throw at startup if absent.

## Incident protocol
1. STOP — do not push, do not commit further
2. Hand off to `security-reviewer` agent
3. Fix CRITICAL issues first
4. Rotate any exposed secret
5. Sweep codebase for similar patterns
