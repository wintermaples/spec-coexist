# Pushback Rules

Detailed pushback policy for `code-review-loop`.

## When Pushback Is Legitimate — and Sometimes Required

- The suggestion would break existing functionality.
- The reviewer lacks full context.
- The suggestion violates YAGNI for unused code.
- The suggestion is technically incorrect for this stack.
- Legacy / compatibility reasons justify the current approach.
- The suggestion conflicts with architectural decisions the user has already made.

## How to Push Back Correctly

- Use technical reasoning, not defensiveness.
- Reference specific code / tests / docs.
- Ask targeted clarifying questions.
- Escalate to the user if the conflict is architectural.

## When a Pushback Turns Out to Be Wrong

If a pushback later turns out to be wrong, the agent **MUST** state the correction factually and move on — no long apology, no defending the original pushback.
