---
name: receiving-code-review
user-invocable: true
description: Use whenever code-review feedback has just been received — from the code-reviewer subagent, from the user, or from an external reviewer — and before any suggested change is implemented. Trigger on phrases like "レビューが返ってきた", "here is the review feedback", "reviewer said...", or immediately after `requesting-code-review` returns. This skill enforces verification-before-implementation and MUST be used by implementing-from-spec, revising-implementation, and systematic-debugging whenever they act on review feedback.
---

# receiving-code-review

## Conformance Keywords

The key words **MUST**, **MUST NOT**, **REQUIRED**, **SHALL**, **SHALL NOT**, **SHOULD**, **SHOULD NOT**, **RECOMMENDED**, **MAY**, and **OPTIONAL** in this document are to be interpreted as described in [RFC 2119](https://www.rfc-editor.org/rfc/rfc2119) and [RFC 8174](https://www.rfc-editor.org/rfc/rfc8174) when, and only when, they appear in all capitals, as shown here.

## Independence

This skill **MUST NOT** invoke any `superpowers:*` skill. It is a self-contained behavioral discipline.

## Core Principle

Code review feedback is a **set of suggestions to evaluate**, not a **set of orders to follow**.

The agent **MUST** verify each item against the actual codebase before implementing it. Blind implementation and performative agreement are both failure modes — the first produces wrong code, the second produces the *appearance* of rigor without the substance.

## The Response Pattern

For every review the agent receives, it **MUST** follow this loop:

1. **READ** the entire feedback without reacting or pre-committing to fixes.
2. **UNDERSTAND** each item — restate it in your own words. If you cannot restate it, you do not understand it yet.
3. **VERIFY** each item against the actual codebase. Does the problem really exist? Is the suggested fix compatible with the existing architecture?
4. **EVALUATE** technical correctness *for this codebase* — not in the abstract.
5. **RESPOND** with either a technical acknowledgment (and a fix) or a reasoned pushback.
6. **IMPLEMENT** one item at a time. Test each fix individually before moving on.

## Forbidden Responses

The agent **MUST NOT** respond with any of:

- "You're absolutely right!"
- "Great point!" / "Excellent feedback!" / "Thanks for catching that!"
- Any expression of gratitude.
- "Let me implement that now" issued *before* verification.

These are performative. They cost the user trust without improving the code. Instead, the agent **MUST** either restate the technical requirement, ask a clarifying question, push back with reasoning, or just silently start fixing.

## Handling Unclear Feedback

If any item in the feedback is unclear, the agent **MUST** stop and ask for clarification **before** implementing *any* item — not just the unclear ones. Items in a review are often related; partial understanding leads to partial-but-wrong implementations.

## Source-Specific Handling

### From the `code-reviewer` subagent (via `requesting-code-review`)
- Treat as a knowledgeable-but-context-limited external reviewer.
- **MUST** verify each suggestion against the codebase before acting.
- **MAY** push back with technical reasoning if the reviewer lacks context.

### From the user directly
- Trusted. Implement after understanding, but **MUST** still ask if scope is unclear.
- **MUST NOT** produce performative agreement. Skip to action.

### From an external reviewer (human, PR comments, etc.)
- Be skeptical but careful. Before implementing, check:
  1. Is this correct for *this* codebase?
  2. Would it break existing functionality?
  3. Is there a reason the current implementation exists?
  4. Does the reviewer have full context?
- If the agent cannot verify a suggestion without more information, it **MUST** say so rather than guess.

## YAGNI Check

If a reviewer recommends "implementing this properly" (more fields, more config, more abstraction), the agent **MUST** first grep the codebase for actual usage. If the feature is unused, the correct response is often to remove it, not to expand it. Surface the tradeoff to the user rather than silently adding speculative complexity.

## Severity-Ordered Implementation

When acting on multi-item feedback, the agent **MUST** implement in this order:

1. Clarify anything unclear (stop until clarified).
2. Blocking issues (bugs, security, data loss).
3. Simple fixes (typos, imports, obvious errors).
4. Complex fixes (refactors, logic changes).

After each individual fix, the agent **MUST** run the relevant tests / type checks to confirm no regression before moving on.

## Pushback Rules

Pushback is legitimate — and sometimes required — when:

- The suggestion would break existing functionality.
- The reviewer lacks full context.
- The suggestion violates YAGNI for unused code.
- The suggestion is technically incorrect for this stack.
- Legacy / compatibility reasons justify the current approach.
- The suggestion conflicts with architectural decisions the user has already made.

How to push back correctly:

- Use technical reasoning, not defensiveness.
- Reference specific code / tests / docs.
- Ask targeted clarifying questions.
- Escalate to the user if the conflict is architectural.

If a pushback later turns out to be wrong, the agent **MUST** state the correction factually and move on — no long apology, no defending the original pushback.

## Acknowledging Correct Feedback

When feedback is correct, acknowledge with the fix itself. Examples:

- "Fixed. Added ISO date validation in search.ts:25."
- "Good catch — off-by-one in indexer.ts:130. Fixed."
- Or just: fix the code and show the diff.

No "thanks," no "great point." The code is the acknowledgment.

## Integration with Other Skills

`implementing-from-spec`, `revising-implementation`, and `systematic-debugging` **MUST** invoke this skill whenever they receive output from `requesting-code-review` or any other review source, before acting on the feedback.

## Bottom Line

Verify. Question. Then implement. Technical rigor over social comfort, always.
