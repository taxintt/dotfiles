# taxin's dotfiles

Personal dotfiles for macOS. Covers shell, git, tmux, and terminal configuration,
plus agent configuration for Claude Code and Codex CLI.

## Contents

| Path | Description |
|---|---|
| `.zshrc` `.gitconfig` `.tmux.conf` `.config/` | Shell, git, and terminal configuration |
| `.claude/skills/` | Claude Code skills (35) |
| `.claude/agents/` | Subagent definitions (8) |
| `.claude/hooks/` | PreToolUse / PostToolUse / Stop verification hooks (5) |
| `.claude/settings.json` | Permissions, sandbox, and plugin configuration |
| `.codex/` | Codex CLI configuration |
| `AGENTS.md` | Coding conventions shared by Claude Code and Codex CLI. Linked to `~/.claude/CLAUDE.md` and `~/.codex/AGENTS.md` |
| `BrewFile` | Homebrew package list |

## Setup

### 1. Install packages

```bash
make brew
```

### 2. Create `.gitconfig.local`

Git user identity is kept out of this repository and lives in `~/.gitconfig.local`,
which `.gitconfig` pulls in via `[include]`. Create it before running `make link`.

```bash
cat > .gitconfig.local <<'EOF'
[user]
	name = <git_username>
	email = <git_email_address>
EOF
```

### 3. Create the symlinks

```bash
make link
```

This symlinks each config into `~/`. **Existing files with the same name are overwritten.**

## Other commands

```bash
make help
```

## License

MIT — see [LICENSE](LICENSE). Some material is derived from third parties:

- `.claude/skills/japanese-tech-writing/` — from a gist by k16shikano (Unlicense)
- `.claude/skills/systematic-debugging/`, `.claude/skills/verification-before-completion/` — based on [obra/superpowers](https://github.com/obra/superpowers) (MIT)
