# Brainstorming Rules

These rules apply during the embedded brainstorming phase of `creating-basic-design`.

## One Question Per Message

Ask exactly one question per message. Never bundle multiple questions.

## Question Format

- **Prefer multiple-choice** options (A / B / C) — they lower the user's cognitive load and produce unambiguous answers.
- **Open-ended questions MAY be used** when the answer space is genuinely open (e.g. "What is the core user goal?").

## Handling Many Pending Questions

When the number of pending questions grows large (more than ~4–5 remaining), write them all to a file instead of asking them one at a time:

```bash
path=$(.claude/skills/_shared/scripts/gen_questions_path.sh basic-design)
# Write all remaining questions to $path, then HALT.
```

Tell the user the file path and **HALT** until they confirm they have answered. Then resume inline.

When only a few questions remain, continue inline without writing a file.

## Visual Companion

Consult `../_shared/references/visual-companion.md` for full operating instructions.

**When to offer it:** only when the next question is fundamentally visual — UI layout, wireframes, architecture diagrams, screen flows. Conceptual questions (scope, wording, API tradeoffs) stay in plain terminal mode.

**Consent:** request consent exactly once, in its own standalone message with no other questions:

> I'd like to switch into Visual Companion mode for the next few questions because they're about screen layout. Is that okay? (yes / no)

If the user declines, continue in plain terminal mode for the rest of the session.

**Launch command:**
```bash
.claude/skills/_shared/scripts/start_visual_server.sh <project-dir>
```

Capture and remember `screen_dir`, `state_dir`, `url`, and `pid` from the output.

## Design Solidified?

Continue the brainstorming loop until all of the following are true:

- The target scope (whole-system vs subsystem) is confirmed.
- Every requirement in `docs/main-requirements.md` (or subsystem requirements) has at least a placeholder design decision.
- No open questions remain that would block writing the document.
- Non-functional requirements (performance, security, availability) have at least high-level answers.
