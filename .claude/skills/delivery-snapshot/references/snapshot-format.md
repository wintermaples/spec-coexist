# Snapshot Document Format

Canonical structure for `docs/_generated/snapshot-<date>.md`. The `delivery-snapshot` skill **MUST** produce output conforming to this format.

## File naming

`snapshot-YYYY-MM-DD.md`

If multiple snapshots are generated on the same day, append a counter: `snapshot-YYYY-MM-DD-2.md`.

## Document structure

```markdown
---
id: snapshot-YYYY-MM-DD
title: Delivery Snapshot — YYYY-MM-DD
generated_at: <ISO 8601 UTC>
generated_by: delivery-snapshot skill
---

# Delivery Snapshot — YYYY-MM-DD

## Summary

| Metric | Value |
| --- | ---: |
| Total REQ-IDs | N |
| Active (status: active) | N |
| Draft (status: draft) | N |
| Retired (deprecated/superseded) | N |
| Test-covered REQ-IDs | N |
| Uncovered REQ-IDs | N |
| Coverage % | N% |

## Completed Requirements (status: active, has verification)

List of REQ-IDs with status=active AND at least one passing `verification-result` evidence.

| REQ-ID | Title | Subsystem | Verification Date |
| --- | --- | --- | --- |

## In-Progress Requirements (status: draft)

| REQ-ID | Title | Subsystem | Owner (if known) | Age (days since creation) |
| --- | --- | --- | --- | --- |

## Uncovered Requirements (no test references)

| REQ-ID | Title | Subsystem | Status |
| --- | --- | --- | --- |

## Recently Modified Design Elements

Design documents modified in the reporting period (default: last 14 days).

| File | Last Modified | Summary of Change |
| --- | --- | --- |

## Subsystem Dependency Graph

Mermaid diagram of subsystem relationships, generated from `subsystem_deps.sh`.

\```mermaid
graph LR
    subgraph Subsystems
        ...
    end
\```

## Orphan Tests

Tests referencing non-existent REQ-IDs (from traceability matrix).

| REQ-ID (missing) | Test File |
| --- | --- |
```

## Field definitions

- **Age**: calendar days since the file was first committed (via `git log --follow --diff-filter=A`).
- **Owner**: extracted from the doc frontmatter if an `owner` field exists; otherwise "—".
- **Coverage %**: `(covered / total) * 100`, rounded to nearest integer.
- **Reporting period**: default 14 days; overridable via `--since` flag if the skill supports it.

## Mermaid style

Follow `_shared/beautiful-mermaid-rules/` conventions for node shapes and edge labels. Use `graph LR` (left-to-right) for subsystem dependencies to keep the diagram readable.

## Generated file policy

Files in `docs/_generated/` are machine-generated artifacts:

- They **MUST NOT** be manually edited (edits will be overwritten).
- They **SHOULD** be committed to the repository for stakeholder access.
- They **MAY** be `.gitignore`d if the team prefers on-demand generation.
