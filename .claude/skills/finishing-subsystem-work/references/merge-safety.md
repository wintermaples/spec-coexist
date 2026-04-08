# Merge Safety

Conformance keywords follow [RFC 2119](https://www.rfc-editor.org/rfc/rfc2119) / [RFC 8174](https://www.rfc-editor.org/rfc/rfc8174).

This document catalogues which git operations are safe to perform from inside `finishing-subsystem-work`, which are forbidden, and the reasoning behind each rule so edge cases can be judged.

## Safe (MAY execute with step-5 confirmation)

- `git add <specific files>` — never `git add -A` or `git add .`; those bundle unrelated edits.
- `git commit` (with hooks and signing intact)
- `git push` to a feature branch whose remote tracking ref is the same branch (fast-forward only)
- `gh pr create` (with a body assembled from the changelog entry and evidence links)
- `git merge --ff-only` — only if the user explicitly chose "merge" at step 5 AND the merge is actually fast-forward. If not fast-forward, HALT and ask.

## Forbidden (MUST NOT execute)

- Any operation listed in `hard-constraints.md` §"Forbidden Operations".
- `git push` to `main` / `master` / `trunk` when the current branch is that same branch. Feature branches only. For direct-to-main pushes the user must run the command themselves.
- `git merge` without `--ff-only` from inside this skill — a non-fast-forward merge rewrites history implicitly. If the user wants a merge commit, they run it.
- Any `gh` subcommand that closes, deletes, or force-updates an existing PR created by someone else.

## Rationale

The blast radius of a destructive git operation is irreversible loss of work. The cost of asking the user is a single message. The ratio is never close. Everything in the "Forbidden" list has a history of turning a successful implementation into an incident — force-push to a shared branch in particular has no undo from the remote side.

Fast-forward pushes to a feature branch are the only git operations whose failure mode is bounded: worst case, the remote rejects the push and the local state is untouched. Everything else can put the repository in a state the user cannot recover without extraordinary measures.

## Edge Cases

- **Pre-existing merge conflict on the feature branch.** HALT. Conflict resolution is a judgement call that belongs to the user, not to an automation skill.
- **Hook failure on commit.** Do **NOT** retry with `--no-verify`. Read the hook output, fix the underlying issue (usually a lint/test regression), re-stage, and create a new commit.
- **Signing failure.** Same as above — never bypass. Ask the user to fix their signing setup and re-run.
- **Detached HEAD.** HALT. A finish operation in detached HEAD has nowhere to push to. Ask the user to check out a named branch first.
- **Dirty working tree outside the subject scope.** See `hard-constraints.md` §"Scope Discipline".

## Interaction with the Fallback Mode

When `gh` is missing or push permissions are absent, `fallback-mode.md` takes over: the skill prints a manual runbook and does not attempt any write operation. This is the correct response — it is better to hand the user a runbook than to guess at a substitute command.
