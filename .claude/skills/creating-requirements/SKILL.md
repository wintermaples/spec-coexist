---
name: creating-requirements
user-invocable: true
description: Use whenever the user wants to CREATE a new requirements document — whole-system (`docs/main-requirements.md`) or subsystem (`docs/subsystems/{id}_{name}/{name}-requirements.md`, including nested subsystems like `docs/subsystems/.../subsystems/{id}_{name}/{name}-requirements.md`). Trigger on phrases like "要件定義を作る", "draft requirements", "new requirements doc", "要件をまとめたい", or any request that implies producing a fresh requirements artifact. This skill MUST NOT update an existing requirements document — it only creates new ones.
---

# creating-requirements

Conformance keywords (MUST / MUST NOT / SHOULD / MAY / ...) follow [RFC 2119](https://www.rfc-editor.org/rfc/rfc2119) / [RFC 8174](https://www.rfc-editor.org/rfc/rfc8174).

## Independence

This skill **MUST NOT** invoke or delegate to any `superpowers:*` skill.

## Hard Constraints (summary)

See `references/constraints.md` for full detail.

- **MUST NOT** update an existing document — halt and direct to `spec-coexist:revising`.
- **MUST** read any draft file supplied at invocation before brainstorming.
- **MUST** follow the template that matches the target document type.
- **MUST** pass `verification-before-completion` (document mode) before reporting done.
- **SHOULD** — when writing any Mermaid diagram in the requirements document, consult the matching rule file under `../_shared/beautiful-mermaid-rules/` (e.g. `flowchart.md`, `sequence-diagram.md`, `state-diagram.md`, `class-diagram.md`, `entity-relationship-diagram.md`, `user-journey.md`, `architecture.md`, `requirement-diagram.md`, `quadrant-chart.md`, `packet.md`, `ishikawa.md`) and follow its guidance so the resulting diagram is clean and readable.

## Steps

0. **Resolve locale** — apply the procedure in `../_shared/templates/README.md` to pick `ja` or `en`. Record the result; every template load in later steps **MUST** use the resolved locale. `ja` loads templates from this skill's `references/`; `en` loads from `../_shared/templates/en/`.
1. **Bootstrap** — run `check_doc_exists.sh docs/main-requirements.md`; read it if it exists, otherwise create an empty placeholder.
2. **Read draft** — if the user supplied a draft path, read it now.
3. **Decide scope** — ask one question: whole-system or subsystem?
4. **Resolve target path** — see `references/path-resolution.md`.
5. **Brainstorm** — follow `references/brainstorming-rules.md`. Read the relevant template + rules files so questions align with what the template requires.
6. **Write document** — follow the template strictly (`references/main-requirements-template.md` or `references/subsystem-requirements-template.md` + their `*-rules.md` companions). Frontmatter and cross-doc links **MUST** follow `../_shared/references/doc-reference-syntax.md` and `../_shared/references/doc-lifecycle.md`.
7. **Check doc links** — run `../_shared/scripts/check_doc_links.sh --root docs --strict`. All errors **MUST** be fixed before proceeding.
8. **Verify (MANDATORY)** — pass through `verification-before-completion` (document mode); see `references/verification-checklist.md`. Fix and re-run until PASS.
9. **Stop** — do not start design or implementation in the same skill invocation.

## Scripts

Invoke from `../_shared/scripts/`:

| Script | Purpose |
| --- | --- |
| `check_doc_exists.sh <path>` | Exit 0 if the file exists (signal to halt) |
| `check_doc_links.sh --root docs --strict` | Validate frontmatter refs, body links, and lifecycle |
| `next_subsystem_id.sh [parent-dir]` | Print the next 3-digit subsystem id (default parent: `docs`) |
| `ensure_subsystem_dir.sh <name> [parent-dir]` | Allocate id and create `{parent}/subsystems/{id}_{name}/` (default parent: `docs`) |
| `qualify_subsystem_id.sh <path>` | Convert subsystem dir path to `~`-separated qualified id |
| `resolve_subsystem_path.sh <qualified-id>` | Convert qualified id back to filesystem path |
| `gen_questions_path.sh requirements` | Print the questions-file path and ensure its parent dir |

## References

| File | Contents |
| --- | --- |
| `references/constraints.md` | Full hard constraints with rationale |
| `references/path-resolution.md` | Target path resolution for whole-system vs subsystem |
| `references/brainstorming-rules.md` | Question rules, question-file threshold, Visual Companion gate |
| `references/verification-checklist.md` | Mandatory checks before reporting completion |
| `references/main-requirements-template.md` | Whole-system document template |
| `references/main-requirements-template-rules.md` | Whole-system authoring guide |
| `references/subsystem-requirements-template.md` | Subsystem document template |
| `references/subsystem-requirements-template-rules.md` | Subsystem authoring guide |
