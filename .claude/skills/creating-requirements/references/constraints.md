# Hard Constraints — creating-requirements

## 1. No updates to existing documents

This skill **MUST NOT** update an existing requirements document. If the target file already has non-trivial content, the skill **MUST** halt immediately and tell the user:

> "That document already exists. To revise it, invoke `spec-coexist:revising` instead."

Use `check_doc_exists.sh <path>` to detect existence. A non-trivial file is any file whose content is not empty and is not solely the placeholder created in Step 1.

**Rationale:** creating and revising are different cognitive tasks with different process gates. Mixing them leads to silent overwrites of agreed requirements.

## 2. Read draft before brainstorming

If the user supplies a draft file path at invocation, the skill **MUST** read the draft before asking any questions. The draft may pre-answer many brainstorming questions, so asking them redundantly wastes user time.

## 3. Template compliance

The final document **MUST** follow the template that matches the target scope:

- Whole-system → `references/main-requirements-template.md`
- Subsystem → `references/subsystem-requirements-template.md`

Every required section heading **MUST** be present. Rows in required tables **MUST NOT** be omitted entirely; use an explicit "N/A" or "TBD" entry only if the information is genuinely unknown and mark it as an open issue in section 8.

## 4. Verification before completion

Before reporting completion to the user, the agent **MUST** pass through `verification-before-completion` (document mode). See `references/verification-checklist.md` for the exact gate. Writing the file is not the same as the file being correct.
