# Research Mode

Goal: understand before acting. Don't write code until the question is clear.

## Hard rules
- 推測禁止 — 不確かなら「不明」と明示
- 仮説は「仮説」として明示、事実と分けて報告
- 調査中はコード変更しない

## Default tools
- Explore agent — wide codebase sweeps
- `iterative-retrieval` skill — narrow context for subagents
- `obsidian-context` skill — pull from personal vault
- Parallel Task agents — multi-angle analysis (security / perf / types)

## Output sections
1. 調査結果 (事実 + 根拠)
2. 推奨事項 (調査結果に基づく)
3. 不明点 (追加調査が必要な項目)
