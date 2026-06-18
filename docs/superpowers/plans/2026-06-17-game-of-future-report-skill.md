# Game of Future Report Sub-Skill Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create `~/.claude/skills/game-of-future/skills/report/SKILL.md` — a sub-skill that reads completed game session artifacts and writes a polished, self-contained HTML presentation to `report.html` in the session folder.

**Architecture:** A single SKILL.md instruction document that Claude executes when invoked as `/game-of-future:report`. No scripts or external dependencies. Claude reads five session artifact files, synthesises editorial content, and writes one fully self-contained HTML file. The HTML uses semantic elements, BEM-namespaced CSS classes, and a complete inline `<style>` block — no network fetches.

**Tech Stack:** Markdown (SKILL.md), HTML5, inline CSS (no JS, no external resources).

## Global Constraints

- Output file must render correctly from `file://` with no network connection
- All CSS in one `<style>` block — no `<link>`, no `@import url(...)`, no web fonts
- No `<script src="">` or inline JS
- BEM class names under `.gof-` namespace throughout
- Every section root carries an `id` matching its section name exactly
- Semantic HTML5: `<article>`, `<section>`, `<header>`, `<footer>`, `<aside>`
- Skill file lives at `~/.claude/skills/game-of-future/skills/report/SKILL.md`
- Main `game-of-future` SKILL.md is **not modified**
- Palette: bg `#faf9f7`, text `#1a1a1a`, secondary `#6b6b6b`, accent `#1a5f6a`, card bg `#ffffff`, border `#e8e4de`
- Headings: `Georgia, 'Times New Roman', serif`; body: `-apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif`
- Max content width: 860px centred

---

## File Structure

```
~/.claude/skills/game-of-future/
  SKILL.md                          ← UNCHANGED
  skills/
    report/
      SKILL.md                      ← CREATE (sole deliverable of this plan)
```

---

### Task 1: Create directory and write SKILL.md

**Files:**
- Create: `~/.claude/skills/game-of-future/skills/report/SKILL.md`

**Interfaces:**
- Produces: `/game-of-future:report` skill, invocable from any Claude Code session in this repo

- [ ] **Step 1: Create the skills/report directory**

```bash
mkdir -p /home/kappa/.claude/skills/game-of-future/skills/report
```

Expected output: none (directory created silently).

Verify:
```bash
ls /home/kappa/.claude/skills/game-of-future/skills/
```
Expected: `report` directory listed.

- [ ] **Step 2: Write SKILL.md**

Write the complete file below to `/home/kappa/.claude/skills/game-of-future/skills/report/SKILL.md`:

````markdown
---
name: report
description: Generate a self-contained HTML presentation from a completed Game of Future session. Reads session artifacts and writes report.html to the session folder, then opens it in the browser.
---

# Game of Future — Report Generator

Generate a polished, self-contained HTML presentation from a completed Game of
Future session. The output is a single `report.html` file suitable for sharing
with people who were not in the session.

## Step 1 — Resolve the Session

The sessions directory is at `game-of-future/sessions/` relative to the
current working directory. If not found there, look for it at
`~/work/game-of-future/game-of-future/sessions/`.

The skill is invoked as `/game-of-future:report [argument]` where `[argument]`
is optional and may be:
- A full session folder name (e.g. `20260617T062405Z-learning-foreign-languages-in-2030`)
- A partial filter term (e.g. `languages`, `education`)
- Absent

### If an explicit session folder name was supplied

Check the folder exists and that the first 20 lines of its `session.md`
contain `Phase 9 — Complete`. Proceed to the confirmation step.

### If a filter term or no argument was supplied

1. Count the total number of subdirectories in `game-of-future/sessions/`.
2. If more than 100, stop and respond: "There are over 100 sessions. Please
   supply a session folder name or a more specific filter term." Do not proceed.
3. If 100 or fewer: for each folder, read only the folder name and the first
   20 lines of `session.md` inside it. Do not read any other files during this
   scan. Check for `Phase 9 — Complete` in those 20 lines.
4. Collect only completed sessions. If a filter term was supplied, keep only
   sessions whose folder name contains the filter term (case-insensitive).
5. Sort collected sessions newest-first (the folder name starts with a
   timestamp so lexicographic descending sort works).
6. Present a numbered list:

   ```
   Completed sessions:
   1. [Topic] ([session-id])
   2. [Topic] ([session-id])
   ...
   Enter a number to select:
   ```

7. Wait for the user to pick a number.

### Confirmation step (always)

Before generating — regardless of how the session was resolved — show:

> Generating report for: **[topic]** (`[session-id]`) — ok?

Wait for an affirmative response before proceeding. If the user says no or
provides a correction, restart selection.

## Step 2 — Read Artifacts

Read these files in order. Read each file completely before moving to the next.

1. `[session-folder]/session.md` — extract: topic, completion date, player
   count, team count
2. `[session-folder]/briefing.md` — extract: the **Facts** section and the
   **Observed Trends** section only. Do NOT use the Facilitator Inference
   section in the Brief HTML section.
3. `[session-folder]/public-room.md` — extract: the accepted cliché list, the
   dissented-items note (if any), and the Team Presentations section
4. `[session-folder]/roster.md` — extract: each player's display name, profile
   label, and team assignment
5. `[session-folder]/report.md` — extract: Forecasts section, Products section
   (all product fields and intersection tests), Official Vote Totals, and
   Non-Binding Facilitator Analysis

Do NOT read `forecasts/*.md` or `teams/*.md` directly unless `report.md` is
absent or its Forecasts/Products sections are empty — in that case read those
files and note the fallback to the user.

## Step 3 — Write report.html

Write a single file to `[session-folder]/report.html`. Follow every constraint
below without exception.

### Self-Contained Constraint (non-negotiable)

The file must work offline when opened from `file://` with no network:
- ALL CSS in one `<style>` block in `<head>`. No `<link rel="stylesheet">`.
- No `<script src="">`. No inline JS.
- No web fonts. No `@import url(...)`. No `@font-face` with remote src.
- No `<img src="">` pointing to any URL. No remote resources of any kind.

### Semantic and Naming Rules (non-negotiable)

- Use `<article class="gof-report">` as the document wrapper
- Use `<header>` for the hero section
- Use `<section>` for every content section
- Use `<footer>` for the footer
- Every section root must carry an `id` attribute matching the section name
  exactly as specified below (e.g. `id="products"`, `id="vote"`)
- Every meaningful block and element must have a BEM-style class name under
  the `.gof-` namespace (e.g. `.gof-product-card__name`)
- Class names must be descriptive enough that a designer who has never seen
  this skill can identify any element by reading the HTML alone

### Document Skeleton

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>[TOPIC] — Game of Future</title>
  <style>
    /* ALL CSS HERE — see CSS Specification below */
  </style>
</head>
<body>
  <article class="gof-report">
    <header  id="hero"             class="gof-hero">          … </header>
    <section id="brief"            class="gof-brief">         … </section>
    <section id="cliches"          class="gof-cliches">       … </section>
    <section id="forecasts"        class="gof-forecasts">     … </section>
    <section id="products"         class="gof-products">      … </section>
    <section id="vote"             class="gof-vote">          … </section>
    <section id="facilitators-take" class="gof-facilitator">  … </section>
    <footer  id="footer"           class="gof-footer">        … </footer>
  </article>
</body>
</html>
```

### CSS Specification

Write exactly this CSS in the `<style>` block (adjust only to fill in dynamic
values like bar widths):

```css
/* === Reset & Base === */
*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
body {
  background: #faf9f7;
  color: #1a1a1a;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
  font-size: 17px;
  line-height: 1.65;
}

/* === Report wrapper === */
.gof-report {
  max-width: 860px;
  margin: 0 auto;
  padding: 0 24px;
}

/* === Shared label === */
.gof-section-label {
  display: block;
  font-size: 0.75rem;
  font-weight: 600;
  letter-spacing: 0.1em;
  text-transform: uppercase;
  color: #1a5f6a;
  margin-bottom: 24px;
}

/* === Hero === */
.gof-hero {
  padding: 80px 0 64px;
  border-bottom: 1px solid #e8e4de;
}
.gof-hero__title {
  font-family: Georgia, 'Times New Roman', serif;
  font-size: clamp(2rem, 5vw, 3.25rem);
  font-weight: normal;
  line-height: 1.15;
  color: #1a1a1a;
  margin-bottom: 16px;
}
.gof-hero__subtitle {
  font-size: 0.95rem;
  color: #6b6b6b;
  letter-spacing: 0.03em;
  text-transform: uppercase;
  margin-bottom: 24px;
}
.gof-hero__intro {
  font-size: 1.1rem;
  color: #3a3a3a;
  max-width: 600px;
}

/* === Brief === */
.gof-brief {
  padding: 64px 0;
  border-bottom: 1px solid #e8e4de;
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 48px;
  align-items: start;
}
.gof-brief__facts-list {
  list-style: none;
  padding: 0;
}
.gof-brief__facts-list li {
  padding: 10px 0;
  border-bottom: 1px solid #e8e4de;
  font-size: 0.95rem;
  color: #3a3a3a;
}
.gof-brief__facts-list li:last-child { border-bottom: none; }
.gof-brief__context {
  font-size: 1rem;
  color: #3a3a3a;
  line-height: 1.7;
}
.gof-brief__context p + p { margin-top: 14px; }

/* === Clichés === */
.gof-cliches {
  padding: 64px 0;
  border-bottom: 1px solid #e8e4de;
}
.gof-cliches__intro {
  font-size: 0.95rem;
  color: #6b6b6b;
  margin-bottom: 24px;
}
.gof-cliches__list {
  columns: 2;
  column-gap: 32px;
  list-style: decimal;
  padding-left: 20px;
}
.gof-cliches__item {
  font-size: 0.875rem;
  color: #6b6b6b;
  padding: 5px 0;
  break-inside: avoid;
}
.gof-cliches__dissent-note {
  margin-top: 20px;
  font-size: 0.875rem;
  color: #6b6b6b;
  font-style: italic;
}

/* === Forecasts === */
.gof-forecasts {
  padding: 64px 0;
  border-bottom: 1px solid #e8e4de;
}
.gof-forecasts__intro {
  font-size: 1rem;
  color: #3a3a3a;
  margin-bottom: 40px;
  max-width: 620px;
}
.gof-forecasts__grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 20px;
}
.gof-forecast-card {
  background: #ffffff;
  border: 1px solid #e8e4de;
  border-radius: 4px;
  padding: 20px;
}
.gof-forecast-card__player-name {
  font-family: Georgia, 'Times New Roman', serif;
  font-size: 1rem;
  font-weight: normal;
  color: #1a1a1a;
  margin-bottom: 4px;
}
.gof-forecast-card__profile {
  font-size: 0.8rem;
  color: #6b6b6b;
  margin-bottom: 10px;
}
.gof-forecast-card__team {
  font-size: 0.75rem;
  color: #1a5f6a;
  font-weight: 600;
  letter-spacing: 0.05em;
  text-transform: uppercase;
  margin-bottom: 12px;
}
.gof-forecast-card__summary {
  font-size: 0.9rem;
  color: #3a3a3a;
  line-height: 1.6;
}

/* === Products (primary section) === */
.gof-products {
  padding: 80px 0;
  border-bottom: 1px solid #e8e4de;
}
.gof-products__intro {
  font-size: 1.05rem;
  color: #3a3a3a;
  margin-bottom: 40px;
  max-width: 620px;
}
.gof-products__grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 28px;
}
.gof-product-card {
  background: #ffffff;
  border: 1px solid #e8e4de;
  border-radius: 4px;
  padding: 32px;
  position: relative;
}
.gof-product-card--winner {
  border-left: 4px solid #1a5f6a;
}
.gof-product-card__badge {
  position: absolute;
  top: 16px;
  right: 16px;
  background: #1a5f6a;
  color: #ffffff;
  font-size: 0.65rem;
  font-weight: 700;
  letter-spacing: 0.12em;
  text-transform: uppercase;
  padding: 3px 8px;
  border-radius: 2px;
}
.gof-product-card__team-label {
  font-size: 0.75rem;
  color: #6b6b6b;
  text-transform: uppercase;
  letter-spacing: 0.08em;
  margin-bottom: 8px;
}
.gof-product-card__name {
  font-family: Georgia, 'Times New Roman', serif;
  font-size: 1.6rem;
  font-weight: normal;
  color: #1a1a1a;
  margin-bottom: 16px;
  line-height: 1.2;
}
.gof-product-card__core-idea {
  font-size: 0.975rem;
  color: #3a3a3a;
  line-height: 1.65;
  margin-bottom: 20px;
}
.gof-product-card__buyer {
  font-size: 0.875rem;
  color: #3a3a3a;
  margin-bottom: 12px;
}
.gof-product-card__buyer strong { color: #1a1a1a; }
.gof-product-card__intersection {
  font-size: 0.875rem;
  color: #3a3a3a;
  padding-top: 16px;
  border-top: 1px solid #e8e4de;
  line-height: 1.6;
}
.gof-product-card__intersection strong { color: #1a1a1a; }
.gof-product-card__votes {
  margin-top: 16px;
  font-size: 0.8rem;
  color: #6b6b6b;
}

/* === Vote === */
.gof-vote {
  padding: 64px 0;
  border-bottom: 1px solid #e8e4de;
}
.gof-vote__intro { margin-bottom: 32px; font-size: 1rem; color: #3a3a3a; }
.gof-vote__tally { max-width: 520px; }
.gof-vote__tally-row {
  display: flex;
  align-items: center;
  gap: 16px;
  margin-bottom: 14px;
}
.gof-vote__label {
  width: 148px;
  flex-shrink: 0;
  font-size: 0.9rem;
  color: #3a3a3a;
}
.gof-vote__tally-row--winner .gof-vote__label {
  font-weight: 600;
  color: #1a1a1a;
}
.gof-vote__bar-track {
  flex: 1;
  background: #e8e4de;
  height: 8px;
  border-radius: 4px;
  overflow: hidden;
}
.gof-vote__bar {
  height: 100%;
  background: #6b6b6b;
  border-radius: 4px;
}
.gof-vote__tally-row--winner .gof-vote__bar { background: #1a5f6a; }
.gof-vote__count {
  width: 28px;
  text-align: right;
  font-size: 0.9rem;
  color: #6b6b6b;
  flex-shrink: 0;
}
.gof-vote__tally-row--winner .gof-vote__count {
  color: #1a1a1a;
  font-weight: 600;
}
.gof-vote__rules {
  margin-top: 20px;
  font-size: 0.8rem;
  color: #6b6b6b;
}

/* === Facilitator === */
.gof-facilitator {
  padding: 64px 0;
  border-bottom: 1px solid #e8e4de;
}
.gof-facilitator__intro {
  font-size: 0.9rem;
  color: #6b6b6b;
  font-style: italic;
  margin-bottom: 24px;
}
.gof-facilitator__body {
  font-size: 1rem;
  color: #3a3a3a;
  line-height: 1.7;
  max-width: 680px;
}
.gof-facilitator__body p + p { margin-top: 16px; }

/* === Footer === */
.gof-footer {
  padding: 40px 0;
  font-size: 0.8rem;
  color: #6b6b6b;
}

/* === Responsive === */
@media (max-width: 720px) {
  .gof-brief            { grid-template-columns: 1fr; }
  .gof-forecasts__grid  { grid-template-columns: repeat(2, 1fr); }
  .gof-products__grid   { grid-template-columns: 1fr; }
  .gof-cliches__list    { columns: 1; }
}
@media (max-width: 480px) {
  .gof-forecasts__grid  { grid-template-columns: 1fr; }
}
```

### Section Content Instructions

Write each section in order. Follow the content guidance exactly.

---

#### `<header id="hero" class="gof-hero">`

```html
<header id="hero" class="gof-hero">
  <span class="gof-section-label">Game of Future</span>
  <h1 class="gof-hero__title">[TOPIC]</h1>
  <p class="gof-hero__subtitle">A foresight session · [DATE]</p>
  <p class="gof-hero__intro">Game of Future is a structured foresight game where AI players produce independent forecasts, form teams, and design products grounded in plausible futures. This is the record of one complete session.</p>
</header>
```

Substitute: `[TOPIC]` = session topic verbatim. `[DATE]` = human-readable date
(e.g. "June 17, 2026") derived from the session timestamp or the Completed
field in `session.md`.

---

#### `<section id="brief" class="gof-brief">`

**Left column — facts:**
Extract 6–8 of the most concrete, specific facts and observed trends from
`briefing.md`. Use only the **Facts** and **Observed Trends** sections. Do
not use Facilitator Inference here. Prefer facts that contain numbers, named
organisations, or dates. Write each as a single `<li>`.

**Right column — context:**
Write a 3–5 sentence editorial paragraph in your own words answering "why does
this topic matter right now?" This is not a summary of the facts — it is a
framing paragraph for a reader who knows nothing about the topic. Draw from
the briefing material but do not copy it.

```html
<section id="brief" class="gof-brief">
  <div class="gof-brief__facts">
    <span class="gof-section-label">The brief</span>
    <ul class="gof-brief__facts-list">
      <li>…</li>
    </ul>
  </div>
  <div class="gof-brief__context">
    <span class="gof-section-label">Why this, why now</span>
    <p>…</p>
  </div>
</section>
```

---

#### `<section id="cliches" class="gof-cliches">`

Extract the accepted cliché list from `public-room.md`. Do not include
dissented items in the `<ol>`. After the list, add the dissent note if any
items were dissented during the session.

Dissent note wording: "N ideas were too interesting to dismiss — they became
forecast territory instead." (Replace N with the actual count from the session
notes. If none, omit the note entirely.)

```html
<section id="cliches" class="gof-cliches">
  <span class="gof-section-label">The clichés</span>
  <p class="gof-cliches__intro">These are the obvious futures the game discards. Products that merely instantiate one of these were disqualified.</p>
  <ol class="gof-cliches__list">
    <li class="gof-cliches__item">…</li>
  </ol>
  <p class="gof-cliches__dissent-note">N ideas were too interesting to dismiss — they became forecast territory instead.</p>
</section>
```

---

#### `<section id="forecasts" class="gof-forecasts">`

From the Forecasts section of `report.md`, write one `<article
class="gof-forecast-card">` per player. For each card:

- `gof-forecast-card__player-name`: player display name
- `gof-forecast-card__profile`: profile label in lowercase (e.g. "skeptical
  economist", "public-policy analyst")
- `gof-forecast-card__team`: team assignment (e.g. "Team Alpha")
- `gof-forecast-card__summary`: **Write a fresh 2–3 sentence distillation in
  your own words.** Do not copy text from `report.md` verbatim. Capture: what
  the player predicted, and the core causal logic behind it. Target 50–80
  words. Make it readable for someone who has not read the full forecast.

```html
<section id="forecasts" class="gof-forecasts">
  <span class="gof-section-label">The forecasts</span>
  <p class="gof-forecasts__intro">Twelve players each produced one independent forecast before teams were formed. These are the raw materials the products are built from.</p>
  <div class="gof-forecasts__grid">
    <article class="gof-forecast-card">
      <h3 class="gof-forecast-card__player-name">…</h3>
      <p class="gof-forecast-card__profile">…</p>
      <p class="gof-forecast-card__team">…</p>
      <p class="gof-forecast-card__summary">…</p>
    </article>
    <!-- one article per player -->
  </div>
</section>
```

---

#### `<section id="products" class="gof-products">` ← PRIMARY SECTION

This is the visual centrepiece. Render the winner card first, followed by the
remaining three in descending vote order.

From the Products section of `report.md`, write one card per team. For each:

- `gof-product-card__team-label`: "Team [Name]" (e.g. "Team Alpha")
- `gof-product-card__name`: product name (e.g. "ShiftReady") as `<h2>`
- `gof-product-card__core-idea`: **Distil to 2–3 sentences in your own
  words.** Do not copy from `report.md` or the team pitch verbatim. Answer:
  what is it, what does it do, who is it for? Make it vivid and concrete.
- `gof-product-card__buyer`: `<strong>For:</strong>` followed by one line
  identifying the target buyer (not the end user — the entity paying)
- `gof-product-card__intersection`: `<strong>Why it works:</strong>` followed
  by one sentence explaining why the product fails if either retained forecast
  is removed. Distilled from the Intersection Test in `report.md`.
- `gof-product-card__votes`: "[N] votes"

Winner card: add class `gof-product-card--winner` and include
`<span class="gof-product-card__badge">Winner</span>` as the first child.

Vote bar widths in the `#vote` section: scale proportionally to the winner.
Winner = 100%. Others = (their votes / winner votes) × 100%.

```html
<section id="products" class="gof-products">
  <span class="gof-section-label">The products</span>
  <p class="gof-products__intro">Each team discarded one of their three assigned forecasts and designed a product that only works when the remaining two are combined. These are the results.</p>
  <div class="gof-products__grid">

    <!-- Winner first -->
    <article class="gof-product-card gof-product-card--winner">
      <span class="gof-product-card__badge">Winner</span>
      <p class="gof-product-card__team-label">Team Alpha</p>
      <h2 class="gof-product-card__name">…</h2>
      <p class="gof-product-card__core-idea">…</p>
      <p class="gof-product-card__buyer"><strong>For:</strong> …</p>
      <p class="gof-product-card__intersection"><strong>Why it works:</strong> …</p>
      <p class="gof-product-card__votes">8 votes</p>
    </article>

    <!-- Remaining three in descending vote order -->
    <article class="gof-product-card">
      <p class="gof-product-card__team-label">Team …</p>
      <h2 class="gof-product-card__name">…</h2>
      <p class="gof-product-card__core-idea">…</p>
      <p class="gof-product-card__buyer"><strong>For:</strong> …</p>
      <p class="gof-product-card__intersection"><strong>Why it works:</strong> …</p>
      <p class="gof-product-card__votes">N votes</p>
    </article>

  </div>
</section>
```

---

#### `<section id="vote" class="gof-vote">`

From the Official Vote Totals in `report.md`. Show all four teams. Winner row
gets `gof-vote__tally-row--winner`. Bar widths: winner = `width: 100%`;
others = `width: [their_votes / winner_votes * 100]%` as an inline style on
`.gof-vote__bar`.

```html
<section id="vote" class="gof-vote">
  <span class="gof-section-label">The vote</span>
  <p class="gof-vote__intro">Each of [N] players cast 2 votes for teams other than their own.</p>
  <div class="gof-vote__tally">

    <div class="gof-vote__tally-row gof-vote__tally-row--winner">
      <span class="gof-vote__label">[Product Name]</span>
      <div class="gof-vote__bar-track">
        <div class="gof-vote__bar" style="width: 100%"></div>
      </div>
      <span class="gof-vote__count">N</span>
    </div>

    <div class="gof-vote__tally-row">
      <span class="gof-vote__label">[Product Name]</span>
      <div class="gof-vote__bar-track">
        <div class="gof-vote__bar" style="width: [pct]%"></div>
      </div>
      <span class="gof-vote__count">N</span>
    </div>

    <!-- repeat for remaining teams -->

  </div>
  <p class="gof-vote__rules">[N] players · 2 votes each · no self-voting · [total] total votes cast</p>
</section>
```

---

#### `<section id="facilitators-take" class="gof-facilitator">`

From the Non-Binding Facilitator Analysis in `report.md`. **Do not reproduce
all subsections.** Select the 3–4 most interesting observations from any of
the subsections and **rewrite them as flowing prose paragraphs**. No headers.
No bullet points. Target: 200–280 words across 2–3 paragraphs. Label this
section clearly as non-binding commentary.

```html
<section id="facilitators-take" class="gof-facilitator">
  <span class="gof-section-label">Facilitator's take</span>
  <p class="gof-facilitator__intro">Non-binding commentary — this is the facilitator's read, not a player verdict.</p>
  <div class="gof-facilitator__body">
    <p>…</p>
    <p>…</p>
  </div>
</section>
```

---

#### `<footer id="footer" class="gof-footer">`

```html
<footer id="footer" class="gof-footer">
  <p>Session [SESSION-ID] · [DATE] · Generated by Game of Future</p>
</footer>
```

---

## Step 4 — Open the File

After writing `report.html`, open it in the default browser:

- Linux: `xdg-open [full-path-to-report.html]`
- macOS: `open [full-path-to-report.html]`

Then report to the user: "report.html written to [path] and opened in browser."
````

- [ ] **Step 3: Verify the file was written**

```bash
wc -l /home/kappa/.claude/skills/game-of-future/skills/report/SKILL.md
```

Expected: 300+ lines.

```bash
head -5 /home/kappa/.claude/skills/game-of-future/skills/report/SKILL.md
```

Expected output:
```
---
name: report
description: Generate a self-contained HTML presentation from a completed Game of Future session. Reads session artifacts and writes report.html to the session folder, then opens it in the browser.
---
```

- [ ] **Step 4: Commit**

```bash
git add /home/kappa/.claude/skills/game-of-future/skills/report/SKILL.md
git commit -m "feat: add game-of-future:report sub-skill for HTML presentation generation"
```

---

### Task 2: Smoke-test against the reference session

**Files:**
- Reads: `game-of-future/sessions/20260617T062405Z-learning-foreign-languages-in-2030/` (all five artifact files)
- Creates: `game-of-future/sessions/20260617T062405Z-learning-foreign-languages-in-2030/report.html`

**Interfaces:**
- Consumes: SKILL.md from Task 1
- Produces: `report.html` in the session folder, opened in browser

- [ ] **Step 1: Invoke the skill**

In the Claude Code session, invoke:

```
/game-of-future:report 20260617T062405Z-learning-foreign-languages-in-2030
```

Expected: confirmation prompt appears:
```
Generating report for: Learning foreign languages in 2030 (20260617T062405Z) — ok?
```

Confirm with "ok" or "yes".

Expected: Claude reads five artifact files, writes report.html, opens browser.

- [ ] **Step 2: Verify report.html was created**

```bash
ls -lh game-of-future/sessions/20260617T062405Z-learning-foreign-languages-in-2030/report.html
```

Expected: file exists, size > 30KB.

- [ ] **Step 3: Verify self-contained constraint**

```bash
grep -c 'src="http' game-of-future/sessions/20260617T062405Z-learning-foreign-languages-in-2030/report.html
grep -c '<link rel=' game-of-future/sessions/20260617T062405Z-learning-foreign-languages-in-2030/report.html
grep -c '<script src=' game-of-future/sessions/20260617T062405Z-learning-foreign-languages-in-2030/report.html
```

Expected: all three commands output `0`.

- [ ] **Step 4: Verify section structure**

```bash
grep -o 'id="[^"]*"' game-of-future/sessions/20260617T062405Z-learning-foreign-languages-in-2030/report.html | sort
```

Expected output contains all eight IDs:
```
id="brief"
id="cliches"
id="facilitators-take"
id="footer"
id="forecasts"
id="hero"
id="products"
id="vote"
```

- [ ] **Step 5: Verify BEM namespace**

```bash
grep -c 'class="gof-' game-of-future/sessions/20260617T062405Z-learning-foreign-languages-in-2030/report.html
```

Expected: > 30 (many elements carry `.gof-` classes).

- [ ] **Step 6: Verify winner card**

```bash
grep 'gof-product-card--winner' game-of-future/sessions/20260617T062405Z-learning-foreign-languages-in-2030/report.html
```

Expected: one line containing `gof-product-card--winner` and `gof-product-card__badge`.

- [ ] **Step 7: Visual review in browser**

Open the file in a browser (it should already be open from Step 1). Verify:
- Hero section shows the topic in large serif type
- Brief section has two columns (facts list left, context paragraph right)
- Clichés section is visually de-emphasised (grey, smaller type)
- Forecasts grid shows 12 cards at 3-across
- Products section is visually dominant — larger cards, winner has teal left border and WINNER badge
- Vote section shows horizontal bar tally, winner bar in teal
- Facilitator section shows prose paragraphs (not headers or bullets)
- Footer shows session ID

If any section is missing or structurally wrong, note the issue and ask Claude to regenerate with a corrected prompt.

- [ ] **Step 8: Commit the generated report.html**

```bash
git add game-of-future/sessions/20260617T062405Z-learning-foreign-languages-in-2030/report.html
git commit -m "feat: generate HTML report for learning-foreign-languages-in-2030 session"
```
