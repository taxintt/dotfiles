---
name: skill-create
description: Creates well-structured Claude Code skills from scratch or by analyzing existing codebases. Guides through skill design, YAML frontmatter, progressive disclosure, and quality validation. Use when the user wants to create, improve, or refactor a skill.
argument-hint: "[analyze | improve <skill-path>]"
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

# Skill Creation

Guides the creation of effective Claude Code skills following official best practices.

## When to Activate

- Creating a new skill from scratch
- Improving or refactoring an existing skill
- Extracting patterns from a codebase into a skill
- Reviewing a skill for quality

## Usage

```
/skill-create                          # Interactive: ask what skill to create
/skill-create analyze                  # Analyze current repo and extract patterns into a skill
/skill-create improve <skill-path>     # Improve an existing skill
```

## Core Principles

1. **Concise is key** - Context window is shared; only add what Claude doesn't already know
2. **Progressive disclosure** - SKILL.md as overview, details in separate files
3. **Appropriate freedom** - Match specificity to task fragility
4. **Iterative development** - Create, test, observe, refine

## Skill Creation Workflow

Copy this checklist and track progress:

```
Skill Creation Progress:
- [ ] Step 1: Define scope and purpose
- [ ] Step 2: Choose skill structure
- [ ] Step 3: Write YAML frontmatter
- [ ] Step 4: Write SKILL.md body
- [ ] Step 5: Create reference files (if needed)
- [ ] Step 6: Validate with checklist
```

### Step 1: Define Scope and Purpose

Ask the user:
- What task does this skill automate or guide?
- When should Claude activate this skill?
- What context does Claude NOT already know?

Determine content type:
- **Reference content** (conventions, patterns, domain knowledge) → auto-invocable by Claude
- **Task content** (deploy, commit, generation) → consider `disable-model-invocation: true`

### Step 2: Choose Skill Structure

**Simple skill** (single file):
```
skill-name/
└── SKILL.md
```

**Standard skill** (with references):
```
skill-name/
├── SKILL.md              # Overview + navigation (< 500 lines)
├── reference-a.md        # Detailed guide (loaded on demand)
└── reference-b.md        # Another reference
```

**Full skill** (with sub-commands and scripts):
```
skill-name/
├── SKILL.md
├── commands/
│   └── action.md         # Sub-command invocable as /action
├── reference/
│   └── patterns.md
└── scripts/
    └── utility.py        # Executable script
```

Keep references **one level deep** from SKILL.md.

### Step 3: Write YAML Frontmatter

Rules for `name`:
- Max 64 characters, lowercase letters/numbers/hyphens only
- Gerund form preferred: `processing-pdfs`, `testing-code`
- This becomes the `/slash-command` name

Rules for `description`:
- Max 1024 characters, third person
- Include **what it does** AND **when to use it**
- Include key trigger terms for discovery

Optional fields:

| Field | Use When |
|-------|----------|
| `argument-hint` | Skill accepts arguments (e.g., `[filename]`) |
| `disable-model-invocation` | Only user should trigger (deploy, commit) |
| `user-invocable: false` | Background knowledge Claude auto-loads |
| `allowed-tools` | Restrict tools available during skill |
| `context: fork` | Run in isolated subagent |

See [templates.md](templates.md) for frontmatter examples.

### Step 4: Write SKILL.md Body

Structure:
1. **Title** - What the skill does
2. **When to Activate** - Trigger conditions
3. **Core content** - Minimal instructions Claude needs
4. **References** - Links to detailed files

Guidelines:
- Under 500 lines
- Challenge each paragraph: "Does Claude need this?"
- Use tables for quick reference, not verbose explanations
- Provide one recommended approach, not multiple options

See [templates.md](templates.md) for body templates.

### Step 5: Create Reference Files

For each reference file:
- Add table of contents if > 100 lines
- Use descriptive filenames: `error-handling.md`, not `doc2.md`
- Link from SKILL.md with clear context for when to read

### Step 6: Validate

Run through the quality checklist: [checklist.md](checklist.md)

## Extracting Skills from Codebases (`analyze` mode)

When creating skills by analyzing an existing codebase:

1. **Analyze git history** for recurring patterns
2. **Identify conventions** in folder structure, naming, workflows
3. **Extract only non-obvious patterns** Claude wouldn't infer from code alone
4. **Generate skill** following the workflow above

```bash
# Useful git analysis commands
git log --oneline -n 200 --name-only --pretty=format:"%H|%s|%ad" --date=short
git log --oneline -n 200 --name-only | grep -v "^$" | grep -v "^[a-f0-9]" | sort | uniq -c | sort -rn | head -20
git log --oneline -n 200 | cut -d' ' -f2- | head -50
```

## Improving Existing Skills (`improve` mode)

When refactoring an existing skill:

1. Read the current SKILL.md and all referenced files
2. Evaluate against [checklist.md](checklist.md)
3. Identify issues: verbosity, missing progressive disclosure, vague descriptions
4. Refactor following the workflow above
5. Verify no references are broken

## Output Location

Skills are placed in `.claude/skills/<skill-name>/SKILL.md` (personal or project scope).

## Anti-Patterns to Avoid

| Anti-Pattern | Fix |
|-------------|-----|
| Verbose explanations of things Claude knows | Remove; assume Claude is smart |
| Multiple equivalent approaches offered | Pick one default, mention alternative only if context-dependent |
| Deeply nested file references | Keep one level deep from SKILL.md |
| Vague names like `helper`, `utils` | Use specific gerund names |
| Time-sensitive information | Use "old patterns" collapsible section |
| Windows-style paths (`\`) | Always use forward slashes (`/`) |
| Magic constants without justification | Document why each value was chosen |
| Separate `.claude/commands/` file for a skill | Use skill's `name` field for `/slash-command` |
