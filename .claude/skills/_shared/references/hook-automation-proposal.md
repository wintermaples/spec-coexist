# Hook Automation Proposal (W5) / フック自動化提案

**Status:** PROPOSAL ONLY — **REQUIRES USER APPROVAL BEFORE ENABLEMENT**
**Scope:** `.claude/settings.json` hook integration for the spec-coexist skill suite
**Plan reference:** `spec-coexist-improvement-plan.md` §4, §5 Phase 5
**Date:** 2026-04-09

> This document is a design proposal. It **MUST NOT** be interpreted as an
> active configuration. No hook described here is to be added to
> `.claude/settings.json` until the user explicitly approves, in writing, the
> staged rollout in section 5.

---

## 1. Goal & Rationale / 目的と背景

### EN
The spec-coexist suite currently relies on human goodwill to honor RFC 2119
constraints (TDD, evidence, verification-before-completion). Comparison
report weakness **W5** identifies the lack of harness-level enforcement: a
well-intentioned agent can still skip the RED phase, fabricate a "done"
claim, or commit without evidence. Hooks close that gap by letting the
Claude Code harness — not the model — run discipline checks at
deterministic lifecycle points.

### JA
現在の spec-coexist は RFC 2119 の規律 (TDD、evidence、完了前検証) の遵守を
人間の善意に依存している。比較レポートの弱点 **W5** が指摘するとおり、
ハーネスレベルの強制力が無いためエージェントは RED フェーズを飛ばしたり、
証拠無しで完了宣言したり、evidence 無しで commit することが可能である。
フックは Claude Code ハーネス (モデルではなく) がライフサイクルの確定的な
タイミングで規律チェックを走らせる仕組みを提供し、この欠落を埋める。

### Non-goals
- Hooks **MUST NOT** replace skill-level RFC 2119 text; they complement it.
- Hooks **MUST NOT** block exploratory/legacy work excluded by
  `test-driven-implementation/references/negative-triggers.md` (once Phase 1
  lands). A hook that cannot distinguish excluded paths **MUST** default to
  warn-only.

---

## 2. Proposed Hooks / 提案するフック

Three hooks are proposed, mirroring plan §4. All command snippets assume the
canonical repo layout (`.claude/skills/_shared/scripts/`).

### 2.1 PostToolUse — verify test-first on code edits

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write|MultiEdit",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/skills/_shared/scripts/verify_test_first.sh --mode=warn --path \"$CLAUDE_TOOL_FILE_PATH\""
          }
        ]
      }
    ]
  }
}
```

**Effect:** after every `Edit`/`Write`/`MultiEdit` that touches a source
file, `verify_test_first.sh` walks `git log` to confirm a failing test was
recorded (via `record_test_failure.sh` / evidence) **before** the production
change. In `--mode=warn` it prints a non-blocking reminder; in
`--mode=enforce` it exits non-zero, which the harness surfaces as a tool
failure.

**File-type filter:** the script itself **SHOULD** filter by extension
(`.py`, `.ts`, `.tsx`, `.js`, `.jsx`, `.rs`, `.go`, `.java`, `.kt`, `.rb`,
`.cs`) and **MUST** skip docs (`*.md`), config (`*.json`, `*.yml`,
`*.yaml`, `*.toml`), and lockfiles. Hook-level matchers are not
expressive enough for this — keep the logic in the script.

### 2.2 Stop — gate checklist before completion claim

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/skills/_shared/scripts/run_gate_checklist.sh --mode=warn"
          }
        ]
      }
    ]
  }
}
```

**Effect:** when the agent is about to stop, `run_gate_checklist.sh`
verifies that a verification-before-completion evidence record exists for
the current session. If absent, the script emits a reminder. This directly
reinforces the `verification-before-completion` skill without changing
skill text.

**Note:** `run_gate_checklist.sh` does not yet exist in the repo. Enabling
this hook **MUST** be gated on its landing in a separate PR.

### 2.3 PreToolUse — block commits without evidence

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/skills/_shared/scripts/check_commit_has_evidence.sh --mode=warn --command \"$CLAUDE_TOOL_COMMAND\""
          }
        ]
      }
    ]
  }
}
```

**Effect:** intercepts `Bash` tool calls; the script inspects
`$CLAUDE_TOOL_COMMAND` and only acts if the command contains `git commit`.
When triggered, it confirms that an evidence record exists for the staged
changes. This prevents "silent" commits that bypass the evidence ledger.

**Note:** `check_commit_has_evidence.sh` does not yet exist. Same PR-gating
caveat as 2.2.

---

## 3. Reliability Concerns & False-Positive Mitigation / 信頼性と誤検出対策

### 3.1 `verify_test_first.sh` specific risks

| Risk | Mitigation |
|---|---|
| Test and production code in a single commit | Allow: test file and production file in the same commit counts as test-first. Document in script header. |
| Monorepo cross-package edits | Resolve the nearest package root and scope the git log walk to that root. |
| Excluded paths (legacy, spikes, notebooks, infra) | Consult `test-driven-implementation/references/negative-triggers.md` at runtime; fall back to warn-only if the reference file is absent (Phase 1 may not be merged). |
| Renames / moves | Use `git log --follow` for file-level history. |
| First commit in a repo | Short-circuit to OK when no prior history exists. |
| Generated code (protobuf, codegen, migrations) | Honor a `.tdd-ignore` glob file at repo root. |
| Hook invoked during rebase / cherry-pick | Detect `.git/REBASE_HEAD`, `.git/CHERRY_PICK_HEAD`; skip checks. |
| Performance on large repos | Cap `git log` walk depth (e.g. 200 commits) and cache per-session results. |

### 3.2 General hook reliability requirements (RFC 2119)

- Every hook script **MUST** support a `--mode={warn,enforce}` flag.
- In `warn` mode, scripts **MUST** exit 0 regardless of findings and emit
  guidance to stderr.
- In `enforce` mode, scripts **MUST** exit non-zero **only** on
  high-confidence violations.
- Scripts **MUST NOT** depend on network access.
- Scripts **SHOULD** complete in under 2 seconds on a typical repo.
- Scripts **SHOULD** log every decision (allow / warn / block) to
  `.claude/hook-log.jsonl` for auditability.
- Scripts **MUST** fail open on internal error (exit 0 with a stderr note)
  rather than blocking the agent on a script bug.

---

## 4. Dependencies on Other Phases

| Hook | Depends on | Phase |
|---|---|---|
| 2.1 PostToolUse | `verify_test_first.sh`, `negative-triggers.md` | Phase 1 (W1) |
| 2.2 Stop | `run_gate_checklist.sh` (new), evidence ledger | Phase 1 + new script PR |
| 2.3 PreToolUse | `check_commit_has_evidence.sh` (new) | new script PR |

This proposal is intentionally written so it does **not** depend on Phase 1
being merged at authoring time. Enablement, however, does.

---

## 5. Staged Rollout / 段階的ロールアウト

Each stage **MUST** complete before the next begins. Each stage **MUST**
obtain explicit user approval.

### Stage 0 — Proposal (this document)
- Review and accept the design.
- No `.claude/settings.json` change.

### Stage 1 — Dry-run (warn-only, opt-in)
- User manually pastes the `warn`-mode snippets into their local
  `.claude/settings.json`.
- Collect 1–2 weeks of `.claude/hook-log.jsonl` data.
- Tune false-positive rate to < 5% of edits on representative repos.

### Stage 2 — Warn-only, committed
- Commit the warn-mode snippets into the repo's `.claude/settings.json`.
- All users see reminders; no one is blocked.
- Continue monitoring for at least one release cycle.

### Stage 3 — Enforce on 2.1 only
- Flip `verify_test_first.sh` to `--mode=enforce`.
- Keep 2.2 and 2.3 in warn mode.
- Provide a documented escape hatch (`SKIP_TDD_HOOK=1` env var, logged).

### Stage 4 — Enforce on 2.2 and 2.3
- Only after Stage 3 has run for a full release cycle with zero
  false-positive incidents.

At any stage a rollback **MUST** be possible by reverting a single commit
to `.claude/settings.json`.

---

## 6. Approval Checklist / 承認チェックリスト

Before any stage beyond Stage 0 is enacted, the user **MUST** confirm:

- [ ] I have read sections 1–5 of this proposal.
- [ ] I accept the false-positive trade-off at the proposed stage.
- [ ] I understand how to disable the hooks (revert the settings commit).
- [ ] I accept that enforcement stages may block my own tool calls.
- [ ] I have verified that `verify_test_first.sh` (and any other referenced
      script) exists in this repo at the version I intend to enable.

---

## 7. Explicit Notice / 明示的な注意

> **REQUIRES USER APPROVAL BEFORE ENABLEMENT.**
> **有効化にはユーザの承認が必須。**
>
> Nothing in this document authorizes an agent, a skill, or a maintainer to
> modify `.claude/settings.json` on the user's behalf. Any such modification
> without prior explicit approval is a violation of the spec-coexist
> discipline this proposal is meant to strengthen.
