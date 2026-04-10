# Skill TDD Protocol / スキル TDD プロトコル

Conformance keywords follow [RFC 2119](https://www.rfc-editor.org/rfc/rfc2119) / [RFC 8174](https://www.rfc-editor.org/rfc/rfc8174).

This document defines **RED-GREEN-REFACTOR applied to skill authoring itself**. It connects to `trigger-tests.md` (which defines the *format* of trigger cases) by prescribing *when* and *how* those cases MUST be exercised during authoring.

このドキュメントは「スキルを書くこと」そのものに対する RED-GREEN-REFACTOR を定義する。`trigger-tests.md` が trigger ケースの **形式** を定めるのに対し、本プロトコルはそれを authoring サイクルのどこで **いつ** 実行するかを定める。

## Why / なぜ

A skill that was never observed to *fail* on a pressure scenario has never been proven to *succeed*. Without a RED baseline, a GREEN skill is indistinguishable from a skill that happens to match today's mood of the model. We therefore require an adversarial baseline **before** SKILL.md exists.

圧力シナリオで一度も **失敗** していないスキルは、一度も **成功** していない。RED ベースラインなしの GREEN は、たまたま通っただけのスキルと区別できない。ゆえに SKILL.md を書く前に敵対的ベースラインを必須とする。

## The Three Phases / 3 フェーズ

### RED — Baseline failure / ベースライン失敗

Before a single line of the new SKILL.md is written:

1. Author **MUST** write >= 3 positive and >= 1 negative trigger cases into `_shared/tests/trigger-cases.jsonl` per `trigger-tests.md`.
2. Author **MUST** dispatch a fresh general-purpose subagent (see `pressure-scenarios.md`) with each positive prompt, *without* the new skill existing on disk.
3. Author **MUST** record the observed failure mode: missing-trigger (no skill fires), wrong-trigger (an adjacent skill fires), or *correct* behaviour without the new skill (in which case the skill is **NOT NEEDED** and authoring **MUST** stop).
4. The failure log **MUST** be captured (paste into the authoring evidence note or commit message). A skill authored without a captured RED log is non-conforming.

SKILL.md を一行でも書く前に:

1. `_shared/tests/trigger-cases.jsonl` に positive >= 3, negative >= 1 の trigger ケースを **書かなければならない (MUST)**。
2. 新しい general-purpose subagent に各 positive プロンプトを投げ、新スキルが **存在しない状態** で観測しなければならない (MUST)。
3. 観測された失敗モード (missing-trigger / wrong-trigger / そもそも新スキル不要) を記録しなければならない (MUST)。新スキル不要と判明した場合は authoring を **中止しなければならない (MUST)**。
4. 失敗ログはコミットメッセージまたは evidence ノートに残さなければならない (MUST)。

### GREEN — Minimal skill that passes / 最小実装

1. Author writes the SKILL.md using `skill-template.md`, **just large enough** to flip every RED case to pass.
2. Author re-dispatches the same pressure prompts via `pressure-scenarios.md`. All positive cases **MUST** now trigger the new skill; all negative cases **MUST NOT**.
3. If any case still fails, the author **MUST NOT** loosen the trigger-cases.jsonl expectations — they **MUST** instead fix the `description`, trigger phrases, or hard constraints.
4. Padding the description with unrelated keywords to force a trigger is **FORBIDDEN** — that is over-fitting and will rot adjacent skills.

全 RED ケースを通過させる **最小限** の SKILL.md を書く。失敗したらテスト側を緩めず、`description` / トリガ句 / ハード制約を直す。無関係キーワードでの水増しは **禁止** する。

### REFACTOR — Thin orchestrator / 薄いオーケストレータ化

Once GREEN:

1. Author **MUST** move every piece of regulation text exceeding 3 consecutive paragraphs out of SKILL.md into `references/`, per `hard-constraints.md`.
2. Author **MUST** re-run the pressure prompts once more — refactoring that silently broke triggers is the #1 regression source.
3. Author **MUST** tighten negative triggers: add one new negative case that *would* have false-positived before the refactor, if any such gap exists.
4. Author **MUST** walk `conformance-checklist.md` end-to-end. Any unchecked item forces re-entry to GREEN.

GREEN 到達後、regulation を `references/` に外出しし、再度圧力プロンプトを流し、negative ケースを増やし、最後に `conformance-checklist.md` を全件確認する。リファクタによる黙示的トリガ破壊は最頻の regression なので再測定は必須。

## Connection to existing trigger-tests.md / 既存 trigger-tests.md との接続

`trigger-tests.md` describes the **schema** of `_shared/tests/trigger-cases.jsonl`. This protocol describes the **lifecycle**: when cases are added (RED, before SKILL.md exists), when they are run (RED, GREEN, REFACTOR — three times minimum), and what counts as evidence of passage (fresh-subagent observation, not self-dispatch from the authoring session).

`trigger-tests.md` はフォーマット、本プロトコルはライフサイクルを定める。RED / GREEN / REFACTOR の **3 回以上** 実行すること、かつ「新しい subagent による観測」のみを合格証拠とすることが要点である。authoring セッション自身によるセルフ判定は証拠にならない。

## RFC 2119 Summary / 要約

- Author **MUST** produce a RED baseline before writing SKILL.md.
- Author **MUST** re-measure after GREEN and after REFACTOR.
- Author **MUST NOT** weaken `trigger-cases.jsonl` to make a case pass.
- Author **MUST NOT** pad `description` with unrelated keywords.
- Author **SHOULD** capture each subagent dispatch in the authoring commit message or evidence note.
- If RED shows the new skill is unnecessary, authoring **MUST** stop.
