# _shared/scripts — Cross-Platform Support

All helpers in this directory are POSIX shell scripts (`*.sh`). A thin Python wrapper (`run.py`) lets skills running on Windows invoke them without adding shell-specific branching to each SKILL.md.

## OS support matrix

| OS / shell | `*.sh` direct | `python run.py <name>` | Notes |
|---|---|---|---|
| Linux (bash / zsh / dash) | ✅ | ✅ | canonical target |
| macOS (zsh, bash) | ✅ | ✅ | canonical target |
| Windows — Git Bash | ✅ | ✅ | `run.py` auto-detects `bash` on PATH |
| Windows — WSL | ✅ | ✅ | `run.py` falls back to `wsl bash` |
| Windows — cmd / PowerShell, no Git Bash, no WSL | ❌ | ❌ (exits 127 with remediation hint) | install Git for Windows or WSL |

## Dependencies

- `run.py` targets Python **≥ 3.8** and uses only the standard library. Any modern Python 3 on the user's machine is sufficient.
- The wrapped scripts assume `git` is on PATH where relevant (for example, `subsystem_deps.sh`, `make_worktree.sh`, `cleanup_worktree.sh`).

## Calling convention from a SKILL.md

Skills **SHOULD** reference helpers by bare name so the user can choose their preferred entry point:

> Invoke `subsystem_deps.sh` — on Windows without Git Bash, use `python run.py subsystem_deps`.

Skills **SHOULD NOT** hard-code the `./subsystem_deps.sh` form inside step text, since that silently breaks Windows. Any invocation example **MUST** either:

- use the bare script name and defer to this README, or
- show both `./foo.sh` and `python run.py foo` side by side.

## Scripts currently shipped

| Script | Purpose |
|---|---|
| `build_traceability_matrix.sh` | Generate the REQ-ID → DES-ID → test-ID → code traceability matrix; consumed by `delivery-snapshot`. |
| `check_doc_exists.sh` | Halt signal if a target doc already exists. |
| `check_doc_links.sh` | Validate frontmatter refs, body Markdown links, and doc lifecycle rules against `_shared/references/doc-reference-syntax.md`. Flags: `--root <dir>` (default `docs`), `--strict`, `--json`. Exit 1 on errors. |
| `check_doc_links.py` | Python implementation of the doc-link checker. Invoked by `check_doc_links.sh`; not normally called directly. |
| `cleanup_worktree.sh` | Remove a worktree + branch with safety checks. |
| `detect_worktree_conflicts.sh` | Detect file-level conflicts between active parallel worktrees. Exit 0 = clean, exit 1 = conflicts. |
| `ensure_subsystem_dir.sh` | Allocate a subsystem id and create its dir. |
| `gen_questions_path.sh` | Path for the questions file used by brainstorming. |
| `make_worktree.sh` | Create an isolated worktree + branch. |
| `next_subsystem_id.sh` | Print the next 3-digit subsystem id. |
| `pre-commit.sh` | Pre-commit hook entry point (doc-link check, evidence schema, traceability). |
| `qualify_subsystem_id.sh` | Resolve a subsystem id (e.g. `01`) to its fully qualified path (e.g. `01_auth`). |
| `record_test_failure.sh` | Capture RED-phase test output as evidence. |
| `resolve_subsystem_path.sh` | Resolve an arbitrary subsystem reference to its on-disk path. |
| `run.py` | Cross-platform Python wrapper that invokes any sibling `*.sh` script via `bash`/`sh`/`wsl bash`/Git Bash. See the OS support matrix above. |
| `start_visual_server.sh`, `stop_visual_server.sh`, `visual_server.py` | Visual Companion helpers (lightweight HTTP server, Python stdlib only). |
| `subsystem_deps.sh` | Dump the subsystem dependency edge list. |
| `validate_evidence.sh` | Validate an evidence file against the JSON schema in `_shared/schemas/`. |
| `verify_evidence.sh` | Verify that the evidence set for a task is complete (no missing required artifacts). |
| `verify_traceability.sh` | Verify the REQ-ID → DES-ID → test-ID → code chain has no gaps. |
| `write_evidence.sh` | Append a verification or post-merge evidence record (shell-friendly form). |
| `write_evidence_json.sh` | Same as `write_evidence.sh` but emits structured JSON for programmatic consumers. |

## Hook automation (proposal)

A staged proposal for wiring these scripts into `.claude/settings.json` hooks lives at `../references/hook-automation-proposal.md`. **Proposal only — explicit user approval is required before enablement.**

## Why not rewrite everything in Python?

The scripts are small and side-effect heavy. A Python rewrite would trade a 30-line shell script for a 60-line Python module that still has to shell out to `git`. The wrapper approach keeps the canonical implementation readable on the suite's primary platforms while still unblocking Windows users who cannot install Git Bash yet.
