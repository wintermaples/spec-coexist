# Subagent Dispatch Template

How to dispatch parallel agents — one per worktree — and collect their results.

## Agent count

- **Minimum**: 2. Below this, use sequential `implementing-from-spec` instead.
- **Maximum**: 4. Beyond this, human review of consolidation becomes the bottleneck (see `isolation-rules.md`).
- **One agent per worktree**, with no sharing — agent count always matches worktree count.

## Prompt structure

Each dispatched agent receives a self-contained prompt. The prompt **MUST** carry every piece of context the agent needs, because the agent has no access to the parent conversation.

### Template

```
You are implementing subsystem "{subsystem-id}" in an isolated git worktree.

## Context
- Worktree path: ../worktrees/{subsystem-id}
- Branch: parallel/{subsystem-id}
- Requirements: docs/subsystems/{subsystem-id}/{name}-requirements.md
- Design: docs/subsystems/{subsystem-id}/{name}-design.md

## Task
1. cd to the worktree path above.
2. Follow the `spec-coexist:implementing-from-spec` skill to implement
   the subsystem according to requirements and design.
3. Run `spec-coexist:test-driven-implementation` — RED phase first,
   then GREEN.
4. Run `spec-coexist:verification-before-completion` and record evidence
   in `.spec-coexist/evidence/{subsystem-id}/`.
5. Commit all changes on branch parallel/{subsystem-id}.

## Constraints
- Do NOT modify files outside docs/subsystems/{subsystem-id}/ and
  src/{subsystem-path}/ (or the equivalent source directory).
- Do NOT touch docs/main-*.md or root config files.
- Do NOT merge back — the parent agent handles consolidation.
- Do NOT invoke any superpowers:* skill.

## Deliverable
When done, report:
- Commit SHA of your final commit
- Test results (pass count, fail count)
- Evidence file paths created
- Any blockers or deviations from the design
```

### Customization Points

| Field | Source |
|---|---|
| `{subsystem-id}` | From the independent set selected in step 3 of the parent skill |
| `{name}` | Directory name suffix after the numeric prefix (e.g., `payment` from `03_payment`) |
| `{subsystem-path}` | Read from the design document's `Source-root:` frontmatter, or infer from project layout |

## Dispatch method

Use the `Agent` tool with these parameters:

```
Agent({
  description: "Implement {subsystem-id}",
  prompt: <the template above, filled in>,
  isolation: "worktree"   // if the platform supports it; otherwise use pre-created worktree
})
```

When the platform's Agent tool supports `isolation: "worktree"`, it would create a worktree of its own — but this skill's `make_worktree.sh` has already done so with the correct branch naming. Prefer the pre-created worktree by **omitting** `isolation` and instructing the agent to `cd` into the worktree path.

Launch all agents in a **single message** with multiple Agent tool calls so they run concurrently.

## Result aggregation

Once all agents finish, the parent collects results into a structured report:

```markdown
## Parallel Implementation Results

| Subsystem | Status | Commit SHA | Tests | Evidence |
|---|---|---|---|---|
| {id} | success/failed/partial | abc1234 | 12 pass, 0 fail | .spec-coexist/evidence/{id}/ |
| ... | ... | ... | ... | ... |

### Blockers
- {id}: {description of blocker, if any}

### Next Step
- All success → proceed to consolidation (step 7)
- Any failed → invoke partial-failure playbook (references/partial-failure.md)
```

## Runtime conflict detection

After dispatch completes but **before** consolidation, run:

```bash
_shared/scripts/detect_worktree_conflicts.sh
```

If it reports overlapping files, the isolation check had a false negative. **HALT** and record the conflict before attempting any merge.
