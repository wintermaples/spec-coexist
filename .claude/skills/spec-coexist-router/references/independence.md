# Suite Independence

Every skill in this suite is self-contained. Each skill **MUST NOT** invoke, delegate to, or otherwise depend on any `superpowers:*` skill at runtime.

This applies to `spec-coexist-router` itself: it plays the same role as `superpowers:using-superpowers`, but is fully independent of it.

## Why

The `superpowers:*` package is an external dependency. Coupling this suite to it would have two consequences:

- behavior could change when that package is updated;
- the suite could not be deployed to a project that does not have `superpowers:*` installed.

Each spec-coexist skill therefore embeds the equivalent behavior directly. If you find yourself thinking "I should call `superpowers:brainstorming`", stop — the equivalent flow is already embedded in the relevant spec-coexist skill.
