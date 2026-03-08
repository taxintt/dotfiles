---
name: obsidian-context
description: Search Obsidian vault for relevant notes and inject them into context. Use when the user asks about topics that might be documented in their notes, when implementing features that may have design docs, or when you need domain knowledge that could be in their vault.
---

# Obsidian Context Search

This skill searches the Obsidian vault for notes relevant to the current task and automatically injects the results into the conversation context.

## 🔍 Search Results

!`~/.claude/skills/obsidian-context/scripts/search-vault.sh $ARGUMENTS`

## 📝 How to Use This Information

The search results above contain excerpts from the Obsidian vault that may be relevant to the current task. Use this information to:

1. **Understand domain context**: Notes may contain business logic, requirements, or architectural decisions
2. **Follow existing patterns**: Look for coding patterns, conventions, or standards documented in the vault
3. **Reference prior work**: Find similar implementations or solutions to related problems
4. **Align with documented decisions**: Ensure your approach matches any documented ADRs or design decisions

## ⚙️ Configuration

The search behavior can be customized with environment variables:

- `OBSIDIAN_VAULT_PATH`: Path to Obsidian vault (default: `$HOME/obsidian`)
- `OBSIDIAN_MAX_RESULTS`: Maximum number of files to show (default: 5)

## 💡 Tips

- Be specific with search terms for better results
- The search is case-insensitive and searches all `.md` files
- Each result shows up to 2 lines of context before and after matches
- Use this skill proactively when starting new features or investigating unfamiliar code

## Examples

Manual invocation:
```
/obsidian-context authentication flow
/obsidian-context API design patterns
/obsidian-context deployment process
```

Claude will also invoke this automatically when you ask questions like:
- "How should I implement the user authentication?"
- "What's our API design pattern?"
- "How do we handle error logging?"
