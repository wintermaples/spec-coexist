# Document Readability

Canonical definition and 7-element evaluation framework for spec-coexist documents. This file is the single source of truth: `creating-requirements`, `creating-basic-design`, and `creating-detail-design` link here rather than duplicating the rules. The same elements apply during writing and at the `verification-before-completion` gate.

Conformance keywords follow [RFC 2119](https://www.rfc-editor.org/rfc/rfc2119) / [RFC 8174](https://www.rfc-editor.org/rfc/rfc8174).

## Definition

> **Document readability is the degree to which the intended reader can extract the information they need from the document, with the effort they can afford, and understand it correctly.**

**Scope:** content only. Visual readability (typography — font, size, line spacing, color, contrast) is **out of scope** for this guide.

## The 7 Elements

### 1. Grammatical readability (易読性)

The text is grammatically correct and uses standard syntax and word order. This is the reader-independent baseline: regardless of audience, does the prose hold together as well-formed sentences?

**Apply when writing:**
- Keep subject and predicate aligned. One main idea per sentence; omit the subject only when context makes it unambiguous.
- Avoid double negatives, chained passive constructions, and demonstratives ("this", "that", "the same") that point at antecedents far away.
- Keep sentences roughly under 25–30 words (60–80 Japanese characters). Split long sentences into bullets or two sentences.

### 2. Reader fit (読み手適合性)

Vocabulary, concepts, and assumed prior knowledge match the intended audience's language, expertise, specialty, and purpose. This is the reader-dependent quality: the same prose may be readable to one audience and opaque to another.

**Apply when writing:**
- State the **intended reader** explicitly at the top of the document (e.g., "The intended readers of this document are developers and operators of this system").
- Define non-obvious domain terms on first use, or point to a glossary section.
- Spell out specialist acronyms (API/SLA/RPO/RTO/...) on first occurrence.
- When prerequisite knowledge lives in another document, link to it explicitly ("Read `docs/main-requirements.md` before this document").

### 3. Clarity & conciseness (明確性・簡潔性)

The text is unambiguous and free of contradictions, with no redundant phrasing or unnecessary repetition. Required information is present in the right amount — neither missing nor padded.

**Apply when writing:**
- Avoid vague qualifiers that push interpretation onto the reader: "appropriately", "as needed", "basically", "etc.", "such as". Replace them with concrete conditions, thresholds, or named targets.
- State each fact in exactly one place. Pick a primary location and have other sections reference it.
- Resolve every `TBD` / `TODO` / `???` placeholder before the verification gate, or move it to an explicit open-issues section.

### 4. Referentiality (参照性)

In long documents, internal information is referenced where it is needed. In specifications, designs, and other technical documents, cross-document references are also in place.

**Apply when writing:**
- Give chapters and sections unique headings; use heading or anchor links for in-document references.
- Reference upstream documents (requirements → basic design → detail design) by relative path and section name. See `doc-reference-syntax.md`.
- Use IDs (REQ-ID / DES-ID / module-ID) as the primary keys for cross-document traceability.
- Make important references explicit in prose so the reader can immediately tell where the source of truth lives.

### 5. Consistency (一貫性)

Terminology and notation are uniform throughout the document.

**Apply when writing:**
- Use one canonical term per concept (do not mix "user" / "end-user" / "consumer" for the same actor).
- Pin terminology in a glossary or a "Definitions" section near the top, and reuse it everywhere.
- Keep structural conventions uniform: section anatomy, table column order, bullet style.
- RFC 2119 modal verbs (MUST / SHOULD / MAY ...) are normative **only** when used in all caps. Avoid mixing them with lowercase "must" / "should" used in everyday prose.

### 6. Structure (構造化)

In long documents, the document is organized so that paragraphs and sections are arranged in a logical sequence.

**Apply when writing:**
- Follow the section order specified by the template. Reordering sections breaks the structure readers rely on.
- One idea per paragraph. Split paragraphs that mix multiple points.
- Default ordering: abstract → concrete, overview → detail, why → what → how.
- Limit nesting to three levels by default. Beyond that, split the document.

### 7. Use of diagrams and formal language (図表・形式言語の活用)

Use diagrams where they help reader comprehension. Use formal languages where ambiguity must be eliminated.

**Apply when writing:**
- Structure, relationships, transitions, and flows are usually faster to grasp from a diagram than from long prose. Prefer Mermaid as the first choice; quality rules live in `../beautiful-mermaid-rules/`.
- Tables fit enumerations, mappings, and conditional matrices well.
- Where strictness matters (interface contracts, data schemas, state machines, validation rules), use formal language: type definitions, JSON Schema, state-machine notation, regular expressions.
- Every diagram or table **MUST** be accompanied by a one-line caption (or a sentence immediately above) that states what it shows.

## Verification Checklist (summary)

After writing, the agent **MUST** confirm each item below as part of the `verification-before-completion` gate (document mode):

- [ ] **Grammatical readability** — Sentence length, grammar, and word order read cleanly. Demonstratives have unambiguous antecedents.
- [ ] **Reader fit** — Intended reader is stated up front. Specialist terms and acronyms are defined or expanded on first use.
- [ ] **Clarity & conciseness** — No vague qualifiers ("appropriately", "as needed", "fast", "easy to use") remain without measurable definitions. No fact is duplicated across sections. No placeholders remain.
- [ ] **Referentiality** — Cross-document links resolve. REQ-IDs / DES-IDs / module-IDs are unique and reachable. The source of truth for each major fact is identifiable.
- [ ] **Consistency** — Terminology and notation are uniform. Table columns, bullet styles, and section anatomy are consistent throughout.
- [ ] **Structure** — Template section order is preserved. One idea per paragraph. Nesting depth ≤ 3.
- [ ] **Diagrams & formal language** — Structures, transitions, and flows are shown via diagrams or tables where prose would be longer or more ambiguous. Each diagram or table has a one-line caption. Strict contracts use formal notation.

If any item is FAIL, fix the document and re-run the checklist from the top. Do not report completion to the user until every item is PASS.

## Scope of Application

This guide is normative for the following skills, which **MUST** apply it:

- `creating-requirements` — requirements documents (whole-system / subsystem)
- `creating-basic-design` — basic design documents (whole-system / subsystem)
- `creating-detail-design` — detailed design documents (whole-system / subsystem)

When `revising` updates an existing document, the revised result **SHOULD** also satisfy the seven elements.
