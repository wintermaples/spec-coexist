# Hard Constraints and Rationale

These constraints are declared in `SKILL.md` and enforced by the conformance checklist. This file documents the reasoning so future maintainers can judge edge cases rather than cargo-culting.

## C1. SKILL.md body ≤ 80 lines

**Rule:** The body of SKILL.md — everything after the closing `---` of the frontmatter, including trailing blank lines — **MUST NOT** exceed 80 lines.

**Why:** A SKILL.md body is loaded into the conversation context the moment the skill triggers. A 300-line SKILL.md burns through budget before the agent has done any work, and the additional prose is rarely load-bearing in practice (usually rationale or examples that belong in `references/`). 80 lines is empirically enough for an orchestrator — description of intent, ordered steps, flow diagram, and pointers to references and scripts — without being so generous that it invites dumping.

**How to recover when you hit the limit:** move rationale to `references/rationale.md`, examples to `references/examples.md`, and anti-patterns to `references/anti-patterns.md`. Do not shrink by deleting steps; shrink by externalizing prose.

## C2. Bilingual trigger phrases

**Rule:** The `description` field **MUST** contain at least one Japanese trigger phrase and at least one English trigger phrase.

**Why:** This project has bilingual users. A Japanese-only description under-triggers on English prompts and vice versa. The cost of adding phrases is near zero; the cost of missing a trigger is a user manually re-invoking the skill — or worse, the agent silently bypassing the suite.

## C3. Independence clause

**Rule:** The `description` **MUST** contain, verbatim: `This skill is self-contained and MUST NOT delegate to any \`superpowers:*\` skill.`

**Why:** The suite's auditability and version stability depend on never reaching into an external plugin at runtime. Declaring this in every description serves two purposes: it reminds the agent at decision time (before the body loads), and it makes violations grep-able during review.

## C4. No regulation text longer than 3 paragraphs in the body

**Rule:** Consecutive prose in the body **MUST NOT** exceed three paragraphs before being broken by either a list, a diagram, or a link to a `references/*.md` file.

**Why:** Walls of prose in SKILL.md are a leading indicator that "this should have been a reference". The constraint forces externalization at the moment the author is tempted to inline rationale. If you find yourself wanting a fourth paragraph, stop and create `references/rationale.md`.

## C5. Scripts are not inlined

**Rule:** SKILL.md **MUST NOT** contain script source code beyond a single invocation example (the command line used to call the script). The script body lives in `<skill>/scripts/` or `.claude/skills/_shared/scripts/`.

**Why:** Inlined scripts duplicate logic (copy-paste drift between skills), consume body lines, and cannot be tested. Externalizing to `_shared/scripts/` also enables reuse across skills, which was a deliberate suite-level refactor.

## C6. References listed in the body must exist

**Rule:** Every `references/*.md` path mentioned in SKILL.md **MUST** exist as a file at the time the skill is committed.

**Why:** A dangling reference is worse than no reference — the agent follows the pointer, fails silently, and proceeds with a weaker context. The conformance checklist includes a filesystem check for this.

## C7. One skill, one purpose

**Rule:** A skill's purpose **MUST** be expressible in one English sentence. If you need "and" to express it, consider splitting.

**Why:** Multi-purpose skills defeat description-based triggering (the trigger phrases become diluted) and make the ordered steps branchy and fragile. Splitting produces two sharper skills, and the suite's orchestration layer (`spec-coexist-router`) handles the routing for free.

## Edge cases

- **Generated content** (tables of contents, auto-updated inventories): count against the 80-line limit. If a generated table is growing, that is a signal to move it to `references/` and have the body link.
- **Mermaid diagrams**: count against the 80-line limit. A flow diagram is worth the lines it costs for a non-trivial skill; for a 3-step skill, prefer a bulleted list.
- **Frontmatter**: does NOT count against the 80-line limit. But an overlong description (say, 400 words) is its own smell — see `description-rules.md`.
