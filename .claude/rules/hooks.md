# Hooks System

## Hook Types

- **PreToolUse**: Before tool execution (validation, parameter modification)
- **PostToolUse**: After tool execution (auto-format, checks)
- **Notification**: When Claude needs user attention (permission prompts, idle state)
- **Stop**: When session ends (final verification)

## Current Hooks (in .claude/settings.json)

### Notification
- **permission_prompt**: Notifies user when permission is needed
- **idle_prompt**: Notifies user when Claude is idle
- **tool_permission_prompt**: Notifies user when tool permission is needed
- **user_question_prompt**: Notifies user when Claude asks a question

All notification hooks use `~/.claude/hooks/claude-notification.sh`

## Auto-Accept Permissions

Use with caution:
- Enable for trusted, well-defined plans
- Disable for exploratory work
- Never use dangerously-skip-permissions flag
- Configure `allowedTools` in `~/.claude.json` instead

## TodoWrite Best Practices

Use TodoWrite tool to:
- Track progress on multi-step tasks
- Verify understanding of instructions
- Enable real-time steering
- Show granular implementation steps

Todo list reveals:
- Out of order steps
- Missing items
- Extra unnecessary items
- Wrong granularity
- Misinterpreted requirements
