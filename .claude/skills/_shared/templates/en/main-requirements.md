---
id: main-requirements
title: Requirements Definition (Whole System)
version: 0.1
status: draft
extends: []
supersedes: []
superseded_by: []
related: []
---

<!-- Frontmatter schema: see .claude/skills/_shared/references/doc-reference-syntax.md
     Lifecycle rules:   see .claude/skills/_shared/references/doc-lifecycle.md

     LENGTH POLICY (read before writing):
     - There is NO target line/page count. Do not anchor to ~1000 lines.
     - Quality over quantity: write only what each section's purpose actually
       requires. Light projects produce short docs; complex ones produce long
       docs. The document length MUST scale with the system, not with habit.
     - Do not pad sections to look thorough. If nothing applies, write
       "N/A — reason: ..." in one line and move on.
     - If a section does not apply, KEEP the heading and write
       "N/A — reason: ..." on one line. Do NOT delete the heading.
       Preserving headings lets later readers distinguish "considered
       and dismissed" from "never considered."
     - This applies to EVERY section, not just the obvious ones.
       Example: a foundational project with no business KPIs of its own
       should NOT invent KPIs — write "N/A — reason: this project is
       internal infrastructure; business KPIs are owned by consuming
       projects." Same rule for stakeholder lists, common interfaces,
       migration requirements, etc.
     - The urge to "pad to look thorough" is the signal to choose N/A.
     - Verification gate fails placeholders (TBD / TODO / ??? / empty
       bullet lists). A one-line "N/A — reason: ..." passes.
     - The template is a coverage checklist, not an essay assignment. -->


# Requirements Definition (Whole System)

This document captures cross-project requirements and indexes the per-subsystem requirements documents. Subsystem-specific details (functional, non-functional, UI, data, and so on) belong in each subsystem's `subsystem-requirements.md`.

| Field | Value |
| --- | --- |
| Project name | |
| Document ID | |
| Version | 0.1 |
| Created | YYYY-MM-DD |
| Author | |
| Approver | |

## Revision History
| Version | Date | Author | Change |
| --- | --- | --- | --- |
| 0.1 | YYYY-MM-DD | | Initial draft |

---

## 1. Introduction
### 1.1 Purpose
### 1.2 Document Structure
The relationship between this whole-system document and each subsystem-requirements document.

```
main-requirements.md          (this document — whole-system index)
└── subsystems/
    ├── 001_example-a/example-a-requirements.md
    ├── 002_example-b/example-b-requirements.md
    └── ...
```

### 1.3 Scope
### 1.4 Glossary (project-wide)
| Term | Definition |
| --- | --- |

### 1.5 Related Documents
| Name | Version | Notes |
| --- | --- | --- |

## 2. Stakeholders and Goals
### 2.1 Stakeholders
### 2.2 Business Goals
### 2.3 Success Metrics

## 3. Cross-Cutting Functional Requirements
Requirement IDs use the `REQ-MAIN-<n>` form (see `_shared/references/id-conventions.md`). Write detailed requirements as `### REQ-MAIN-<n>: <title>` headings.

## 4. Cross-Cutting Non-Functional Requirements
### 4.1 Performance
### 4.2 Availability
### 4.3 Security
### 4.4 Observability
### 4.5 Compliance

## 5. Constraints and Assumptions

## 6. Subsystem Index
| ID | Name | Summary | Requirements doc |
| --- | --- | --- | --- |

## 7. Open Questions

| ID | Question | Related subsystem | Raised | Due | Owner | Status |
| --- | --- | --- | --- | --- | --- | --- |
