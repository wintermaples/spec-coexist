# Suite Independence

Every skill in this suite is self-contained. Each skill **MUST NOT** invoke, delegate to, or otherwise depend on any `superpowers:*` skill at runtime.

This includes `spec-coexist-router` itself, which plays the same role as `superpowers:using-superpowers` but is fully independent of it.

## Why

The `superpowers:*` package is an external dependency. Coupling this suite to it means behavior can change when that package is updated, and the suite cannot be deployed to a project that does not have `superpowers:*` installed.

Each spec-coexist skill therefore embeds the equivalent behavior directly. If you find yourself thinking "I should call `superpowers:brainstorming`", stop — the equivalent flow is embedded inside the relevant spec-coexist skill.
