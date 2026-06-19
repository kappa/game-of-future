# Language Parameter Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add `language` as an optional session parameter that defaults to the
language detected from the topic text and propagates through all facilitator
content, the player turn guard, and the HTML report.

**Architecture:** Four independent Markdown edits — one per file — each
self-contained and independently verifiable. No code, no dependencies between
tasks, no shared state beyond the spec.

**Tech Stack:** Plain Markdown, Edit tool, grep for verification.

## Global Constraints

- All edits are in `skills/` relative to the repo root
  (`/home/kappa/work/game-of-future`).
- Do not reformat, reorder, or rephrase any existing content outside the
  specific insertion/replacement points shown in each task.
- Verify with grep before and after each edit.
- One commit per task.

---

### Task 1: Add `language` to Required Input (SKILL.md)

**Files:**
- Modify: `skills/game-of-future/SKILL.md` lines 19–32

**Interfaces:**
- Produces: `language` parameter definition consumed by Tasks 3 and 4 at
  runtime (not a code interface — establishing the documented contract).

- [ ] **Step 1: Verify current state**

```bash
grep -n "language\|research policy" skills/game-of-future/SKILL.md
```

Expected output — two matching lines, no `language` in the defaults list:
```
22:and research policy.
```

- [ ] **Step 2: Edit Required Input section**

In `skills/game-of-future/SKILL.md`, replace:

```
Require a user-supplied topic. Accept optional roster constraints, control mode,
and research policy.

Use these defaults when omitted:

- 12 players in four teams of three
- autonomous mode
- shared briefing
- no independent player research
- two votes per player for other teams
```

with:

```
Require a user-supplied topic. Accept optional roster constraints, control mode,
research policy, and language.

Use these defaults when omitted:

- 12 players in four teams of three
- autonomous mode
- shared briefing
- no independent player research
- two votes per player for other teams
- language: detected from the topic text
```

- [ ] **Step 3: Verify edit**

```bash
grep -n "language" skills/game-of-future/SKILL.md
```

Expected output:
```
22:research policy, and language.
31:- language: detected from the topic text
```

- [ ] **Step 4: Commit**

```bash
git add skills/game-of-future/SKILL.md
git commit -m "feat: add language to Required Input defaults"
```

---

### Task 2: Add Language header and Locked Guard section (session.md template)

**Files:**
- Modify: `skills/game-of-future/assets/session-template/session.md`

**Interfaces:**
- Produces: `Language: {{LANGUAGE}}` field (read by the report skill at
  runtime) and `## Locked Player Turn Guard` section (written by setup,
  read by every subsequent facilitator turn).

- [ ] **Step 1: Verify current state**

```bash
grep -n "Language\|LANGUAGE\|Guard\|GUARD" skills/game-of-future/assets/session-template/session.md
```

Expected output: no matches.

- [ ] **Step 2: Add Language header line**

In `skills/game-of-future/assets/session-template/session.md`, replace:

```
- Team count: {{TEAM_COUNT}}
- Current phase: setup
```

with:

```
- Team count: {{TEAM_COUNT}}
- Language: {{LANGUAGE}}
- Current phase: setup
```

- [ ] **Step 3: Add Locked Player Turn Guard section**

In the same file, append after the last line of the Completion Checklist
(after `- [ ] All provider sessions closed after reporting`):

```
## Locked Player Turn Guard

{{PLAYER_TURN_GUARD}}
```

- [ ] **Step 4: Verify edit**

```bash
grep -n "Language\|LANGUAGE\|Guard\|PLAYER_TURN_GUARD" skills/game-of-future/assets/session-template/session.md
```

Expected output:
```
7:- Language: {{LANGUAGE}}
31:## Locked Player Turn Guard
33:{{PLAYER_TURN_GUARD}}
```

(Line numbers may differ slightly; content must match exactly.)

- [ ] **Step 5: Commit**

```bash
git add skills/game-of-future/assets/session-template/session.md
git commit -m "feat: add Language field and Locked Player Turn Guard to session template"
```

---

### Task 3: Add Session Language section (facilitation.md)

**Files:**
- Modify: `skills/game-of-future/references/facilitation.md`

**Interfaces:**
- Produces: four language rules (detection, guard locking, content language,
  profile translation) that govern facilitator behaviour at runtime.

- [ ] **Step 1: Verify current state**

```bash
grep -n "Session Language\|Determine language\|Lock the guard" skills/game-of-future/references/facilitation.md
```

Expected output: no matches.

- [ ] **Step 2: Insert Session Language section**

In `skills/game-of-future/references/facilitation.md`, replace:

```
- Everything else: standard unix utils via Bash

## Bash Command Rules (non-negotiable)
```

with:

```
- Everything else: standard unix utils via Bash

## Session Language

**Determine language at setup.** Use the user-supplied `language` parameter if
provided; otherwise infer the language from the topic text. Record the result
as the `Language:` field in `session.md`.

**Lock the guard at setup.** Translate the Player Turn Guard into the session
language exactly once. Record the translation verbatim in the `Locked Player
Turn Guard` section of `session.md`. For every subsequent turn, prepend only
this recorded text as the guard — do not re-translate it and do not use the
English source below. The verbatim requirement applies to the locked
translation, not to the English source.

**All facilitator content in session language.** Write the briefing, all player
prompts, cliché adjudication, team coordination turns, presentation turns,
clarification turns, and the final report in the session language.

**Player profiles in session language.** When delivering a player profile in
the start prompt, translate it into the session language.

## Bash Command Rules (non-negotiable)
```

- [ ] **Step 3: Verify edit**

```bash
grep -n "Session Language\|Determine language\|Lock the guard\|All facilitator content\|Player profiles in session" skills/game-of-future/references/facilitation.md
```

Expected output (4 matching lines):
```
23:## Session Language
25:**Determine language at setup.**
31:**Lock the guard at setup.**
38:**All facilitator content in session language.**
43:**Player profiles in session language.**
```

(Line numbers may differ; all five patterns must match.)

- [ ] **Step 4: Commit**

```bash
git add skills/game-of-future/references/facilitation.md
git commit -m "feat: add Session Language section to facilitation rules"
```

---

### Task 4: Update Language Rule in report skill

**Files:**
- Modify: `skills/game-of-future:report/SKILL.md` lines 109–115

**Interfaces:**
- Consumes: `Language:` field in `session.md` produced by Task 2 at session
  setup time.

- [ ] **Step 1: Verify current state**

```bash
grep -n "Язык\|Language\|topic text" "skills/game-of-future:report/SKILL.md"
```

Expected output — the old ad-hoc detection line:
```
112:session language from `session.md` (the `Язык` / `Language` field or from the
113:topic text). If the session was conducted in Russian, write all section labels,
```

- [ ] **Step 2: Replace Language Rule**

In `skills/game-of-future:report/SKILL.md`, replace:

```
### Language Rule

Generate all text content in the same language as the session. Read the
session language from `session.md` (the `Язык` / `Language` field or from the
topic text). If the session was conducted in Russian, write all section labels,
intro text, badges, and facilitator prose in Russian. If in English, write in
English. Match the output language to the session language without exception.
```

with:

```
### Language Rule

Read the session language from the `Language:` field in `session.md`.

All strings shown in the Section Content Instructions below are English-language
templates. Every string that is not sourced from a session artifact (topic,
player names, forecast text, vote counts, dates, session IDs) must be rendered
in the session language. This covers section labels, intro paragraphs, badges,
inline labels, the hero subtitle and about note, the footer line, and any other
fixed text. Set the `<html lang="">` attribute to the BCP 47 code for the
session language.
```

- [ ] **Step 3: Verify edit**

```bash
grep -n "Язык\|topic text\|Language:\|BCP 47\|Section Content Instructions" "skills/game-of-future:report/SKILL.md"
```

Expected output — old patterns gone, new ones present:
```
112:Read the session language from the `Language:` field in `session.md`.
114:All strings shown in the Section Content Instructions below are English-language
119:session language. Set the `<html lang="">` attribute to the BCP 47 code for the
```

`Язык` and `topic text` must not appear.

- [ ] **Step 4: Commit**

```bash
git add "skills/game-of-future:report/SKILL.md"
git commit -m "feat: update Language Rule to read from Language field and treat templates as translatable"
```
