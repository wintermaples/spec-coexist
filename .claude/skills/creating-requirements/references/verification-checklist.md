# Verification Checklist — creating-requirements

Run this checklist as the `verification-before-completion` gate (document mode) **before** reporting completion to the user. Fix every failure and re-run until the checklist passes clean.

## How to run

1. Re-read the target file from disk — do not rely on what you just wrote.
2. Work through every item below; mark each PASS or FAIL with a one-line reason.
3. Report the results to the user as part of the completion message.

## Checklist

### Structure
- [ ] Frontmatter table is present (プロジェクト名, 文書番号, バージョン, 作成日, 作成者, 承認者).
- [ ] 改訂履歴 table is present with at least one row.
- [ ] All required top-level sections (1 through 8 + 付録) are present.
- [ ] All required subsections within each section are present.

### Content completeness
- [ ] No unresolved placeholders remain: `TBD`, `TODO`, `???`, `<fill in>`, `YYYY-MM-DD` (unless intentional future date fields), or empty table cells where content is required.
- [ ] No empty bullet points (a bullet with no text, or only whitespace).
- [ ] Section 5.1 (機能一覧) contains MoSCoW priority for every row (subsystem docs only).
- [ ] Non-functional requirements (section 6) contain numeric targets, not vague qualitative descriptions.
- [ ] Section 2.3/2.4 KPI/KGI rows have current value, target value, and measurement method filled in (or are explicitly marked as an open issue in section 8).

### Cross-references
- [ ] Every subsystem listed in section 5.2 (whole-system docs) has a corresponding `*-requirements.md` link or an explicit note that it is planned.
- [ ] Frontmatter `バージョン` is `0.1` for a new document.
- [ ] Frontmatter `作成日` is today's date (not `YYYY-MM-DD`).

### Readability (per `../../_shared/references/document-readability.md`)
- [ ] **易読性** — Sentences are grammatically clean; long sentences are split; demonstratives ("これ", "それ", "同様") have unambiguous antecedents.
- [ ] **読み手適合性** — The intended reader is stated up front (section 1.1 / 1.2). Domain-specific terms and acronyms are defined on first use or via 用語定義.
- [ ] **明確性・簡潔性** — No vague qualifiers ("適切に", "など", "必要に応じて", "高速に") remain without a measurable definition. The same fact is not duplicated across sections.
- [ ] **参照性** — Cross-document links (parent requirements, sibling subsystems, related design) resolve. REQ-IDs are unique and reachable.
- [ ] **一貫性** — Terminology is uniform (no mix of "ユーザ"/"ユーザー", "サブシステム"/"子システム", etc.). Table column orders and bullet styles are consistent throughout.
- [ ] **構造化** — Template section order is preserved. One idea per paragraph. Nesting depth ≤ 3.
- [ ] **図表・形式言語の活用** — Structures, flows, and relationships are shown via diagrams (Mermaid) or tables where natural-language prose would be longer or more ambiguous. Each diagram/table has a 1-line caption stating what it shows.

### Gate
If **any** item above is FAIL, fix the document and re-run the checklist from the top. Do not report completion until every item is PASS.
