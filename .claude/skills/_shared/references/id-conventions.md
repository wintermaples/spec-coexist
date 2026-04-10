# ID Conventions

Canonical naming rules for identifiers used across spec-coexist documents, tests, and evidence. This is the single source of truth — all skills and scripts reference this file.

Conformance keywords follow [RFC 2119](https://www.rfc-editor.org/rfc/rfc2119) / [RFC 8174](https://www.rfc-editor.org/rfc/rfc8174).

## Requirement IDs

Format: `REQ-<SUBSYSTEM>-<n>`

| Component | Rule | Example |
| --- | --- | --- |
| `REQ-` | Fixed prefix, uppercase | `REQ-` |
| `<SUBSYSTEM>` | Uppercase alphanumeric + underscore, matching the subsystem directory name (without numeric prefix) | `AUTH`, `PAYMENT`, `DASHBOARD_V2` |
| `<n>` | Sequential integer, no zero-padding required (but allowed) | `1`, `02`, `100` |

Examples: `REQ-AUTH-1`, `REQ-PAYMENT-3`, `REQ-INGEST-12`

### Whole-system requirements

For requirements in `docs/main-requirements.md` (not subsystem-scoped), use subsystem = `MAIN`:

`REQ-MAIN-1`, `REQ-MAIN-2`

### Placement

Requirement IDs **MUST** appear as inline markers in requirements documents:

```markdown
### REQ-AUTH-1: Password length minimum

The system SHALL enforce a minimum password length of 12 characters.
```

The heading format `### REQ-<SUBSYSTEM>-<n>: <title>` is the canonical form. IDs **MAY** also appear inline in prose (e.g., "as specified in REQ-AUTH-1").

## Design Element IDs

Format: `DES-<SUBSYSTEM>-<n>`

Same rules as requirement IDs but with `DES-` prefix. Used in basic design documents to mark design decisions that trace back to requirements.

Examples: `DES-AUTH-1`, `DES-PAYMENT-5`

### Placement

```markdown
### DES-AUTH-1: bcrypt hashing strategy

Implements [REQ-AUTH-1](../auth-requirements.md#req-auth-1-password-length-minimum).
```

Design elements **SHOULD** link back to the requirement(s) they satisfy using standard Markdown body links.

## Test IDs

Tests reference requirement IDs using `[REQ-xxx]` tags in test names or descriptions.

### Format by framework

**pytest:**
```python
def test_password_minimum_length():  # [REQ-AUTH-1]
    ...

class TestAuth:
    """[REQ-AUTH-1] [REQ-AUTH-2]"""
    ...
```

**Jest / Vitest:**
```typescript
it("enforces minimum password length [REQ-AUTH-1]", () => {
  ...
});

describe("Auth [REQ-AUTH-1] [REQ-AUTH-2]", () => {
  ...
});
```

**Go testing:**
```go
func TestPasswordMinLength(t *testing.T) { // [REQ-AUTH-1]
    ...
}
```

The `[REQ-xxx]` tag **MUST** appear in either the test function/method name comment or the test description string. The traceability scanner (`verify_traceability.sh`, `build_traceability_matrix.sh`) greps for the `REQ-<SUBSYSTEM>-<n>` pattern inside test files.

## Bidirectional Link Summary

```
Requirements doc          Design doc              Test file              Evidence
REQ-AUTH-1 ──────────► DES-AUTH-1 ◄──────── [REQ-AUTH-1] ◄──── verification-result
  (defines)         (implements, links       (covers, tags        (proves, references
                     back to REQ)            REQ in name)         REQ in subject)
```

The `build_traceability_matrix.sh` script aggregates all four columns and reports gaps.

## Scanner Regex

All scripts use this POSIX-extended regex to find IDs:

- Requirements: `REQ-[A-Z0-9_]+-[0-9]+`
- Design elements: `DES-[A-Z0-9_]+-[0-9]+`

## See also

- [`doc-reference-syntax.md`](./doc-reference-syntax.md) — body link and frontmatter reference rules
- [`doc-lifecycle.md`](./doc-lifecycle.md) — document state transitions
- `_shared/scripts/verify_traceability.sh` — REQ-ID coverage checker
- `_shared/scripts/build_traceability_matrix.sh` — full traceability matrix builder
