# Design: Game of Future — Report Sub-Skill (`/game-of-future:report`)

- Date: 2026-06-17
- Status: approved
- Author: brainstorming session with Alex

---

## Overview

A new sub-skill of `game-of-future` that reads a completed session's artifact
folder and generates a single self-contained HTML file — a shareable,
editorial-style presentation of the game's results. The primary audience is
people who were not in the session; the primary purpose is sharing the products
the game produced.

---

## Invocation

```
/game-of-future:report [session-id-or-filter]
```

Lives at:

```
~/.claude/skills/game-of-future/skills/report/SKILL.md
```

This is the same sub-skill pattern used by `superpowers:brainstorming`,
`superpowers:writing-plans`, etc. The main `game-of-future` SKILL.md is
**not modified**.

---

## Session Selection

Resolution happens in strict priority order:

### 1. Explicit session ID or path supplied

Use it directly. No scanning, no list. Show the one-line confirmation
(topic + timestamp) and proceed on approval.

### 2. Natural-language filter or no argument

**First, count sessions** in `game-of-future/sessions/`. If more than 100,
stop and ask the user to supply a more specific session ID or term. Do not
scan all folders.

If 100 or fewer: scan **only** the folder name (encodes timestamp + topic
slug) and **the topic field in the first ~20 lines of `session.md`**. No
other files read during filtering. This keeps filtering cost minimal
regardless of how large the session artifacts are.

Completion check: look for `Phase 9 — Complete` in the first 20 lines of
`session.md`. Only completed sessions are eligible.

**Filter supplied:** present only matching sessions as a numbered list.
**No filter:** present all completed sessions, newest-first, numbered.

User picks by number.

### 3. Confirmation step

Before generating, always show one line:

> Generating report for: *[topic]* ([session-id]) — ok?

This applies in all cases, including when a session ID was supplied explicitly.
The confirmation costs nothing and prevents generating a report for the wrong session.

---

## Artifact Reading Order

Claude reads these files in order, in a single context pass before writing
any HTML:

1. `session.md` — topic, date, player count, team count, parameters
2. `briefing.md` — facts, observed trends (not facilitator inference)
3. `public-room.md` — accepted cliché list, dissented items, team pitches
4. `roster.md` — player names, profile labels, team assignments
5. `report.md` — forecast summaries, product specs, vote totals, facilitator
   analysis

The individual `forecasts/*.md` and `teams/*.md` files are **not** read
directly — `report.md` already contains curated summaries of all of them.
If `report.md` is absent or incomplete, fall back to reading `forecasts/*.md`
and `teams/*.md` directly and inform the user in the response.

---

## Output

A single file written to the session folder:

```
game-of-future/sessions/<session-id>/report.html
```

After writing, open the file in the default browser:
- macOS: `open report.html`
- Linux: `xdg-open report.html`

The file must be fully self-contained: all CSS in a `<style>` block in
`<head>`, no external stylesheets, no external scripts, no web fonts, no
network-fetched images. Must render correctly when opened from a local
filesystem with no network connection.

---

## HTML Document Structure

Sections appear in this order. Every section has a matching `id` attribute on
its root element for anchor links and CSS targeting. All class names follow
BEM convention under the `.gof-` namespace so a designer can identify and
restyle any block without reading the generation logic.

### 1. Hero `id="hero"`

- Classes: `.gof-hero`
- Content: game topic as `<h1>`, subtitle `"A Game of Future session · [date]"`,
  one-sentence explainer of what Game of Future is
- Visual: full-width, large type, centred or left-aligned

### 2. The Brief `id="brief"`

- Classes: `.gof-brief`, `.gof-brief__facts`, `.gof-brief__context`
- Content: two-column layout. Left: key facts and observed trends from
  `briefing.md` as a `<ul>`. Right: a short "why this topic now" editorial
  paragraph Claude writes from the briefing material.
- Facilitator inference is **excluded** from this section (belongs to the
  facilitator's take, not the setup)

### 3. The Clichés `id="cliches"`

- Classes: `.gof-cliches`, `.gof-cliches__intro`, `.gof-cliches__list`,
  `.gof-cliches__item`, `.gof-cliches__item--dissented`,
  `.gof-cliches__dissent-note`
- Content: intro sentence ("These are the obvious futures the game discards"),
  numbered list of accepted clichés, a separate note naming the dissented
  items ("Six ideas were too interesting to dismiss and became forecast
  territory instead")
- Visual: de-emphasised — secondary grey text, smaller type than body,
  no bold or accent colour

### 4. The Forecasts `id="forecasts"`

- Classes: `.gof-forecasts`, `.gof-forecasts__intro`, `.gof-forecasts__grid`,
  `.gof-forecast-card`, `.gof-forecast-card__player-name`,
  `.gof-forecast-card__profile`, `.gof-forecast-card__team`,
  `.gof-forecast-card__summary`
- Content: 12 player cards in a CSS grid. Each card: player display name,
  one-line profile label (e.g. "skeptical economist"), team assignment
  (small, secondary), 2–3 sentence distillation of their forecast.
  Claude writes the distillation — not verbatim quote, not the full text.
- Layout: 3-across on wide, 2-across on tablet, 1-across on mobile

### 5. The Products `id="products"` ← primary section

- Classes: `.gof-products`, `.gof-products__intro`, `.gof-products__grid`,
  `.gof-product-card`, `.gof-product-card--winner`,
  `.gof-product-card__badge` (winner badge),
  `.gof-product-card__team-label`,
  `.gof-product-card__name`,
  `.gof-product-card__core-idea`,
  `.gof-product-card__buyer`,
  `.gof-product-card__intersection`,
  `.gof-product-card__votes`
- Content: four team product cards. Each card:
  - Product name as `<h3>`
  - Core idea: 2–3 sentences — Claude distills from the product spec and
    team pitch, not copied verbatim from either source
  - Target buyer: one line, labelled "For:"
  - Intersection sentence: one sentence on why the product only works when
    both forecasts combine, labelled "Why it works:" — distilled from the
    intersection test in `report.md`
  - Vote count: shown as `"N votes"`, small
  - Team label: small, secondary (e.g. "Team Alpha")
- Winner card: `.gof-product-card--winner` class, left border in accent
  colour, `WINNER` badge (`.gof-product-card__badge`) top-right
- Layout: 2-across on wide, 1-across on mobile. Cards are visually larger
  than forecast cards.

### 6. The Vote `id="vote"`

- Classes: `.gof-vote`, `.gof-vote__intro`, `.gof-vote__tally`,
  `.gof-vote__tally-row`, `.gof-vote__tally-row--winner`,
  `.gof-vote__bar`, `.gof-vote__label`, `.gof-vote__count`,
  `.gof-vote__rules`
- Content: vote tally as horizontal bar rows (CSS only, no JS/SVG),
  winner row distinguished, rules note ("12 players · 2 votes each · no
  self-voting")

### 7. Facilitator's Take `id="facilitators-take"`

- Classes: `.gof-facilitator`, `.gof-facilitator__intro`,
  `.gof-facilitator__body`
- Content: condensed editorial prose from the non-binding facilitator
  analysis in `report.md`. Claude selects the 3–4 most interesting
  observations and rewrites them as flowing prose (not headers, not
  bullets). Target: ~250 words. Explicitly labelled as non-binding
  facilitator commentary, not player output.

### 8. Footer `id="footer"`

- Classes: `.gof-footer`
- Content: session ID, timestamp, "Generated by Game of Future."

---

## Visual Style

### Typography

```css
font-family (headings): Georgia, 'Times New Roman', serif
font-family (body):     -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif
```

No external font loads. Renders offline.

### Palette

| Role | Value |
|---|---|
| Page background | `#faf9f7` |
| Body text | `#1a1a1a` |
| Secondary / de-emphasised text | `#6b6b6b` |
| Accent (winner, rules, links) | `#1a5f6a` |
| Card background | `#ffffff` |
| Card border | `#e8e4de` |
| Winner card border | `#1a5f6a` |

### Layout

- Max content width: 860px, centred, `margin: 0 auto`
- Generous vertical rhythm: sections separated by substantial whitespace
- Forecast grid: `grid-template-columns: repeat(3, 1fr)` → 2 → 1
- Product grid: `grid-template-columns: repeat(2, 1fr)` → 1
- All layout via CSS Grid, no flexbox hacks, no JS

### Self-Contained Constraint

- All CSS in one `<style>` block in `<head>`
- No `<link rel="stylesheet">`
- No `<script src="">`
- No web fonts (`@import`, `@font-face` with remote URLs)
- No `<img src="">` pointing to remote URLs
- File must open and render correctly from `file://` with no network

---

## Naming and Semantics Requirement

The SKILL.md must instruct Claude explicitly:

> Use semantic HTML5 elements throughout: `<article>` for the document body,
> `<section>` for each named section, `<header>` for the hero, `<footer>`
> for the footer, `<aside>` for secondary callouts. Every section root must
> have an `id` attribute matching its section name exactly as listed in this
> spec. Every meaningful block and element must have a BEM-style class name
> under the `.gof-` namespace. Class names must be descriptive enough that a
> designer unfamiliar with the generation process can identify any element
> by reading the HTML alone.

---

## Skill File Location Summary

```
~/.claude/skills/game-of-future/
  SKILL.md                      ← unchanged
  skills/
    report/
      SKILL.md                  ← new sub-skill (this spec)
```

---

## Out of Scope

- No editing or regenerating partial sections
- No multiple output formats (PDF, Markdown)
- No live-preview or watch mode
- No automatic regeneration when session artifacts change
- No inclusion of raw divergence/convergence round transcripts (those live
  in team files; the HTML is a presentation, not a transcript)
