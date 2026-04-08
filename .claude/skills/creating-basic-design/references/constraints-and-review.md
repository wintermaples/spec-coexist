# Hard Constraints and Review Protocol

## Conformance Keywords

The key words **MUST**, **MUST NOT**, **REQUIRED**, **SHALL**, **SHALL NOT**, **SHOULD**, **SHOULD NOT**, **RECOMMENDED**, **MAY**, and **OPTIONAL** in this document are to be interpreted as described in [RFC 2119](https://www.rfc-editor.org/rfc/rfc2119) and [RFC 8174](https://www.rfc-editor.org/rfc/rfc8174) when, and only when, they appear in all capitals.

## Independence

This skill **MUST NOT** invoke or delegate to any `superpowers:*` skill. It **MUST** invoke the project-local skills `requesting-code-review` and `receiving-code-review`.

## Hard Constraints

- This skill **MUST NOT** update an existing basic design document. If the target file already exists, the skill **MUST** halt and direct the user to `spec-coexist:revising-spec`.
- If `docs/main-requirements.md` does not exist, the skill **MUST** halt immediately. A basic design without requirements is meaningless.

## Verification Gate

After the basic design document is written, the agent **MUST** pass through `verification-before-completion` (document mode) before invoking review or reporting completion. This means:

- Re-read the file from disk.
- Confirm every template section is present.
- Confirm every requirement is traceable.
- Confirm no `TBD` / `TODO` / `???` placeholders remain.
- Confirm no empty bullets.

Fix any failures and re-run the gate until it passes cleanly.

## Mandatory Design Review

Although the artifact is a document rather than executable code, the same review discipline applies: a fresh reviewer catches template-compliance gaps, vague requirements traceability, missing sections, and internal inconsistencies invisible to the author.

### Step 1 — Invoke `requesting-code-review`

After writing the document (and, if the draft is unstaged, committing it so `BASE_SHA` / `HEAD_SHA` are meaningful), invoke `requesting-code-review` with:

| Parameter | Value |
| --- | --- |
| `WHAT_WAS_IMPLEMENTED` | `"Newly created basic design document at <path>"` |
| `PLAN_OR_REQUIREMENTS` | Pointer to `docs/main-requirements.md` (or the subsystem requirements) **and** to the template + rules files in `references/` |
| `BASE_SHA` | Commit immediately before the doc was added |
| `HEAD_SHA` | Commit containing the new doc |
| `DESCRIPTION` | 1–3 sentences on what the design covers |

Instruct the reviewer to specifically check:
- Template and rules compliance
- Traceability to every requirement
- Internal consistency
- Unresolved `TBD`s
- Any scope that exceeds the requirements

### Step 2 — Handle feedback

The agent **MUST** handle the returned feedback through `receiving-code-review`.

### Step 3 — Fix policy

| Severity | Required action |
| --- | --- |
| **Critical** (missing sections, contradicts requirements, violates template rules) | **MUST** be fixed before reporting completion |
| **Important** | **MUST** be fixed unless the user explicitly waives them |
| **Minor** | **MAY** be deferred but **MUST** be listed in the final report |

### Step 4 — Re-review after fixes

After fixes, the agent **SHOULD** re-dispatch the reviewer on the new `HEAD_SHA`.

### Step 5 — Final report

The final report to the user **MUST** include a `Review:` line summarizing the outcome.
