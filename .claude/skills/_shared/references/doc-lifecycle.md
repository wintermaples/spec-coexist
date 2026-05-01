# Document Lifecycle

How spec-coexist documents move through states and reference each other across revisions. Read alongside [`doc-reference-syntax.md`](./doc-reference-syntax.md), which defines the schema for the references mentioned here.

Conformance keywords follow [RFC 2119](https://www.rfc-editor.org/rfc/rfc2119) / [RFC 8174](https://www.rfc-editor.org/rfc/rfc8174).

## States

| `status` | Meaning |
| --- | --- |
| `draft` | In progress, not yet agreed. May be incomplete. |
| `active` | Current source of truth. |
| `deprecated` | Still exists but **MUST NOT** be followed for new work. Requires `superseded_by`. |
| `superseded` | Replaced by one or more successor documents. Requires `superseded_by`. |

**Choosing between `deprecated` and `superseded`:** use `superseded` when a concrete replacement exists, and `deprecated` when the doc is retired without a 1:1 replacement (a pointer to the new scope is still required).

## Transitions

```
draft ──► active ──► deprecated
                 └─► superseded
```

Transitions **MUST** go through the `revising` skill so that the link checker runs and the frontmatter stays consistent.

## Rules

1. A document with `status: deprecated` or `superseded` **MUST** have a non-empty `superseded_by`.
2. Every entry in a doc's `supersedes` list **SHOULD** itself be `deprecated` or `superseded`; otherwise the checker emits a warning.
3. The `extends` graph across all docs **MUST** be acyclic — a cycle is a checker error.
4. A superseded document **MUST NOT** be deleted while any live doc still references it. Update the live doc's link first, then delete.
5. When revising, bump `version` and update the `Revision History` table in the body. Add the old path to the new doc's `supersedes` **only** when producing a parallel replacement, not when making an in-place edit.

## Examples

### In-place revision (no supersede)

```yaml
# before
version: 0.3
status: active

# after
version: 0.4
status: active
```

No `supersedes` entry is needed: the path is stable, and the history lives in the body's `Revision History` table.

### Parallel replacement

```yaml
# docs/subsystems/03_auth/auth-requirements.md  (old)
status: superseded
superseded_by:
  - ../03_auth_v2/auth-requirements.md

# docs/subsystems/03_auth_v2/auth-requirements.md  (new)
status: active
supersedes:
  - ../03_auth/auth-requirements.md
```

The checker confirms that both sides reference each other and that the old doc's status is retired.

## See also

- [`doc-reference-syntax.md`](./doc-reference-syntax.md) — frontmatter schema and body link rules.
