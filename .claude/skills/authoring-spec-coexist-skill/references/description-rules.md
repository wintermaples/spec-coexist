# Description Field Rules

The `description` field in the frontmatter is the **only** signal the harness uses to auto-trigger a skill. Getting it wrong causes two failure modes: under-triggering (skill never runs when it should) and over-triggering (skill runs on unrelated conversation, wasting tokens and polluting output). The spec-coexist suite leans slightly toward over-triggering via the 1% rule, but that only works if each description is *specific enough* to distinguish its own territory.

## Required elements

A conformant `description` **MUST** contain, in this order:

1. **Lead clause** — starts with `Use whenever ...` or `Use at the start of ...`. States the primary trigger condition in English, using concrete nouns (not "stuff" or "things").
2. **Trigger phrases** — a `Trigger on phrases like "..."` sentence containing **at least one Japanese phrase and at least one English phrase**. Three to six phrases total is a good target. Pick phrases a real user would type, not abstract descriptions.
3. **Negative cues (SHOULD)** — a `Do NOT trigger for ...` or `This skill MUST NOT ...` clause that names the adjacent territory the skill should NOT claim. This is the single biggest lever against over-triggering.
4. **Scope / hard constraint (SHOULD)** — if the skill has a defining constraint (e.g. "only creates new documents, never updates existing ones"), state it here. It both helps triggering and pre-commits the agent to the right behavior.
5. **Independence clause (MUST)** — the sentence `This skill is self-contained and MUST NOT delegate to any \`superpowers:*\` skill.` verbatim. Non-negotiable; the suite's independence guarantee depends on every skill carrying this line.

## Length

Target 80–180 words. Shorter descriptions under-trigger (the harness has too little signal). Longer descriptions waste always-in-context budget and tend to contradict themselves.

## Phrase selection

Good trigger phrases are:

- **Natural** — what a user actually types, in the register they actually use ("これバグってる", not "I encountered an anomalous behavior").
- **Diverse in register** — mix polite and casual, English and Japanese, typed and spoken-style.
- **Concrete** — "基本設計を作る" beats "something about design".
- **Distinct from neighbors** — if two skills share a phrase, at least one of them is mis-scoped.

## Anti-patterns

- **Keyword soup**: `Trigger on phrases like "requirements", "design", "spec", "implementation", "bug", "fix"` — too generic, fires on everything.
- **Marketing copy**: `The best skill for ...` — the harness does not care; the tokens are wasted.
- **Hidden rules**: putting "MUST do X" in the description only. The description is read by the harness for matching; the body is read by the agent for execution. Rules that matter for execution **MUST** appear in the body or `references/`.
- **Missing independence clause**: silently lets the agent fall back on `superpowers:*` under load, breaking the suite's guarantee.
- **No negative cues**: the description only says "when to fire", never "when not to". The 1% rule then fires everywhere.

## Minimal example

```
description: Use whenever the user wants to CREATE a new requirements document — whole-system (`docs/main-requirements.md`) or subsystem. Trigger on phrases like "要件定義を作る", "新しい要件", "draft requirements", "new requirements doc". Do NOT trigger for updates to existing requirements — use `spec-coexist:revising-spec` instead. This skill MUST halt if the target file already exists. This skill is self-contained and MUST NOT delegate to any `superpowers:*` skill.
```
