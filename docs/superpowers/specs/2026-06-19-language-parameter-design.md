# Design: Language Parameter for Game of Future

**Date:** 2026-06-19  
**Status:** approved

## Summary

Add `language` as an optional session input parameter. Default is inferred from
the topic text. The user may override it explicitly. When set, all
facilitator-generated content — briefing, player prompts, guard, player
profiles, adjudication, pitches, and report — is written in the session
language. The `game-of-future:report` skill reads the language from the
standardised `Language:` field in `session.md` and renders all fixed text
(section labels, badges, intro text, footer) in that language.

## Files Changed

- `skills/game-of-future/SKILL.md` — Required Input section
- `skills/game-of-future/assets/session-template/session.md` — header + locked guard section
- `skills/game-of-future/references/facilitation.md` — new Session Language section
- `skills/game-of-future:report/SKILL.md` — Language Rule: read from `Language:` field; strengthen to explicitly cover all fixed strings

## Design

### 1. Input Contract (SKILL.md)

Add `language` to the accepted optional parameters in Required Input:

> `language` — the language for all session content. Default: inferred from the
> topic text (e.g., a Russian-language topic → Russian game). The user may
> specify any language explicitly to override detection.

The defaults list already includes other optional parameters (control mode,
research policy, roster constraints). Language is added alongside them.

### 2. Session Artifact (session.md template)

Add one header line:

```
- Language: {{LANGUAGE}}
```

Add a new section at the end of the template:

```markdown
## Locked Player Turn Guard

{{PLAYER_TURN_GUARD}}
```

The setup step fills `{{LANGUAGE}}` and `{{PLAYER_TURN_GUARD}}` when
instantiating the session. All subsequent turns source the guard text from this
section rather than from the English template in facilitation.md.

### 3. Facilitation Rules (facilitation.md)

Add a new "Session Language" section after the "Facilitator Tooling" section,
with four rules:

**Rule 1 — Determine language at setup.**  
Use the user-supplied `language` override if provided; otherwise infer from the
topic text. Record the result as `Language:` in `session.md`.

**Rule 2 — Lock the guard at setup.**  
Translate the Player Turn Guard into the session language exactly once. Record
the translation in the `Locked Player Turn Guard` section of `session.md`.  
For all subsequent turns, prepend only this recorded text as the guard — do not
re-translate and do not use the English template. The verbatim requirement
applies to the locked translation, not to the English source.

**Rule 3 — All facilitator content in session language.**  
Write the briefing, all player prompts, cliché adjudication, team coordination
turns, presentation turns, clarification turns, and the final report in the
session language.

**Rule 4 — Player profiles in session language.**  
When delivering a player profile in the start prompt, translate it into the
session language.

### 4. Report Skill (game-of-future:report/SKILL.md)

The report skill already has a Language Rule (Step 3) but it uses a `Язык` /
`Language` ad-hoc detection and falls back to the topic text. With `Language:`
now guaranteed in every session.md, update the rule to:

**Read cleanly from the field.** Replace the `Язык` / `Language` / topic-text
fallback chain with a single read of the `Language:` field from `session.md`.

**Treat Section Content Instructions as English templates, not literals.**
Every string in the Section Content Instructions that is not sourced from a
session artifact (topic, player names, forecast text, vote counts, etc.) is an
English-language placeholder. All such text must be rendered in the session
language. No separate enumeration is maintained here — the Section Content
Instructions are the authoritative source, and the language rule applies to
everything in them that is not session data.

## Non-Goals

- Multilingual sessions (different players in different languages) — not in scope.
- Translating artifact file names or directory slugs — paths remain ASCII.
- Per-phase language switching — language is fixed for the session.

## Error Handling

No new pause conditions. Language detection from the topic text is best-effort;
if the topic is ambiguous or mixed-language, the facilitator picks the dominant
language and records the decision in the Facilitator Ledger in `session.md`.
