# Target Path Resolution — creating-requirements

## Whole-system

Target: `docs/main-requirements.md`

1. Run `check_doc_exists.sh docs/main-requirements.md`.
2. If the file exists **and has non-trivial content**, halt (see `constraints.md` §1).
3. If the file does not exist, create an empty placeholder so subsequent steps have a stable target.

## Subsystem

Target: `<subsystem-dir>/<name>-requirements.md`

Subsystems may be **top-level** (directly under `docs/subsystems/`) or **nested** (under an existing subsystem's `subsystems/` folder, e.g. `docs/subsystems/001_common-platform/subsystems/001_notification/`).

1. Ask the user which kind of subsystem:
   - **Existing subsystem** → enumerate all subsystem directories recursively (`find docs/subsystems -mindepth 1 -type d` filtered to `{id}_{name}` pattern) and let the user pick; the path is already set.
   - **New top-level subsystem** → run `ensure_subsystem_dir.sh <name>`; capture the printed path.
   - **New child subsystem of an existing subsystem** → first let the user pick the parent subsystem from the enumerated list, then run `ensure_subsystem_dir.sh <name> <parent-subsystem-path>`; capture the printed path.
2. Derive the target file: `<dir>/<name>-requirements.md`.
3. Run `check_doc_exists.sh <target>`.
4. If the target exists, halt (see `constraints.md` §1).

### Template `extends` path computation

The `{{EXTENDS_PATH}}` placeholder in the subsystem-requirements template **MUST** be resolved as follows:

- **Top-level subsystem** (parent is `docs`): `../../main-requirements.md`
- **Child subsystem** (parent is another subsystem): relative path to the parent subsystem's requirements document. For example, if the child is at `docs/subsystems/001_common/subsystems/001_notification/`, the `extends` path is `../../common-requirements.md` (pointing to `docs/subsystems/001_common/common-requirements.md`).

The `extends` chain forms a hierarchy: child → parent → ... → main.

## Examples

| Scenario | Command | Resulting target |
| --- | --- | --- |
| New whole-system doc | *(no script needed)* | `docs/main-requirements.md` |
| New subsystem "billing" | `ensure_subsystem_dir.sh billing` → `docs/subsystems/001_billing/` | `docs/subsystems/001_billing/billing-requirements.md` |
| Existing subsystem id 003 "auth" | *(pick from list)* | `docs/subsystems/003_auth/auth-requirements.md` |
| New child "notification" under "common-platform" | `ensure_subsystem_dir.sh notification docs/subsystems/001_common-platform` → `docs/subsystems/001_common-platform/subsystems/001_notification/` | `docs/subsystems/001_common-platform/subsystems/001_notification/notification-requirements.md` |
