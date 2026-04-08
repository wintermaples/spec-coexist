# Embedded Brainstorming Flow — revising-spec

This skill embeds its own brainstorming loop.

## Rules

1. Ask exactly **one question per message**.
2. Questions **SHOULD** be multiple-choice. Open-ended questions **MAY** be used when the answer space is genuinely open.
3. When **many** pending questions (~5 or more): generate a question file path via `scripts/gen_questions_path.sh`, write the questions, and **HALT brainstorming** until the user confirms they've answered.
4. When **few** pending questions: continue inline.
5. **UI-related questions**: the Visual Companion **MAY** be launched (see `../_shared/references/visual-companion.md`). Consent **MUST** be requested exactly once, in its own standalone message.

## Rationale

One question per message lets the user give a focused answer and the agent adapt each next question to what was just learned.
