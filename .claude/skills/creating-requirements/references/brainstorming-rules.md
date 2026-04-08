# Brainstorming Rules — creating-requirements

This skill embeds its own brainstorming flow. It **MUST NOT** delegate to `superpowers:brainstorming` or any other external brainstorming skill.

## Core rules

1. Ask exactly **one question per message**.
2. Questions **SHOULD** be multiple-choice. Open-ended questions **MAY** be used when needed.
3. Adapt each question to the previous answer — do not follow a rigid pre-written script.
4. Base your questions on what the target template actually requires (read the template + rules files before starting so you know what gaps need filling).

**Rationale for one question per message:** users answer better when they aren't drowning in a wall of bullet points, and the agent can adapt the next question to the previous answer in real time.

## Question-file threshold

When the number of **pending** questions reaches approximately 5 or more:

1. Generate a question file path: `.claude/skills/_shared/scripts/gen_questions_path.sh requirements`
2. Write all pending questions to that file.
3. **Halt brainstorming** and tell the user: "I've written the remaining questions to `<path>`. Please answer them and let me know when you're done."
4. Resume only after the user explicitly confirms the questions have been answered.

When pending questions are few (fewer than ~5), continue inline dialogue without writing a file.

## Visual Companion gate

If upcoming questions are fundamentally visual (UI mockups, layout choices, screen flows, architecture diagrams), the agent **MAY** launch the **Visual Companion** (see `../_shared/references/visual-companion.md`).

Rules:
- Request consent exactly once, in its own standalone message — no other questions in the same message.
- Example consent request: "I'd like to switch into Visual Companion mode for the next few questions because they're about screen layout. Is that okay? (yes / no)"
- If the user declines, continue in plain terminal mode.
- A question *about* a UI topic is not automatically visual. "What kind of dashboard do you want?" is conceptual; "Which of these dashboard layouts feels right?" is visual.

## Checklist: is brainstorming complete?

Before moving to Step 6 (write the document), confirm:

- [ ] Every required template section has enough information to write a non-placeholder entry.
- [ ] All MoSCoW priorities have been assigned to functional requirements (subsystem only).
- [ ] Non-functional requirements have numeric targets (not vague words like "fast" or "reliable").
- [ ] Stakeholders are identified with names or roles.
- [ ] KPI/KGI targets have current values, target values, and measurement methods.
- [ ] Scope-out items are explicitly listed.
- [ ] No critical business rules are still ambiguous.
