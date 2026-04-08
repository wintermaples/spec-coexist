# Severity Policy

## Thresholds

- **Critical** — **MUST** be fixed before the calling skill reports completion.
- **Important** — **MUST** be fixed before the calling skill reports completion, unless the user is explicitly asked and explicitly waives it.
- **Minor** — **MAY** be deferred. If deferred, the agent **MUST** list them in the final report so they are not lost.

## Pushback

If the reviewer is technically wrong, the agent **SHOULD** push back using the `receiving-code-review` skill's rules (technical reasoning, reference to code/tests). Pushback is legitimate; performative agreement is not.
