---
id: {{SUBSYSTEM_ID}}_requirements
title: Requirements Definition — {{SUBSYSTEM_NAME}}
version: 0.1
status: draft
extends:
  - {{EXTENDS_PATH}}
supersedes: []
superseded_by: []
related: []
---

<!-- Frontmatter schema: see .claude/skills/_shared/references/doc-reference-syntax.md
     Lifecycle rules:   see .claude/skills/_shared/references/doc-lifecycle.md

     LENGTH POLICY (read before writing):
     - There is NO target line/page count. Do not anchor to ~1000 lines.
     - Quality over quantity. A 3-feature subsystem doc that runs 80–150
       lines is correct; a 20-feature subsystem cannot. Length MUST scale
       with feature count and business complexity.
     - Do not pad sections to look thorough. If nothing applies, write
       "N/A — reason: ..." in one line and move on.
     - If a section does not apply, KEEP the heading and write
       "N/A — reason: ..." on one line. Do NOT delete the heading.
       Preserving headings lets later readers distinguish "considered
       and dismissed" from "never considered."
     - This applies to EVERY section, not just the obvious ones.
       Example: a screen-only subsystem with no printed forms should
       NOT invent a form — write "N/A — reason: no printed output;
       this subsystem is purely interactive." Same rule for KPIs,
       external interfaces, migration requirements, etc.
     - The urge to "pad to look thorough" is the signal to choose N/A.
     - Verification gate fails placeholders (TBD / TODO / ??? / empty
       bullet lists). A one-line "N/A — reason: ..." passes.
     - The template is a coverage checklist, not an essay assignment. -->


# Requirements Definition — {{SUBSYSTEM_NAME}}

| Field | Value |
| --- | --- |
| Subsystem ID | {{ID}} |
| Subsystem name | {{SUBSYSTEM_NAME}} |
| Version | 0.1 |
| Created | YYYY-MM-DD |
| Author | |
| Approver | |

## Revision History
| Version | Date | Author | Change |
| --- | --- | --- | --- |
| 0.1 | YYYY-MM-DD | | Initial draft |

## 1. Purpose and Scope
### 1.1 Purpose of this subsystem
### 1.2 In scope
### 1.3 Out of scope

## 2. Actors and Use Cases
### 2.1 Actors
### 2.2 Primary use cases
### 2.3 Alternative / exception flows

## 3. Functional Requirements
Requirement IDs use the `REQ-{{SUBSYSTEM}}-<n>` form (see `_shared/references/id-conventions.md`; `{{SUBSYSTEM}}` is the uppercase subsystem name). They are the traceability key for DES-IDs and `[REQ-xxx]` test tags. Write detailed requirements as `### REQ-{{SUBSYSTEM}}-<n>: <title>` headings.

| REQ-ID | Requirement | Priority | Acceptance criteria |
| --- | --- | --- | --- |
| REQ-{{SUBSYSTEM}}-1 | | | |

## 4. Non-Functional Requirements
### 4.1 Performance
### 4.2 Reliability
### 4.3 Security
### 4.4 Usability
### 4.5 Maintainability

## 5. Data Requirements
### 5.1 Key entities
### 5.2 Retention / lifecycle

## 6. External Interfaces
| Name | Direction | Protocol | Notes |
| --- | --- | --- | --- |

## 7. Constraints and Assumptions

## 8. Open Questions

| ID | Question | Raised | Due | Owner | Status |
| --- | --- | --- | --- | --- | --- |
