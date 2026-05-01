# Document Reference Syntax

Canonical rules for how spec-coexist documents reference each other. This file is the single source of truth: every `creating-*` and `revising-*` skill links here rather than duplicating the rules.

Conformance keywords follow [RFC 2119](https://www.rfc-editor.org/rfc/rfc2119) / [RFC 8174](https://www.rfc-editor.org/rfc/rfc8174).

## Layer 1 — Body links

Documents **MUST** reference other spec documents through plain GitHub-flavored Markdown links:

```markdown
See [§4.3 Security](../../main-requirements.md#43-security).
Supersedes [old auth design](../auth-v1/auth-v1-design.md).
```

Rules:

1. Paths **MUST** be relative to the source file; absolute filesystem paths are forbidden. The link checker treats a leading `/` as "relative to the docs root", but prefer `../` style for portability.
2. The path component **MUST** end in `.md`. Non-`.md` links (images, code, external URLs) are ignored by the checker.
3. Anchors are optional. When present, they **MUST** use GitHub-style slugs (lowercase, spaces replaced with `-`, punctuation stripped). The checker validates every anchor against the heading slugs of the target file.
4. External links (`http://`, `https://`, `mailto:`) and pure in-page anchors (`#section`) are outside the checker's scope and **MAY** be used freely.

## Layer 2 — Lifecycle frontmatter

Every requirements or basic-design document created or revised after this change lands **MUST** begin with a YAML frontmatter block:

```yaml
---
id: subsys-03_auth
title: Auth subsystem requirements
version: 0.3
status: active
extends:
  - ../../main-requirements.md
supersedes:
  - ../auth-v1/auth-v1-requirements.md
superseded_by: []
related:
  - ../../main-basic-design.md#4-auth
---
```

Field reference:

| Field | Type | Required | Meaning |
| --- | --- | --- | --- |
| `id` | string | yes | Stable identifier. For subsystems, use the `{id}_{name}` directory prefix. For nested subsystems, use the `~`-separated qualified form: `subsys-001_common~001_notification`. |
| `title` | string | yes | Human-readable title. |
| `version` | string | yes | Semantic-ish version; bumped by `revising`. |
| `status` | enum | yes | One of `draft`, `active`, `deprecated`, `superseded`. |
| `extends` | list of refs | no | Documents this doc inherits / specializes. Cycles are forbidden. |
| `supersedes` | list of refs | no | Older documents this one replaces. Each target **SHOULD** be `deprecated` or `superseded`. |
| `superseded_by` | list of refs | conditional | **MUST** be non-empty when `status` is `deprecated` or `superseded`. |
| `related` | list of refs | no | Non-inheriting cross-references (e.g. the matching basic-design for a requirements doc). |

All ref values in `extends` / `supersedes` / `superseded_by` / `related` follow the **same Layer 1 path rules**, so the checker validates body links and frontmatter refs in a single pass.

For nested subsystems, `extends` forms a chain from child to root: child subsystem → parent subsystem → main document. For example, `notification-requirements.md` extends `../../common-requirements.md`, which in turn extends `../../main-requirements.md`.

## Parser subset

The shipped checker (`_shared/scripts/check_doc_links.py`) intentionally supports only a small YAML subset:

- Scalar strings (quoted or bare).
- Flat lists of strings (`- item`).
- Comments (`#`).

Nested maps, anchors, and flow-style collections are **NOT** supported — keep frontmatter flat.

## See also

- [`doc-lifecycle.md`](./doc-lifecycle.md) — state transitions and lifecycle rules.
- `_shared/scripts/check_doc_links.sh` — the checker that enforces this spec.
