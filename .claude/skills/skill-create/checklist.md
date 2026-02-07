# Skill Quality Checklist

Validate each item before finalizing a skill.

## Frontmatter

- [ ] `name`: max 64 chars, lowercase/numbers/hyphens only
- [ ] `name`: gerund form preferred (`processing-pdfs`, not `pdf-processor`)
- [ ] `name`: no reserved words (`anthropic`, `claude`)
- [ ] `description`: non-empty, max 1024 chars
- [ ] `description`: third person ("Processes...", not "I can..." or "You can...")
- [ ] `description`: includes what it does AND when to use it
- [ ] `description`: includes key trigger terms for discovery

## Content Quality

- [ ] SKILL.md body under 500 lines
- [ ] Only information Claude doesn't already know
- [ ] No verbose explanations of common concepts
- [ ] One recommended approach per task (not multiple equivalent options)
- [ ] Consistent terminology throughout
- [ ] No time-sensitive information (or in collapsible "old patterns" section)
- [ ] Concrete examples, not abstract descriptions

## Structure

- [ ] Progressive disclosure: overview in SKILL.md, details in separate files
- [ ] File references are one level deep (no nested chains)
- [ ] Reference files > 100 lines have table of contents
- [ ] Descriptive filenames (`error-handling.md`, not `doc2.md`)
- [ ] Forward slashes in all paths (no `\`)
- [ ] "When to Activate" section present

## Workflows (if applicable)

- [ ] Clear sequential steps
- [ ] Copyable checklist for progress tracking
- [ ] Feedback loops for quality-critical operations (validate -> fix -> repeat)
- [ ] Decision points clearly marked (conditional workflows)

## Scripts (if applicable)

- [ ] Scripts handle errors explicitly (don't punt to Claude)
- [ ] No magic constants (all values justified)
- [ ] Required packages listed
- [ ] Clear whether to execute or read as reference
- [ ] Validation/verification steps for critical operations

## Commands (if applicable)

- [ ] `allowed_tools` lists only required tools
- [ ] Description matches actual behavior
- [ ] Placed in correct location (`.claude/commands/` or skill's `commands/`)
