# Anti-patterns and Invalid Rationalizations — verification-before-completion

## Anti-patterns

Treat each as a trigger to run the gate, not as completed verification.

- **"It should work."** — Not evidence. Run it.
- **"I just ran the tests a minute ago."** — Not fresh. Run again after the last edit.
- **"The relevant tests pass."** — Which ones? Show the output.
- **"Lint passes (I didn't change anything it would care about)."** — Run it anyway.
- **"I'll fix the remaining warnings later."** — Fine, but then the claim is "implemented with 3 known warnings listed below", not "done".
- **Reporting completion and *then* running verification in the next turn.** — The gate runs *before* the claim, not after.

## Rationalizations That Do NOT Excuse Skipping the Gate

- "The change is trivial."
- "I'm confident it works."
- "The user is waiting."
- "Just this once."
- "I already ran it earlier in the session."
- "Running the full suite is slow."

If the full suite is genuinely too slow, tell the user and agree on a reduced scope in advance — do not silently skip.
