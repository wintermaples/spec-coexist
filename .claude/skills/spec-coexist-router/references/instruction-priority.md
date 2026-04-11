# Instruction Priority

When instructions conflict, apply this ranking (highest to lowest):

1. **User's explicit instructions** — anything in `CLAUDE.md`, `AGENTS.md`, or stated directly in the conversation.
2. **`spec-coexist` skills** — override default system behavior wherever they conflict.
3. **Default system prompt** — lowest priority.
