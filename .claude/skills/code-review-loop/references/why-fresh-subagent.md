# Why a Fresh Subagent

A dispatched subagent receives only the carefully scoped prompt in `code-reviewer.md` — not the entire session history. This matters because:

1. The reviewer evaluates the **work product**, not the author's thought process. This avoids confirmation bias ("the author clearly meant well, so it's fine").
2. The main agent's context is preserved for continued work instead of being consumed by review chatter.
3. A fresh perspective is more likely to catch assumptions that became invisible to the implementer.
