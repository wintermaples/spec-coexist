# Fallback Mode

Conformance keywords follow [RFC 2119](https://www.rfc-editor.org/rfc/rfc2119) / [RFC 8174](https://www.rfc-editor.org/rfc/rfc8174).

## When This Mode Activates

The skill **MUST** switch to fallback mode when any of the following is detected:

- `gh` CLI is not installed or not on `PATH`.
- `gh auth status` reports no authenticated user.
- The current user does not have push permission to the target remote (detected by a dry-run `git push --dry-run` returning a permission error).
- The target remote is unreachable from the current environment.

In fallback mode, the skill **MUST NOT** attempt to execute the integration step itself. Guessing at a substitute command or bypassing the missing capability is prohibited.

## What Fallback Mode Does

It prints a **manual runbook** to the user — copy-pasteable commands the user can run from their own terminal to complete the integration. The runbook **MUST** include, in order:

1. The exact branch name and target.
2. The shaped commit list (`git log --oneline <base>..HEAD`).
3. The sequence of commands to run (`git push -u origin <branch>`, `gh pr create ...` or an equivalent web-UI instruction).
4. The prepared PR body (title + summary + evidence links) as a fenced block the user can copy.
5. The post-merge handoff path the user should update after the merge lands.

## What Fallback Mode Does Not Do

- It does **NOT** execute any write operation on the repository or the remote.
- It does **NOT** fabricate a `docs/evidence/` record claiming integration happened.
- It does **NOT** mark the skill as complete until the user confirms that the runbook will be executed manually.

## Reporting

The final report in fallback mode **MUST** state clearly that integration was handed off to the user and list what the user still needs to do. The `Review:` outcome line **MUST** reflect "handed off — manual completion pending", not "done".
