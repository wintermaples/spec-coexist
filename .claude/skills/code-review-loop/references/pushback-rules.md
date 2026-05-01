# Pushback rules

Detailed pushback policy for `code-review-loop`.

## When pushback is legitimate — and sometimes required

- The suggestion would break existing functionality.
- The reviewer lacks full context.
- The suggestion violates YAGNI for unused code.
- The suggestion is technically incorrect for this stack.
- Legacy or compatibility reasons justify the current approach.
- The suggestion conflicts with architectural decisions the user has already made.

## How to push back correctly

- Use technical reasoning, not defensiveness.
- Reference specific code, tests, or docs.
- Ask targeted clarifying questions.
- Escalate to the user when the conflict is architectural.

## When a pushback turns out to be wrong

If a pushback later turns out to be wrong, the agent **MUST** state the correction factually and move on — no long apology, no defending the original pushback.
