# Shared Templates — Locale Resolution

The `spec-coexist` suite's document templates are **locale-aware**. Every skill that writes a requirements or basic-design document **MUST** resolve the locale as its first content step, before reading any template.

## Supported locales

| Locale | Canonical templates | Status |
|---|---|---|
| `ja` | `creating-requirements/references/*-template.md`, `creating-basic-design/references/*-template.md` | Primary, battle-tested. |
| `en` | `_shared/templates/en/*.md` | Secondary, seeded as direct translations of `ja` with `TODO:` markers. Refine during use. |

The physical location difference is historical: `ja` templates live next to the skills that first used them; `en` templates are centralized under `_shared/templates/en/` so new locales can be added without touching each skill. A future consolidation **MAY** move `ja` under `_shared/templates/ja/` — until then, treat the table above as authoritative.

## Resolution procedure

A skill resolving the locale **MUST** follow these steps in order and stop at the first match:

1. **Explicit override.** If the user's message contains `locale: ja`, `locale: en`, "in English", "日本語で", or a similar explicit instruction, honor it.
2. **Existing document language.** If a document already exists at the target path (e.g. `docs/main-requirements.md`), detect its primary language and match it. Do not mix locales inside one document.
3. **Conversation language.** Detect the language of the user's most recent non-command message. CJK characters → `ja`. Otherwise → `en`.
4. **Default.** `ja`. The suite's design center is Japanese spec culture.

The resolved locale **MUST** be recorded in the skill's final `Review:` line as `locale=<ja|en>`.

## How a skill loads a template

```
if locale == "ja":
    template = "<skill>/references/{kind}-template.md"       # in place
    rules    = "<skill>/references/{kind}-template-rules.md"
else:
    template = "_shared/templates/en/{kind}.md"
    rules    = "_shared/templates/en/{kind}-rules.md"        # optional for en
```

If the `en` template is missing a section that the `ja` template has, the skill **MUST** fall back to translating the `ja` section on the fly and add a `TODO(en):` marker so the next author can upstream it.

## Adding a new locale

1. Create `_shared/templates/{locale}/` with the four files: `main-requirements.md`, `subsystem-requirements.md`, `main-basic-design.md`, `subsystem-basic-design.md`.
2. Add a row to the table above.
3. Add trigger-test cases exercising a greeting in the new locale and verify the resolver picks it.
4. Leave `TODO(i18n):` markers liberally — direct translation is acceptable v1 per the Phase 4 plan.

## Non-goals

- Automatic machine translation inside skills.
- Bi-directional sync between locales — documents are authored once per project, in one locale.
- Locale negotiation mid-document.
