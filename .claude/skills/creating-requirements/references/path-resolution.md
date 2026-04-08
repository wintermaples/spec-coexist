# Target Path Resolution — creating-requirements

## Whole-system

Target: `docs/main-requirements.md`

1. Run `check_doc_exists.sh docs/main-requirements.md`.
2. If the file exists **and has non-trivial content**, halt (see `constraints.md` §1).
3. If the file does not exist, create an empty placeholder so subsequent steps have a stable target.

## Subsystem

Target: `docs/subsystems/{id}_{name}/{name}-requirements.md`

1. Ask the user whether to use an **existing** subsystem directory or create a **new** one.
   - Existing → enumerate `docs/subsystems/*/` and let the user pick; the id is already set.
   - New → run `ensure_subsystem_dir.sh <name>`; capture the printed path.
2. Derive the target file: `<dir>/<name>-requirements.md`.
3. Run `check_doc_exists.sh <target>`.
4. If the target exists, halt (see `constraints.md` §1).

## Examples

| Scenario | Command | Resulting target |
| --- | --- | --- |
| New whole-system doc | *(no script needed)* | `docs/main-requirements.md` |
| New subsystem "billing" | `ensure_subsystem_dir.sh billing` → `docs/subsystems/001_billing/` | `docs/subsystems/001_billing/billing-requirements.md` |
| Existing subsystem id 003 "auth" | *(pick from list)* | `docs/subsystems/003_auth/auth-requirements.md` |
