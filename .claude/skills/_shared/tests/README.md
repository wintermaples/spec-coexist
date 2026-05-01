# spec-coexist trigger tests

This directory holds the trigger-test assets for every skill under `.claude/skills/`.

## Files

- `trigger-cases.jsonl` — one JSON object per line; each entry is a (prompt → expected skill) pair. Schema and authoring rules live in `../../_meta/authoring-references/trigger-tests.md`.
- `run_trigger_tests.sh` — static validator that checks JSON validity, required fields, skill-directory existence, and coverage (≥ 3 positive + ≥ 1 negative cases per skill, including at least one ja and one en positive).

## How to run

```bash
bash .claude/skills/_shared/tests/run_trigger_tests.sh
```

Exit code is 0 on success and 1 on any failure. The script is safe to wire into CI: it has no side effects and only needs `python3`.

## What this is NOT

This is a **static** validator. It does not fire prompts against Claude and does not observe which skill actually triggers at runtime. A live runner is tracked as follow-up work in `SPEC_COEXIST_EXTENSION_PLAN.md` §6. Until that lands, this validator is the mechanical half of the regression net; a human reviewer of each new skill is the other half.

## When to update

Whenever a skill is added, renamed, or has its trigger phrases changed, update `trigger-cases.jsonl` in the same commit. The `_meta/authoring-skill` conformance checklist enforces this at skill-creation time, and the validator enforces it mechanically on every CI run.

## Adding cases for a new skill

See the skill-authoring reference at `../../_meta/authoring-references/trigger-tests.md`. In short:

- ≥ 3 positive cases, covering ja + en + at least one implicit phrasing.
- ≥ 1 negative case, ideally a near-miss against an adjacent skill.
- Prompts must read like something a real engineer would type.
