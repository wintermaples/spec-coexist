# Brainstorming Rules for Detailed Design

These rules apply during the brainstorming phase of `creating-detail-design`.

## Module-by-Module Processing

Process one module at a time, completing its design before moving to the next. This keeps conversations focused and prevents context overload.

Order of processing:

1. Modules with **no dependencies** on other modules.
2. Modules that **depend on** already-designed modules.
3. **Integration / orchestration** modules last.

## One Question Per Message

Ask exactly one question per message. Never bundle multiple questions.

## Question Format

- **Prefer multiple-choice** options (A / B / C) — they lower the user's cognitive load and produce unambiguous answers.
- **Open-ended questions MAY be used** when the answer space is genuinely open (e.g. "What happens when the payment gateway times out?").
- **Accompany questions with draft Mermaid diagrams** when the question concerns behavior or flow. Show the user what you assume and ask them to confirm or correct.

## Diagram-Driven Dialogue

When discussing behavior, follow this loop — it is faster and more precise than asking abstract questions:

1. Draw a draft Mermaid diagram based on the basic design.
2. Ask the user: "この流れで合っていますか？修正点はありますか？" / "Does this flow look correct? Any corrections?"
3. Iterate until the user confirms.

## Handling Many Pending Questions

When the number of pending questions grows large (more than ~4–5 remaining), write them all to a file:

```bash
path=$(.claude/skills/_shared/scripts/gen_questions_path.sh detail-design)
# Write all remaining questions to $path, then HALT.
```

Tell the user the file path and **HALT** until they confirm they have answered. Then resume inline.

## Visual Companion

Consult `../_shared/references/visual-companion.md` for full operating instructions.

**When to offer it:** only when the next question is fundamentally visual — architecture diagrams, data flow visualizations, complex state machines. Textual behavior questions stay in plain terminal mode.

**Consent:** request consent exactly once, in its own standalone message.

## Design Solidified?

Continue the brainstorming loop until **all** of the following are true:

- Every module identified in step 5 has its key behaviors specified via Mermaid diagrams.
- Interface contracts between modules are defined (inputs, outputs, error responses).
- Error handling paths are specified for each module.
- State transitions are documented for every stateful module.
- No open questions remain that would force an implementer to make arbitrary choices.
