# Hard Constraints — finishing-subsystem-work

Conformance keywords follow [RFC 2119](https://www.rfc-editor.org/rfc/rfc2119) / [RFC 8174](https://www.rfc-editor.org/rfc/rfc8174).

## HALT Preconditions

The skill **MUST** halt immediately — before any file is modified or any git command is run — if any of the following is false:

1. **Verification evidence present.** At least one file matching `docs/evidence/verification-*.md` exists whose `subject:` front-matter field clearly corresponds to the work being finished. If the evidence is ambiguous, ask the user to name the specific file; do not guess.
2. **Review closure.** The most recent `code-review-loop` session for this subject reports zero unresolved Critical or Important findings. "I'll fix it in a follow-up" does **NOT** satisfy this precondition for Critical/Important severities. (Nit / Suggestion severities **MAY** be deferred if the user acknowledges them explicitly.)
3. **Working tree sanity.** There **MUST NOT** be untracked files outside the intended change scope. The agent **MUST** run `git status` and surface anything unexpected to the user before proceeding.

A HALT here is not a failure of this skill — it is the skill doing its job. Route the user to the upstream skill that closes the gap (`implementing-from-spec`, `revising`, `verification-before-completion`, or `code-review-loop`).

## Forbidden Operations

This skill **MUST NOT** execute any of the following, under any circumstances, within its own procedure:

- `git reset --hard`
- `git push --force` / `git push -f` / `git push --force-with-lease`
- `git branch -D`
- `git clean -f` / `git clean -fd`
- `git commit --amend` on commits that have already been pushed to a shared remote
- `git rebase -i` (interactive mode is unsupported in this environment)
- `git commit --no-verify`, `--no-gpg-sign`, or any flag that bypasses hooks or signing

If the user explicitly requests one of these operations, the skill **MUST** stop, explain why it is forbidden *inside this skill*, and hand control back to the user to run the command themselves. The user's authority to run destructive commands is not inherited by the skill.

## Confirmation Gate (Step 5)

Before any push, PR create, or merge, the skill **MUST**:

1. Print the full commit list (`git log --oneline <base>..HEAD`), the target branch, and the intended integration mode in a single message.
2. Ask an explicit yes/no question: "Proceed with `{mode}` against `{target}`?"
3. Wait for an affirmative reply. Ambiguous replies ("I think so", "maybe", "go ahead and figure it out") **MUST** be treated as "no" and re-prompted.

A single affirmative covers exactly the confirmed mode and target. It does **NOT** authorise subsequent pushes, additional branches, or follow-up PRs.

## Scope Discipline

The skill **MUST NOT** include unrelated changes in the final integration. If `git status` shows edits outside the subject's scope, the skill **MUST** either (a) stash them and surface their existence to the user, or (b) halt and ask how to proceed. Silently bundling unrelated edits is a scope violation.
