# spec-coexist trigger tests

This directory holds the trigger-test assets for every skill in `.claude/skills/`.

## Files

- `trigger-cases.jsonl` — one JSON object per line. Each entry is a (prompt → expected skill) pair. Schema and authoring rules: `../../authoring-spec-coexist-skill/references/trigger-tests.md`.
- `run_trigger_tests.sh` — static validator. Checks JSON validity, required fields, skill directory existence, and coverage requirements (≥ 3 positive + ≥ 1 negative per skill, plus at least one ja and one en positive).

## How to run

```bash
bash .claude/skills/_shared/tests/run_trigger_tests.sh
```

Exit code 0 on success, 1 on any failure. Safe to wire into CI — the script has no side effects and only needs `python3`.

## What this is NOT

This is a **static** validator. It does not fire prompts against Claude and does not observe which skill actually triggers at runtime. A live runner is tracked in `SPEC_COEXIST_EXTENSION_PLAN.md` §6 as follow-up work. Until it lands, this validator is the mechanical half of the regression net; the human reviewer of a new skill is the other half.

## When to update

Whenever a skill is added, renamed, or has its trigger phrases changed, update `trigger-cases.jsonl` in the same commit. The `authoring-spec-coexist-skill` conformance checklist enforces this at skill-creation time, and the validator enforces it mechanically on every CI run.

## Adding cases to a new skill

See the skill-authoring reference at `../../authoring-spec-coexist-skill/references/trigger-tests.md`. In short:

- ≥ 3 positive cases, covering ja + en + one implicit phrasing.
- ≥ 1 negative case, ideally a near-miss against an adjacent skill.
- Prompts must read like something a real engineer would type.
