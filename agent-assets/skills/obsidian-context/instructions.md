# Obsidian Context Search

This skill searches the Obsidian vault for notes relevant to the current task and returns excerpts to use in the conversation context.

## 🔍 Search Results

検索にはsystemの`rg`が必要。本文を読んだskillディレクトリ内の `scripts/search-vault.sh` を、ユーザーの検索語を引数としてシェルで実行し、その出力を読む。検索語はシェル引数として適切にクォートする。

```bash
bash <skill-directory>/scripts/search-vault.sh "authentication flow"
```

## 📝 How to Use This Information

The script output contains excerpts from the Obsidian vault that may be relevant to the current task. Use this information to:

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
obsidian-context authentication flow
obsidian-context API design patterns
obsidian-context deployment process
```

Use this skill when you ask questions like:
- "How should I implement the user authentication?"
- "What's our API design pattern?"
- "How do we handle error logging?"
