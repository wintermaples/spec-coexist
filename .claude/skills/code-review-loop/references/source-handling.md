# Source-specific handling

Trust levels and verification requirements vary by where the review feedback originated.

## From the `code-reviewer` subagent (via `code-review-loop`)

- Treat as a knowledgeable but context-limited external reviewer.
- **MUST** verify each suggestion against the codebase before acting.
- **MAY** push back with technical reasoning when the reviewer lacks context.

## From the user directly

- Trusted. Implement after understanding, but **MUST** still ask if scope is unclear.
- **MUST NOT** produce performative agreement — skip straight to action.

## From an external reviewer (human, PR comments, etc.)

Be skeptical but careful. Before implementing, check:

1. Is this correct for *this* codebase?
2. Would it break existing functionality?
3. Is there a reason the current implementation exists?
4. Does the reviewer have full context?

If the agent cannot verify a suggestion without more information, it **MUST** say so rather than guess.
