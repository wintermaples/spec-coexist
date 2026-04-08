# Commit Shaping

Conformance keywords follow [RFC 2119](https://www.rfc-editor.org/rfc/rfc2119) / [RFC 8174](https://www.rfc-editor.org/rfc/rfc8174).

## Rule

One logical change = one commit. A "logical change" is the smallest unit that can be reverted on its own without breaking the build or leaving the codebase in an inconsistent state.

## Consequences

- A feature that adds a new module + wires it into the router **MAY** be a single commit (the wiring is part of the same logical change).
- A feature that adds a new module AND refactors an unrelated helper **MUST** be two commits. The refactor is a separate logical change.
- Changelog entries **MUST** travel in the same commit as the code they describe, not a trailing "docs: update changelog" commit.
- Acceptance test, RED evidence reference, and production code **SHOULD** live in the same commit when possible so the commit is self-contained for bisect.

## Shaping Procedure

1. Run `git status` and `git diff --stat` to see the full scope of staged + unstaged changes.
2. Group changes by logical unit. Use `git add -p` for hunk-level staging. Do **NOT** use `git add -A` or `git add .` — they bundle unrelated edits.
3. Commit each group with a message that states the *why*, not just the *what*. Reference the acceptance bullet or issue when applicable.
4. Verify with `git log --oneline <base>..HEAD` that each line reads as a single coherent change.

## Forbidden Shortcuts

- Do **NOT** use `git commit --amend` on a commit that has already been pushed.
- Do **NOT** use `git rebase -i` (interactive rebase is unsupported in this environment).
- Do **NOT** "squash everything into one commit at the end" as a substitute for shaping as you go — the history loses its bisect value.

## When the Work Is Already One Commit

If the upstream skill already produced a single, well-shaped commit, this step is a no-op — confirm the shape and proceed. Do not re-shape for its own sake.
