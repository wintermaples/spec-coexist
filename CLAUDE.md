# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**spec-coexist** is a spec-driven development skill suite for Claude Code. It keeps specifications and implementation in sync ("coexist") across the full development lifecycle: problem exploration → requirements → basic design → implementation → review → completion.

Primary language: Japanese (日本語). English templates and docs also provided.

## Build & Package Commands

```bash
# Package the plugin for distribution
./scripts/package-spec-coexist.sh
# Output: dist/spec-coexist-<version>.tar.gz

# Run trigger tests (skill routing validation)
bash .claude/skills/_shared/tests/run_trigger_tests.sh
```

**Version source of truth:** `packaging/spec-coexist/.claude-plugin/plugin.json` — bump `version` here before packaging.

## Architecture

### Task-Tier System (T0–T3)

The `spec-coexist-router` classifies every user message into a tier and routes to the appropriate skill(s):

- **T0** (trivial, ≤10 lines): direct edit via `fast-path`
- **T1** (small, single function/bugfix): TDD + verification via `fast-path`
- **T2** (medium, feature): align with existing specs + TDD + self-check + review
- **T3** (large, new subsystem): full spec pipeline

### Skill Layout

All skills live in `.claude/skills/` and are live-reloaded by Claude Code: edits take effect on the next turn with no restart needed. Each skill is a directory containing a `SKILL.md` file.

**Underscore-prefixed directories are infrastructure, not skills:**
- `_docs/` — end-user guides (ja/en)
- `_meta/` — skill authoring guides for contributors
- `_shared/` — cross-skill scripts, templates, schemas, references, tests
- `_utils/` — CI workflow templates for downstream consumers

### Skill Pipeline Flow

```
exploring-problem-space → creating-requirements → creating-basic-design
    → creating-detail-design (optional, recommended)
    → implementing-from-spec (uses test-driven-implementation)
    → pre-review-self-check → code-review-loop
    → verification-before-completion → finishing-subsystem-work
```

Side paths: `revising` (spec or impl changes), `systematic-debugging` (bugs), `delivery-snapshot` (status reports), `parallelizing-subsystem-work` (concurrent worktree impl).

### Key Invariants

- Skills **must not** update existing spec documents directly — they must route through `revising`
- All work ≥T1 requires evidence artifacts (dual-write: Markdown under `docs/evidence/`, JSON under `.spec-coexist/evidence/{task_id}/`)
- Skills are self-contained — they do not delegate to `superpowers:*` skills
- Traceability chain: REQ-ID → DES-ID → test-ID → code

### Locale Resolution

Templates exist in `ja` (co-located in skill `references/`) and `en` (centralized in `_shared/templates/en/`). Resolution order: explicit override → existing doc language → conversation language (CJK → ja) → default ja.

### Shared Scripts (`_shared/scripts/`)

POSIX shell scripts for document validation, subsystem management, worktree operations, evidence recording, and a lightweight Visual Companion HTTP server (Python stdlib only).

### Packaging & Distribution

The packaging script assembles the contents of `.claude/skills/` into the official Claude Code plugin layout under `packaging/spec-coexist/.claude-plugin/`. The `dist/` directory is gitignored.

### CI (`_utils/github-workflows/spec-coexist.yml`)

Designed for **downstream consumers** (not this repo's own CI). Gates: tier detection, evidence schema validation, evidence completeness, REQ-ID traceability, doc link integrity. Copy to `.github/workflows/` in consuming repos.

### Test Cases

`_shared/tests/trigger-cases.jsonl` — 80+ JSONL test cases validating skill trigger routing (positive/negative, ja/en, tier overrides).
