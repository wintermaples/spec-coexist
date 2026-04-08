# Negative Triggers

The 1% rule prevents *skipping* a relevant skill. This document prevents the opposite failure: a `spec-coexist` skill firing on an unrelated message, wasting context and polluting output. If a user message matches **any** case below AND has no other spec-driven signal, the agent **MUST NOT** invoke a `spec-coexist` skill and **MUST** respond normally.

The list is capped at **20 entries**. Growing past that cap is a signal that the 1% rule itself — not this exclusion list — needs rethinking.

## Excluded categories

1. **Environment / setup troubleshooting** — "node が起動しない", "pip install が失敗する", "docker daemon not running". Tooling, not spec work.
2. **CLI / library usage questions** — "git rebase の使い方", "how do I use `jq` to filter this", "what does `ruff --fix` do?". Reference lookup.
3. **Read-only documentation browsing** — "README を見せて", "show me the contents of `docs/main-requirements.md`". No mutation intent.
4. **Git log / history summaries** — "直近のコミットを要約して", "what changed in the last 5 commits". Historical query.
5. **Pure Q&A about general concepts** — "TDD って何?", "what is a monad?". Educational, no artifact.
6. **Small talk / meta** — "ありがとう", "thanks", "are you there?", "今日の日付は?". No task.
7. **Clipboard / formatting help** — "このテキストを markdown 表にして", "convert this JSON to YAML". Format transform.
8. **Math or data one-shots** — "この配列の中央値は?", "compute the sha256 of this string". Pure computation.
9. **Editor / IDE configuration** — "VS Code の設定", "how do I bind this shortcut". Local tooling.
10. **CI log reading without fix request** — "この CI ログ何が落ちてるか教えて" **without** "直して". Diagnostic read, not a bug fix engagement.
11. **Personal notes / scratchpad** — "ちょっとメモさせて", "jot this down". User is thinking aloud.
12. **Language translation** — "この英語を日本語に訳して". Pure translation.
13. **External URL fetch requests** — "この URL の内容を取ってきて". Web fetch, no repo mutation.
14. **Permissions / access / auth issues with external services** — "gh auth login が通らない". Account state.
15. **Questions about Claude itself** — "Claude の context window は?", "which model are you?". Meta.

Slots 16–20 are reserved. New entries **MUST** be appended with a 1-line rationale, and any addition **MUST** ship with a negative trigger test case in `_shared/tests/trigger-cases.jsonl`.

## How the check is applied

1. Read the user message.
2. If it matches any excluded category above AND contains **no** spec, design, implementation, bug, review, merge, or skill-authoring signal — do **not** invoke a skill.
3. Otherwise, fall through to the 1% rule.

The negative list is **subordinate** to the 1% rule: if both fire (e.g. "README を見せて、ついでに要件も更新したい"), the 1% rule wins.

## Why the cap matters

An unbounded negative list inverts the suite's philosophy — it becomes "only fire when allowed" instead of "fire unless clearly excluded". The cap preserves the default-on posture that makes the 1% rule effective.
