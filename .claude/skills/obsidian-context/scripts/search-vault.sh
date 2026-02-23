#!/bin/bash
# Search Obsidian vault for relevant notes

set -euo pipefail

VAULT_PATH="${OBSIDIAN_VAULT_PATH:-~/obsidian}"
QUERY="$*"
MAX_RESULTS="${OBSIDIAN_MAX_RESULTS:-5}"

if [[ -z "$QUERY" ]]; then
    echo "Error: No search query provided" >&2
    exit 1
fi

if [[ ! -d "$VAULT_PATH" ]]; then
    echo "Error: Vault path not found: $VAULT_PATH" >&2
    exit 1
fi

# Search for markdown files containing the query
# Use ripgrep for fast searching
# Try Claude's built-in ripgrep first, then fall back to system rg
if [[ -x "/Users/taxin/.local/share/claude/versions/2.1.44" ]]; then
    rg_search() {
        /Users/taxin/.local/share/claude/versions/2.1.44 --ripgrep "$@"
    }
elif command -v rg &> /dev/null; then
    rg_search() {
        rg "$@"
    }
else
    echo "Error: ripgrep (rg) not found. Please install it: brew install ripgrep" >&2
    exit 1
fi

echo "## 🔍 Obsidian Vault Search Results for: \"$QUERY\""
echo ""
echo "**Vault Path:** $VAULT_PATH"
echo ""

# Search with context lines, case-insensitive, only .md files
# Format: filename, line number, and matching content
RESULTS=$(rg_search \
    --type md \
    --ignore-case \
    --context 2 \
    --max-count 3 \
    --heading \
    --color never \
    "$QUERY" \
    "$VAULT_PATH" \
    2>/dev/null || true)

if [[ -z "$RESULTS" ]]; then
    echo "❌ No results found for \"$QUERY\""
    exit 0
fi

# Get unique files from results
UNIQUE_FILES=$(echo "$RESULTS" | grep -E '^[^:]+\.md' | cut -d: -f1 | sort -u | head -n "$MAX_RESULTS")

if [[ -z "$UNIQUE_FILES" ]]; then
    echo "❌ No markdown files found"
    exit 0
fi

FILE_COUNT=$(echo "$UNIQUE_FILES" | wc -l | tr -d ' ')
echo "📁 Found matches in **$FILE_COUNT** file(s) (showing top $MAX_RESULTS)"
echo ""

# Display results for each file
while IFS= read -r FILE; do
    RELATIVE_PATH="${FILE#$VAULT_PATH/}"

    echo "### 📄 \`$RELATIVE_PATH\`"
    echo ""

    # Get matches with context for this specific file
    FILE_RESULTS=$(rg_search \
        --type md \
        --ignore-case \
        --context 2 \
        --max-count 3 \
        --color never \
        --no-heading \
        --line-number \
        "$QUERY" \
        "$FILE" \
        2>/dev/null || true)

    if [[ -n "$FILE_RESULTS" ]]; then
        echo '```'
        echo "$FILE_RESULTS"
        echo '```'
    fi
    echo ""
done <<< "$UNIQUE_FILES"

echo "---"
echo "*💡 Tip: Use \`/obsidian-context <query>\` to search for different keywords*"
