# Hard Constraints and Review Protocol

## Conformance Keywords

The key words **MUST**, **MUST NOT**, **REQUIRED**, **SHALL**, **SHALL NOT**, **SHOULD**, **SHOULD NOT**, **RECOMMENDED**, **MAY**, and **OPTIONAL** in this document are to be interpreted as described in [RFC 2119](https://www.rfc-editor.org/rfc/rfc2119) and [RFC 8174](https://www.rfc-editor.org/rfc/rfc8174) when, and only when, they appear in all capitals.

## Independence

This skill **MUST NOT** invoke or delegate to any `superpowers:*` skill. It **MUST** invoke the project-local `code-review-loop` skill.

## Hard Constraints

- This skill **MUST NOT** update an existing detailed design document. If the target `detail-design/index.md` already exists, the skill **MUST** halt and direct the user to `spec-coexist:revising`.
- If the corresponding basic design document does not exist, the skill **MUST** halt immediately. A detailed design without a basic design is meaningless.
  - Whole-system: `docs/main-basic-design.md` must exist.
  - Subsystem: `docs/subsystems/{id}_{name}/{name}-design.md` must exist.
- For nested subsystems, the parent subsystem's basic design document **MUST** also exist before creating a child subsystem's detailed design.
- The detailed design text **MUST** apply the 7 readability elements (grammatical readability / reader fit / clarity & conciseness / referentiality / consistency / structure / use of diagrams and formal language) defined in `../../_shared/references/document-readability.md`. The verification gate and the reviewer re-check the same elements. Scope is content only; visual typography is out of scope.

## Notation Constraint — Mermaid First

- **Mermaid diagrams** are the primary notation for specifying behavior, interfaces, data flows, and state transitions.
- **Code snippets** (pseudocode, type definitions, schema fragments) are permitted **ONLY** when a Mermaid diagram cannot prevent implementation drift — for example, complex validation regex, exact serialization formats, or cryptographic parameter configurations.
- When code is used, it **MUST** be annotated with a comment explaining why a Mermaid diagram was insufficient.
- The detailed design **MUST NOT** descend to implementation level. It specifies *behavior and contracts*, not function bodies or class implementations.

## Verification Gate

After all detailed design files are written, the agent **MUST** pass through `verification-before-completion` (document mode) before invoking review or reporting completion. This means:

- Re-read `index.md` and every module file from disk.
- Confirm every module listed in the index has a corresponding file.
- Confirm every basic design function/feature ID is traceable to at least one module.
- Confirm no `TBD` / `TODO` / `???` placeholders remain.
- Confirm no empty sections (use "N/A — reason: ..." for inapplicable sections).
- Confirm Mermaid diagrams render without syntax errors.
- Re-check each of the 7 readability elements (`../../_shared/references/document-readability.md`): grammatical readability (sentence length, demonstratives), reader fit (intended-reader statement, acronym expansions), clarity & conciseness (no vague qualifiers, no duplication), referentiality (basic-design / sibling-module links resolve, DES-IDs unique), consistency (terminology, table column order), structure (template section order, one idea per paragraph), diagrams and formal language (every diagram/table has a 1-line caption; strict contracts use formal notation).

Fix any failures and re-run the gate until it passes cleanly.

## Mandatory Design Review

### Step 1 — Invoke `code-review-loop`

After writing the documents (and committing so `BASE_SHA` / `HEAD_SHA` are meaningful), invoke `code-review-loop` with:

| Parameter | Value |
| --- | --- |
| `WHAT_WAS_IMPLEMENTED` | `"Newly created detailed design at <path>"` |
| `PLAN_OR_REQUIREMENTS` | Pointer to the basic design document **and** to the template + rules files in `references/` |
| `BASE_SHA` | Commit immediately before the docs were added |
| `HEAD_SHA` | Commit containing the new docs |
| `DESCRIPTION` | 1–3 sentences on what the detailed design covers |

Instruct the reviewer to specifically check:
- Template and rules compliance
- Traceability to basic design elements (DES-IDs)
- Mermaid diagram correctness (no syntax errors, accurate flows)
- No implementation-level code without justification
- Internal consistency across module files
- Unresolved `TBD`s
- **Conformance to the 7 readability elements** (`../../_shared/references/document-readability.md`): grammatical readability / reader fit / clarity & conciseness / referentiality / consistency / structure / use of diagrams and formal language

### Step 2 — Handle feedback

The agent **MUST** handle the returned feedback through `code-review-loop`.

### Step 3 — Fix policy

| Severity | Required action |
| --- | --- |
| **Critical** (missing modules, contradicts basic design, violates notation rules) | **MUST** be fixed before reporting completion |
| **Important** | **MUST** be fixed unless the user explicitly waives them |
| **Minor** | **MAY** be deferred but **MUST** be listed in the final report |

### Step 4 — Re-review after fixes

After fixes, the agent **SHOULD** re-dispatch the reviewer on the new `HEAD_SHA`.

### Step 5 — Final report

The final report to the user **MUST** include a `Review:` line summarizing the outcome.
