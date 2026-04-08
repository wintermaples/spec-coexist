# Embedded Brainstorming Flow — revising-implementation

## Rules

1. Ask **one question per message** — never bundle multiple questions.
2. Prefer multiple-choice questions; open-ended questions **MAY** be used when a closed list would be artificial.
3. When there are many pending questions (more than ~4–5), write them to a file using `gen_questions_path.sh implementation-revision` and **HALT** until the user has answered.
4. When there are few pending questions, continue inline without writing a file.
5. The Visual Companion (see `../_shared/references/visual-companion.md`) **MAY** be launched once per skill invocation for UI-related questions. Consent **MUST** be requested exactly once, in a standalone message containing no other questions.

## Goal

Brainstorming ends when the revision plan is solidified: the set of files to change, the nature of each change, and how correctness will be verified are all agreed.
