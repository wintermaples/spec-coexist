---
id: main-detail-design
title: Detailed Design (Whole System)
version: 0.1
status: draft
extends:
  - ../main-basic-design.md
supersedes: []
superseded_by: []
related: []
---

<!-- Frontmatter schema: see .claude/skills/_shared/references/doc-reference-syntax.md
     Lifecycle rules:   see .claude/skills/_shared/references/doc-lifecycle.md

     NOTATION POLICY (read before writing):
     - Mermaid diagrams are the PRIMARY notation (sequence, state,
       flowchart, class, ER). Code snippets are allowed ONLY when
       a Mermaid diagram cannot prevent implementation drift (e.g.
       complex regex, serialization format, crypto config).
     - When code is used, annotate with a comment explaining why
       Mermaid was insufficient.
     - This document specifies BEHAVIOR and CONTRACTS, not
       implementation. Do not write function bodies, method
       implementations, or algorithm pseudocode.

     LENGTH POLICY:
     - There is NO target line/page count.
     - If a section does not apply, KEEP the heading and write
       "N/A — reason: ..." on one line. Do NOT delete the heading.
     - The template is a coverage checklist, not an essay. -->


# Detailed Design (Whole System)

This document captures the whole-system detailed-design patterns and indexes the per-subsystem detailed-design documents.

| Field | Value |
| --- | --- |
| Project name | |
| Document ID | |
| Version | 0.1 |
| Created | YYYY-MM-DD |
| Author | |

## Revision History

| Version | Date | Author | Change |
| --- | --- | --- | --- |
| 0.1 | YYYY-MM-DD | | Initial draft |

---

## 1. Introduction

### 1.1 Purpose

This document takes the architectural decisions from the basic design and specifies them with enough precision to prevent implementation drift. Mermaid diagrams are the primary notation.

### 1.2 Relation to basic design

```
main-basic-design.md              (basic design: whole system)
├── main-detail-design/            (this document: whole-system detail design)
│   └── index.md
├── subsystems/
│   ├── SUB-A/detail-design/       (subsystem detail design)
│   │   ├── index.md
│   │   ├── module-1.md
│   │   └── module-2.md
│   └── ...
```

### 1.3 Related documents

| Document | Version | Notes |
| --- | --- | --- |
| Basic Design (Whole System) | | Parent document |
| Requirements (Whole System) | | Traceability |

---

## 2. Cross-Cutting Patterns

### 2.1 Authentication / authorization flow

N/A — reason: ... (or define with sequence diagram)

### 2.2 Common error handling flow

N/A — reason: ... (or define with flowchart)

### 2.3 Common data transformation patterns

N/A — reason: ... (or define with flowchart / class diagram)

### 2.4 Common logging patterns

N/A — reason: ... (or define with sequence diagram)

---

## 3. Subsystem Detailed Design Index

| # | Subsystem ID | Subsystem name | Detailed design | Status |
| --- | --- | --- | --- | --- |
| 1 | SUB-A | | [detail-design](./subsystems/SUB-A/detail-design/index.md) | |
| 2 | SUB-B | | [detail-design](./subsystems/SUB-B/detail-design/index.md) | |

---

## 4. Design Decision Records (Cross-Cutting)

| ID | Decision | Options considered | Chosen | Rationale | Related subsystems |
| --- | --- | --- | --- | --- | --- |
| DDR-MAIN-01 | | | | | |

---

## 5. Open Questions

<!-- TODO(en): align with ja template once in active use. -->
