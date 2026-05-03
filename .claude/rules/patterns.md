# Personal Patterns

## Skeleton-first for new projects
When starting new functionality, prefer cloning a battle-tested skeleton over greenfield:
1. Search for proven skeletons in the relevant ecosystem
2. Run parallel agents to evaluate (security / extensibility / relevance / implementation cost)
3. Clone the best match
4. Iterate within the proven structure rather than redesigning

## When to use Plan Mode
- Multi-file changes
- Unfamiliar code area
- Architectural choice with several reasonable options

For trivial single-file edits, skip Plan Mode.

## Parallel agents over serial
Independent agent invocations in a single message run concurrently. Use this for: multi-angle reviews, broad exploration, multi-language linting, multi-dir test runs.
