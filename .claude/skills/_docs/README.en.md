# spec-coexist Skill Package — Usage Guide

> A Claude Code skill suite that keeps specs and implementation always in sync (coexist).

## Table of Contents

- [Quick Start](#quick-start)
- [Workflow Overview](#workflow-overview)
- [Task Tier System](#task-tier-system)
- [Skills Reference](#skills-reference)
- [Subsystem Development](#subsystem-development)
- [Visual Companion](#visual-companion)
- [Tips](#tips)

---

## Quick Start

### 1. Installation

**As a development repository:**

Clone this repo — skills under `.claude/skills/` are automatically recognized.

**As a plugin for another project:**

```bash
# Build the package
./scripts/package-spec-coexist.sh

# Extract the generated dist/spec-coexist-<version>.tar.gz
# and place it in Claude Code's plugin directory
```

### 2. First Steps

Just talk to Claude Code naturally.

```
"I want to draft requirements for a new project"
→ creating-requirements activates

"Requirements are ready, let's write the basic design"
→ creating-basic-design activates

"Implement according to this design"
→ implementing-from-spec activates
```

The **spec-coexist-router** automatically classifies your message by task size and invokes the appropriate skill.

---

## Workflow Overview

spec-coexist covers the following development lifecycle:

```
Problem     →  Requirements  →  Basic Design  →  Implementation  →  Review  →  Ship
Exploration        Definition                                                    
   │                 │               │                │               │          │
   ▼                 ▼               ▼                ▼               ▼          ▼
exploring        creating        creating          impl.           code      finishing
-problem         -require        -basic            -from           -review   -subsystem
 -space           -ments         -design           -spec           -loop     -work
```

### When specs change

```
Spec change → revising (spec mode) → revising (implementation mode)
```

### When bugs appear

```
Bug found → systematic-debugging → (if needed) revising
```

---

## Task Tier System

Every user message is classified by the **spec-coexist-router** into one of four tiers. Each tier requires a different level of process.

| Tier | Size | Examples | Required Process |
| --- | --- | --- | --- |
| **T0** | trivial | Typo fix, variable rename (≤10 lines) | Direct edit only |
| **T1** | small | Single function addition, simple bug fix | TDD + verification |
| **T2** | medium | Feature addition, multi-file changes | Requirements + design + TDD + review |
| **T3** | large | New subsystem, large-scale refactor | Full spec process + subsystem split |

You can explicitly specify a tier:

```
"tier:T0 fix this typo"
"tier:T1 add this function"
```

---

## Skills Reference

### Problem Exploration Phase

#### exploring-problem-space

Helps structure unformed ideas and identify the real problem to solve before requirements begin.

**Trigger examples:**
- "I'm not sure what we should build"
- "help me figure out the real problem"
- "brainstorm the problem"

**Output:** A problem definition and a handoff point to creating-requirements.

---

### Spec Creation Phase

#### creating-requirements

Creates a new requirements document — whole-system (`docs/main-requirements.md`) or per subsystem.

**Trigger examples:**
- "draft requirements"
- "new requirements doc"
- "I want to define requirements"

**Guardrail:** Halts if a requirements document already exists; redirects to the revising skill.

#### creating-basic-design

Creates a new basic design document. Halts if the corresponding requirements document does not exist.

**Trigger examples:**
- "draft a basic design"
- "write the design document"
- "create a basic design for this subsystem"

**Prerequisite:** A corresponding requirements document must exist.

---

### Implementation Phase

#### implementing-from-spec

Implements code based on requirements + basic design. Internally invokes test-driven-implementation for TDD.

**Trigger examples:**
- "implement from the spec"
- "build it from the basic design"
- "implement this design"

**Iron Law:** No production code is written unless a failing test exists first.

#### fast-path

Dedicated to T0/T1 lightweight tasks. No spec documents required — takes the shortest path to completion.

**Trigger examples:**
- "tier:T0 fix this typo"
- "tier:T1 add this function"
- "quick fix"
- "small change"

---

### Spec Revision Phase

#### revising

Handles revision of requirements/design documents AND implementation updates after spec changes.

**Trigger examples (spec revision):**
- "revise the spec"
- "update the requirements"
- "change the design"

**Trigger examples (implementation update):**
- "update the code to match the new spec"
- "reflect the spec change in the implementation"

---

### Debugging

#### systematic-debugging

Hypothesis-driven debugging. Collects evidence and validates hypotheses before proposing any fix.

**Trigger examples:**
- "this is broken"
- "test is failing"
- "the output is wrong"
- "something's not working"

**Process:** Observe → Generate hypotheses → Experiment → Identify root cause → Fix

---

### Quality Assurance

#### pre-review-self-check

Pre-review self-check for naming, complexity, boundaries, and error handling.  
*Typically invoked automatically by other skills.*

#### verification-before-completion

A hard gate that requires fresh verification evidence (test runs, build checks) before any completion claim.  
*Typically invoked automatically by other skills.*

#### code-review-loop

Handles the full review cycle: request review, receive feedback, verify fixes.

**Trigger examples:**
- "review this change"
- "here is the review feedback"
- "before I merge"

---

### Completion & Integration

#### finishing-subsystem-work

Integrates verified and reviewed work — commit, push, and merge.

**Trigger examples:**
- "ready to merge"
- "open a pull request"
- "wrap up this branch"

#### delivery-snapshot

Generates a point-in-time project status report: completed requirements, in-progress work, uncovered REQ-IDs, and dependency graphs.

**Trigger examples:**
- "generate a delivery snapshot"
- "project status report"
- "what's the current state of requirements"

---

### Parallel Development

#### parallelizing-subsystem-work

Implements multiple subsystems concurrently using git worktrees.

**Trigger examples:**
- "implement these in parallel worktrees"
- "parallelize these subsystems"
- "work on these subsystems simultaneously"

**Prerequisite:** 2+ subsystems must each have completed requirements + basic design.

---

## Subsystem Development

For larger projects, functionality can be split into subsystems.

### Directory Structure

```
docs/
├── main-requirements.md           ← Whole-system requirements
├── main-basic-design.md           ← Whole-system basic design
└── subsystems/
    ├── 01_auth/
    │   ├── auth-requirements.md
    │   └── auth-design.md
    ├── 02_api/
    │   ├── api-requirements.md
    │   └── api-design.md
    └── ...
```

### Subsystem Development Flow

1. Identify features in the whole-system requirements
2. Create requirements and basic design per subsystem
3. Use `parallelizing-subsystem-work` for parallel implementation
4. Use `finishing-subsystem-work` to integrate

---

## Visual Companion

A lightweight HTTP server for visually guiding requirements and design discussions. Provides real-time Mermaid diagram previews, among other features.

**Starting:**

Automatically launched during skill execution. To start manually:

```bash
python3 .claude/skills/_shared/scripts/visual_server.py
```

**Requires:** Python 3.10+ (standard library only — no additional packages needed)

---

## Tips

### Let the router choose the skill

In most cases, just describe what you want in natural language. The router will pick the right skill — you don't need to memorize skill names.

### Use tier labels for efficiency

Tag small tasks with `tier:T0` or `tier:T1` to skip unnecessary process and finish quickly.

### Keep specs and implementation in sync

The core principle of spec-coexist is that specs and implementation are always synchronized. Even when you want to change only the code, the recommended flow is: update the spec first, then reflect the change in the implementation.

### Trust the guardrails

Each skill has built-in safety mechanisms:
- Prevents overwriting existing documents
- Prevents creating a design without requirements
- Prevents writing production code without tests
- Prevents claiming completion without verification

These HALTs are intentional. Follow their guidance rather than working around them.
