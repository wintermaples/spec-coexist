# Folder Structure Guidelines

Detailed design documents are organized as a **folder of multiple files** rather than a single monolithic file. This keeps each file focused, prevents unmanageable length, and allows parallel work across modules.

## Recommended Layout

### Whole-System

```
docs/main-detail-design/
├── index.md              # Overview, module index, cross-cutting concerns
├── {module-name}.md       # Per-module detailed design (one file per module)
├── {module-name-2}.md
└── shared-patterns.md     # Optional: cross-cutting patterns used by multiple modules
```

### Subsystem

```
docs/subsystems/{id}_{name}/detail-design/
├── index.md              # Overview, module index, cross-cutting concerns
├── {module-name}.md       # Per-module detailed design
├── {module-name-2}.md
└── shared-patterns.md     # Optional
```

### Nested Subsystem

```
docs/subsystems/{parent_id}_{parent}/subsystems/{id}_{name}/detail-design/
├── index.md
├── {module-name}.md
└── ...
```

## Naming Rules

- **index.md** — always the entry point. Contains the module index table and cross-cutting concerns.
- **Module files** — named after the module in kebab-case: `user-authentication.md`, `payment-processing.md`, `data-export.md`.
- **shared-patterns.md** — optional, for patterns referenced by ≥2 module files. Only create if actual sharing exists; do not speculatively create.

## How to Determine Modules

Extract modules from the basic design's functional decomposition:

1. Read §4 アプリケーション機能設計 (or §2 Structure in EN templates) from the basic design.
2. Group related functions by cohesion — those that share data, collaborate closely, or serve the same user workflow.
3. Each group becomes one module file.
4. Aim for 3–10 module files per subsystem. Fewer than 3 suggests the design is too coarse; more than 10 suggests over-decomposition.

## When a Single File is Acceptable

If the subsystem is small (≤3 functions, ≤1 screen, no batch processing), the entire detailed design **MAY** be written in a single `index.md` with inline module sections instead of separate files. The folder structure is still used (a `detail-design/` directory with `index.md`), but no separate module files are needed.

## Cross-References

- `index.md` **MUST** link to every module file in its module index table.
- Module files **SHOULD** link back to `index.md` and to related module files when describing inter-module interactions.
- All links use relative Markdown paths per `_shared/references/doc-reference-syntax.md`.
