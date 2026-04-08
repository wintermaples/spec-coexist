# One Question Per Message

During steps 1–2 of `exploring-problem-space`, the agent **MUST** ask at most one question per message.

## Why

Divergent phases fail when the agent front-loads a questionnaire. Users answer the first question, skip the rest, and the agent either re-asks (annoying) or assumes (dangerous). Constraining to one question forces the agent to pick the highest-information question at each turn and keeps the conversation tractable.

## Rules

- **MUST** ask exactly one question per assistant turn, or zero if no new question is warranted.
- **MUST NOT** batch questions with "also" / "and another thing" / bullet lists of questions.
- The question **SHOULD** be answerable in one or two sentences.
- If multiple questions are equally important, pick the one whose answer **most constrains the hypothesis space**, and defer the rest.
- Once the agent moves past step 2 (hypothesis generation), this rule relaxes — hypothesis review can present all hypotheses at once.

## Exceptions

None inside this skill. The constraint is stricter than elsewhere in the suite because divergence is the most fragile phase.
