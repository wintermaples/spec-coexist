# Conformance Checklist

Walk this checklist before step 10 (verification). Any unchecked item **MUST** block completion. Copy the list into the session and mark each item explicitly — do not skim.

## Frontmatter

- [ ] `name` matches the directory name exactly.
- [ ] `user-invocable` is set to `true` or `false` (not omitted). Justification matches `user-invocable-policy.md`.
- [ ] `description` starts with `Use whenever` or `Use at the start of`.
- [ ] `description` contains at least one Japanese trigger phrase in `"..."` form.
- [ ] `description` contains at least one English trigger phrase in `"..."` form.
- [ ] `description` contains at least one negative cue (`Do NOT trigger for ...` or `This skill MUST NOT ...` for scope).
- [ ] `description` ends with the independence clause verbatim: `This skill is self-contained and MUST NOT delegate to any \`superpowers:*\` skill.`
- [ ] `description` is 80–180 words (rough target; enforce with judgment).

## Body length

- [ ] Body (everything after the closing `---`) is ≤ 80 lines, including blank lines.
- [ ] No consecutive prose block exceeds 3 paragraphs before a list / diagram / link breaks it.

## Structure

- [ ] Body contains `# {{skill-name}}` as the first heading.
- [ ] Body contains an RFC 2119 reference line.
- [ ] Body contains an `## Independence` section with the MUST NOT clause.
- [ ] Body contains `## Ordered Steps` with numbered, imperative steps.
- [ ] Last or second-to-last ordered step is `verification-before-completion` (unless the skill is itself a gate, in which case document why).
- [ ] Body contains `## References` listing every reference file it uses.
- [ ] Body contains `## Scripts` (even if "None.") so the reader knows whether side effects exist.

## References on disk

- [ ] Every `references/*.md` path mentioned in the body exists as a file.
- [ ] No reference file is empty or contains only a title.
- [ ] Each reference file has a single clear purpose (do not create a `misc.md`).

## Scripts

- [ ] No script source code is inlined in SKILL.md beyond an invocation example.
- [ ] Shared scripts live under `.claude/skills/_shared/scripts/`.
- [ ] Skill-local scripts live under `<skill>/scripts/`.

## Registration

- [ ] `spec-coexist-router` (SKILL.md or its references) includes this skill in the inventory with its trigger condition.
- [ ] If the skill is meant to be called by other skills, at least one caller's SKILL.md or references mention it by name.

## Trigger tests

- [ ] `_shared/tests/trigger-cases.jsonl` contains ≥ 3 positive cases for this skill.
- [ ] `_shared/tests/trigger-cases.jsonl` contains ≥ 1 negative case (a prompt that should NOT trigger this skill).
- [ ] Positive cases include at least one Japanese prompt and one English prompt.

## Independence

- [ ] No part of SKILL.md or its references invokes, mentions, or relies on any `superpowers:*` skill except to explicitly forbid it.
- [ ] No `superpowers:` string appears in scripts.

## Final

- [ ] The author has read the final SKILL.md top to bottom once more, with fresh eyes, and can state the skill's purpose in one sentence.
