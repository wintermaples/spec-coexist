# Code Quality Checklist

Single source of truth for what "disciplined code" means in this suite. Walk this file end-to-end
for every changed file in the diff. Each section lists concrete questions; a file passes only when
every applicable question is answered affirmatively in writing.

Conformance keywords follow RFC 2119.

## 1. SOLID (lightweight)

- **Single responsibility** — does this function/class do exactly one thing described by its name?
- **Open/closed** — when a new case is added, is the change additive (new file, new branch) rather
  than invasive rewrites of stable callers?
- **Liskov** — do subtypes honor the contract of their supertype? No weakened preconditions, no
  strengthened postconditions?
- **Interface segregation** — are callers forced to depend on methods they do not use?
- **Dependency inversion** — does the module depend on an abstraction the caller owns, rather than
  a concretion the callee imposes?

Any "no" is **at least Important**.

## 2. Naming

- Do names describe **intent**, not implementation? (`retryAfterBackoff` over `sleepLoop`)
- Are booleans positively phrased? (`isEnabled`, not `notDisabled`)
- Are units on numeric names? (`timeoutMs`, `sizeBytes`)
- Are abbreviations either industry-standard (HTTP, URL) or expanded?
- Do test names state the behavior under test, not the function name?

## 3. Complexity

- Cyclomatic complexity per function **SHOULD** stay ≤ 10. If higher, is there a documented reason?
- Nesting depth **SHOULD** stay ≤ 3. Early returns are preferred over pyramids.
- Functions **SHOULD** fit on one screen (≤ ~50 lines) unless they are a straight-line sequence.
- Does any single function mix IO, computation, and error recovery? Split it.

## 4. Boundaries

- Where does untrusted input cross into the system? Is it validated **at the boundary**, not deep
  inside?
- Where does the system call external services? Is the failure mode (timeout, 5xx, partial) handled
  explicitly?
- Are public interfaces of the changed module minimized? Every exported symbol is a commitment.
- Does the diff leak internal types across a module boundary that the spec says should be opaque?

## 5. Error handling

- Is every `try` paired with a specific, actionable `catch`? No bare `except:` / `catch (e) {}`.
- Are errors **typed** so callers can distinguish recoverable from fatal?
- Do error messages include enough context to locate the failure (id, operation, inputs) without
  leaking secrets?
- Are retries bounded? Is backoff present where appropriate?
- Does the code swallow an error anywhere? If yes, is there a written justification?

## 6. Dead code

- Are there commented-out blocks? Delete them; git is the archive.
- Are there parameters, imports, or local variables the diff introduced and never reads?
- Are there functions added in this diff that have no caller? If a caller is coming in a later
  commit, is that stated in the evidence record?

## 7. Secrets

- Does the diff introduce any literal that looks like a key, token, password, or connection string?
  **Critical** if yes.
- Are secrets read from the environment or a secrets manager, not hard-coded?
- Does logging or error formatting inadvertently include secret-bearing fields?
- Are test fixtures using obviously fake credentials (`test_api_key_DO_NOT_USE`)?

## 8. Logging

- Is each added log line at the right level? (`debug` for flow, `info` for state changes, `warn`
  for recoverable surprises, `error` for actionable failures.)
- Does the log line carry correlation information (request id, subject, operation)?
- Is there a noisy log inside a tight loop? Remove or downgrade.
- Does any log line contain PII or secrets? **Critical** if yes.

## Severity mapping

- **Critical** — secret leaks, unhandled untrusted input, broken contract with callers, swallowed
  errors in a security-relevant path.
- **Important** — SOLID or boundary violations, missing error types, dead code in a hot path,
  complexity escalation without justification.
- **Minor** — naming nits, log level tweaks, test-name clarity.

Critical and Important findings **MUST** be fixed before `code-review-loop` is dispatched.
