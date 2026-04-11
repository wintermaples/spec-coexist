# Trigger Test Format

Trigger tests live at `.claude/skills/_shared/tests/trigger-cases.jsonl`. Each line is one JSON object representing a (prompt → expected skill) pair. The file is append-only; new skills add their cases at the bottom.

## Schema

```json
{
  "id": "revising-pos-1",
  "skill": "revising",
  "prompt": "spec-coexist に新しいスキルを追加したい",
  "language": "ja",
  "expect": "trigger",
  "note": "direct create request, Japanese"
}
```

Fields:

- `id` — `{skill}-{pos|neg}-{n}`. Positive cases assert the skill *should* trigger; negative cases assert it *should not*.
- `skill` — the skill under test. For negative cases, still name the skill whose boundary is being tested.
- `prompt` — verbatim user message. No paraphrasing; it should read like something a real user would type.
- `language` — `ja`, `en`, or `mixed`.
- `expect` — `trigger` or `no-trigger`.
- `note` — one line of context. What aspect of the trigger space this case covers.

## How many cases per skill

Minimum per the hard constraints: **≥ 3 positive, ≥ 1 negative**. Recommended: 4 positive + 2 negative.

Positive case coverage should include:

1. A direct, explicit request in Japanese.
2. A direct, explicit request in English.
3. An implicit request — the user describes the problem without naming the skill.

Negative case coverage should include at least:

1. A "near-miss" — a prompt that shares keywords with the skill but actually needs an adjacent skill (e.g., for `creating-basic-design`, a prompt asking to *update* an existing design).

## Writing good prompts

Good:

- `"基本設計書、main-basic-design.md をまず作りたいんだけど"`
- `"I just finished the new payment subsystem, need to write the requirements doc for it"`
- `"このバグどうしても再現しないんだけどちょっと見てくれる?"`

Bad:

- `"create a design"` — too vague, no user texture
- `"Use creating-basic-design skill to create a design"` — the user would never write the skill name; this tests nothing
- `"help"` — signals nothing

A prompt is good if you can imagine it being typed by a stressed engineer on a Tuesday afternoon.

## Negative cases are where triggering gets interesting

Most false positives come from over-general trigger phrases matching adjacent territory. A negative case like `"要件を少し直したい"` for `creating-requirements` (it should route to `revising`, not `creating-requirements`) is worth more than five obvious positive cases. Budget your attention accordingly.

## Running the tests

A runner script does not yet exist — this is Phase 0 work (see `SPEC_COEXIST_EXTENSION_PLAN.md` §6). Until then, the file serves as a specification: human reviewers check new skills against these cases manually. When the runner lands, it will consume this same file without format changes.
