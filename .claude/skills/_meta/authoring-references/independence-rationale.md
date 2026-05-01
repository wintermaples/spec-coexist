# Why spec-coexist Does Not Delegate to `superpowers:*`

Every spec-coexist skill — including this one — carries the clause:

> This skill is self-contained and MUST NOT delegate to any `superpowers:*` skill.

This is not a rivalry or a not-invented-here reflex. It is a deliberate architectural choice with four concrete reasons.

## 1. Versioning and reproducibility

`superpowers` is distributed as a plugin under `~/.claude/plugins/cache/.../superpowers/{version}/`. Its version is not pinned by this repository's git history. A skill that delegates to `superpowers:test-driven-development` produces different behavior depending on which plugin version the user happens to have installed. For a suite that is supposed to be auditable — where "on commit X, the spec-coexist behavior was exactly this" must hold — that non-determinism is unacceptable.

Keeping every skill self-contained in `.claude/skills/` ensures the suite's behavior is fully captured in git: `git checkout` gives you the exact behavior of that commit.

## 2. Auditability and the RFC 2119 guarantee

spec-coexist skills use RFC 2119 vocabulary (MUST / SHOULD / MAY) because the suite is built for contexts — regulated industries, enterprise SI, compliance-sensitive projects — where "the tool MUST do X" needs to mean something legally defensible. `superpowers` does not declare RFC 2119 conformance, and its normative language is informal ("Iron Law", all-caps "NEVER"). Delegating across that boundary silently downgrades the guarantee: a spec-coexist skill makes a MUST-level promise, then hands control to a skill that does not operate at that level.

## 3. Trigger-space and namespace collisions

Several skill names collide across suites: `systematic-debugging`, `verification-before-completion`, `code-review-loop`. If a spec-coexist skill delegates by unqualified name, which one runs depends on harness resolution order — fragile and environment-dependent. Forbidding cross-suite delegation entirely avoids the question. All collisions are resolved statically by namespace (`spec-coexist:` vs `superpowers:`) at the caller layer, not at skill runtime.

## 4. Context budget

A cross-suite call loads both suites' SKILL.md bodies into context, doubling the tax for no benefit when spec-coexist already has a thinner, project-local equivalent. The suite's thin-orchestrator design (≤ 80 lines per SKILL.md) exists precisely to keep the budget lean. Delegating to a 371-line `superpowers:test-driven-development` undoes that work.

## What is allowed

- A human operator may invoke `superpowers:*` directly in the same conversation as a spec-coexist skill. That is a runtime coincidence, not a delegation.
- The comparison documents (`SKILLS_COMPARISON.md`, `SPEC_COEXIST_EXTENSION_PLAN.md`) may discuss `superpowers` freely — they are documentation, not skill code.
- An orchestration layer *above* both suites — e.g. a CLAUDE.md or a human running `/` commands — may sequence skills from both suites. The prohibition is specifically against a spec-coexist skill invoking a `superpowers:*` skill from *within its own Ordered Steps*.

## What happens if a new skill breaks the rule

The conformance checklist fails (see `conformance-checklist.md` → Independence section), which blocks step 10 (verification), which blocks the completion claim. The skill cannot be marked done. This is by design: the rule is enforced at the gate, not by goodwill.
