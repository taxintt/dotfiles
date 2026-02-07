# Skill Templates

## YAML Frontmatter Examples

### Good: Specific, third-person, includes triggers

```yaml
---
name: processing-pdfs
description: Extracts text and tables from PDF files, fills forms, and merges documents. Use when working with PDF files or when the user mentions PDFs, forms, or document extraction.
---
```

```yaml
---
name: golang-testing
description: Go testing patterns including table-driven tests, subtests, benchmarks, fuzzing, and test coverage. Use when writing or reviewing Go tests.
---
```

### Bad: Vague or wrong perspective

```yaml
# Too vague
description: Helps with documents

# Wrong perspective (first person)
description: I can help you process Excel files

# Wrong perspective (second person)
description: You can use this to process Excel files

# Missing triggers
description: Processes data from various sources
```

## SKILL.md Body Template

### Simple Skill (instruction-only)

````markdown
---
name: {skill-name}
description: {What it does}. {When to use it}.
---

# {Skill Title}

{One-line summary of what the skill provides.}

## When to Activate

- {Trigger condition 1}
- {Trigger condition 2}
- {Trigger condition 3}

## {Core Section}

{Minimal instructions, tables, or code examples that Claude needs.}

## {Optional Section}

{Additional context only if Claude truly needs it.}
````

### Standard Skill (with references)

````markdown
---
name: {skill-name}
description: {What it does}. {When to use it}.
---

# {Skill Title}

{One-line summary.}

## When to Activate

- {Trigger conditions}

## Quick Reference

| {Column 1} | {Column 2} |
|-------------|-------------|
| {item} | {description} |

## {Core Section}

{Essential instructions.}

## Detailed References

- `{topic-a}.md` - {When to read this file}
- `{topic-b}.md` - {When to read this file}
````

### Workflow Skill (with checklist)

````markdown
---
name: {skill-name}
description: {What it does}. {When to use it}.
---

# {Skill Title}

{One-line summary.}

## When to Activate

- {Trigger conditions}

## Workflow

Copy this checklist and track progress:

```
Progress:
- [ ] Step 1: {action}
- [ ] Step 2: {action}
- [ ] Step 3: {action}
```

### Step 1: {Action}

{Instructions for this step.}

### Step 2: {Action}

{Instructions. If validation fails, return to Step 1.}

### Step 3: {Action}

{Final step with verification.}
````

## Command Template

````markdown
---
name: {command-name}
description: {What the command does}
allowed_tools: ["Read", "Write", "Glob", "Grep", "Bash"]
---

# /{command-name}

{Brief description of what happens when invoked.}

## Steps

1. {First action}
2. {Second action}
3. {Output or result}
````

## Degrees of Freedom Guide

### High Freedom (text-based, context-dependent)

```markdown
## Code review process
1. Analyze the code structure
2. Check for potential bugs or edge cases
3. Suggest improvements for readability
```

### Medium Freedom (preferred pattern with flexibility)

````markdown
## Generate report
Use this template and customize as needed:
```python
def generate_report(data, format="markdown"):
    # Process data, generate output
```
````

### Low Freedom (exact steps, fragile operations)

````markdown
## Database migration
Run exactly this script:
```bash
python scripts/migrate.py --verify --backup
```
Do not modify the command or add additional flags.
````
