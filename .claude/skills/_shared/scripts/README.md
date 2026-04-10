# _shared/scripts — Cross-Platform Support

All helpers here are POSIX shell scripts (`*.sh`). A thin Python wrapper (`run.py`) exists so skills running on Windows can invoke them without shell-specific branching in each SKILL.md.

## OS support matrix

| OS / shell | `*.sh` direct | `python run.py <name>` | Notes |
|---|---|---|---|
| Linux (bash / zsh / dash) | ✅ | ✅ | canonical target |
| macOS (zsh, bash) | ✅ | ✅ | canonical target |
| Windows — Git Bash | ✅ | ✅ | `run.py` auto-detects `bash` on PATH |
| Windows — WSL | ✅ | ✅ | `run.py` falls back to `wsl bash` |
| Windows — cmd / PowerShell, no Git Bash, no WSL | ❌ | ❌ (exits 127 with remediation hint) | install Git for Windows or WSL |

## Dependencies

- `run.py` targets Python **≥ 3.8** (only stdlib). Any modern Python 3 on the user's machine is sufficient.
- The wrapped scripts assume `git` is on PATH where relevant (e.g. `subsystem_deps.sh`, `make_worktree.sh`, `cleanup_worktree.sh`).

## Calling convention from a SKILL.md

Skills **SHOULD** reference helpers by bare name so the user can pick their entry point:

> Invoke `subsystem_deps.sh` — on Windows without Git Bash, use `python run.py subsystem_deps`.

Skills **SHOULD NOT** hardcode the `./subsystem_deps.sh` form inside step text; that breaks Windows without warning. Any invocation example **MUST** either:

- use the bare script name and defer to this README, or
- show both `./foo.sh` and `python run.py foo` side by side.

## Scripts currently shipped

| Script | Purpose |
|---|---|
| `check_doc_exists.sh` | Halt signal if a target doc already exists. |
| `check_doc_links.sh` | Validate frontmatter refs, body Markdown links, and doc lifecycle rules against `_shared/references/doc-reference-syntax.md`. Flags: `--root <dir>` (default `docs`), `--strict`, `--json`. Exit 1 on errors. |
| `ensure_subsystem_dir.sh` | Allocate a subsystem id and create its dir. |
| `gen_questions_path.sh` | Path for the questions file used by brainstorming. |
| `next_subsystem_id.sh` | Print the next 3-digit subsystem id. |
| `record_test_failure.sh` | Capture RED-phase test output as evidence. |
| `subsystem_deps.sh` | Dump the subsystem dependency edge list. |
| `make_worktree.sh` | Create an isolated worktree + branch. |
| `cleanup_worktree.sh` | Remove a worktree + branch with safety checks. |
| `detect_worktree_conflicts.sh` | Detect file-level conflicts between active parallel worktrees. Exit 0 = clean, exit 1 = conflicts. |
| `write_evidence.sh` | Append a verification or post-merge evidence record. |
| `visual_server.py`, `start_visual_server.sh`, `stop_visual_server.sh` | Visual Companion helpers. |

## Hook automation (proposal)

A staged proposal for wiring these scripts into `.claude/settings.json` hooks lives at `../references/hook-automation-proposal.md` — **proposal only, requires explicit user approval before enablement**.

## Why not rewrite everything in Python?

The scripts are small and side-effect heavy. Rewriting in Python would trade a 30-line shell script for a 60-line Python module that still has to shell out to `git`. The wrapper approach keeps the canonical implementation readable on the platforms the suite was designed for while unblocking Windows users who cannot install Git Bash yet.
