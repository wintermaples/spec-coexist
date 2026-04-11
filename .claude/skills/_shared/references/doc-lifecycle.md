# Document Lifecycle

How spec-coexist documents move through states and reference each other across revisions. Pairs with [`doc-reference-syntax.md`](./doc-reference-syntax.md).

Conformance keywords follow [RFC 2119](https://www.rfc-editor.org/rfc/rfc2119) / [RFC 8174](https://www.rfc-editor.org/rfc/rfc8174).

## States

| `status` | Meaning |
| --- | --- |
| `draft` | In progress, not yet agreed. May be incomplete. |
| `active` | Current source of truth. |
| `deprecated` | Still exists but **MUST NOT** be followed for new work. Requires `superseded_by`. |
| `superseded` | Replaced by one or more successor documents. Requires `superseded_by`. |

`deprecated` vs `superseded`: use `superseded` when a concrete replacement exists; use `deprecated` when the doc is retired without a 1:1 replacement (but a pointer to the new scope is still required).

## Transitions

```
draft ──► active ──► deprecated
                 └─► superseded
```

Transitions **MUST** be performed via the `revising` skill so that the link checker runs and frontmatter stays consistent.

## Rules

1. A document with `status: deprecated` or `superseded` **MUST** have a non-empty `superseded_by`.
2. Every entry in a doc's `supersedes` list **SHOULD** itself be `deprecated` or `superseded` — if not, the checker emits a warning.
3. The `extends` graph across all docs **MUST** be acyclic. A cycle is a checker error.
4. Deleting a superseded document is **NOT** allowed while any live doc still references it. Change the live doc's link first, then delete.
5. When revising, bump `version`, update the `Revision History` table inside the body, and add the old path to the new doc's `supersedes` only if you are producing a parallel replacement (not an in-place edit).

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

No `supersedes` entry — the path is stable, the history lives in the body table.

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

The checker validates that both sides point at each other and that the old doc's status is retired.

## See also

- [`doc-reference-syntax.md`](./doc-reference-syntax.md) — frontmatter schema and body link rules.
