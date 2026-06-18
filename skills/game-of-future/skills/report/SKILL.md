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
  exactly as specified below
- Every meaningful block and element must have a BEM-style class name under
  the `.gof-` namespace (e.g. `.gof-team-block__player-name`)
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
    <header  id="hero"              class="gof-hero">           … </header>
    <section id="brief"             class="gof-brief">          … </section>
    <section id="participants"      class="gof-participants">   … </section>
    <section id="cliches"           class="gof-cliches">        … </section>
    <section id="forecasts"         class="gof-forecasts">      … </section>
    <section id="products"          class="gof-products">       … </section>
    <section id="facilitators-take" class="gof-facilitator">    … </section>
    <footer  id="footer"            class="gof-footer">         … </footer>
  </article>
</body>
</html>
```

### CSS Specification

Write exactly this CSS in the `<style>` block:

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

/* === Shared section label === */
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
}
/* The "what is Game of Future" note — secondary, visually separated from the report content */
.gof-hero__about {
  margin-top: 32px;
  padding-top: 20px;
  border-top: 1px solid #e8e4de;
  font-size: 0.85rem;
  color: #6b6b6b;
  max-width: 560px;
  line-height: 1.6;
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
.gof-brief__date-note {
  font-size: 0.75rem;
  color: #9b9b9b;
  margin-bottom: 16px;
  font-style: italic;
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
.gof-brief__context p {
  margin-bottom: 14px;
}
.gof-brief__context p:last-child { margin-bottom: 0; }

/* === Participants === */
.gof-participants {
  padding: 48px 0;
  border-bottom: 1px solid #e8e4de;
}
.gof-participants__intro {
  font-size: 0.9rem;
  color: #6b6b6b;
  margin-bottom: 28px;
}
.gof-participants__grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 24px;
}
.gof-team-block__name {
  font-size: 0.8rem;
  font-weight: 600;
  letter-spacing: 0.06em;
  text-transform: uppercase;
  color: #1a5f6a;
  margin-bottom: 12px;
  padding-bottom: 8px;
  border-bottom: 1px solid #e8e4de;
}
.gof-team-block__list {
  list-style: none;
  padding: 0;
}
.gof-team-block__player {
  padding: 7px 0;
  border-bottom: 1px solid #f0ece6;
}
.gof-team-block__player:last-child { border-bottom: none; }
.gof-team-block__player-name {
  display: block;
  font-size: 0.875rem;
  color: #1a1a1a;
}
.gof-team-block__player-role {
  display: block;
  font-size: 0.78rem;
  color: #6b6b6b;
}

/* === Clichés (intentionally de-emphasised) === */
.gof-cliches {
  padding: 40px 0;
  border-bottom: 1px solid #e8e4de;
}
.gof-cliches .gof-section-label {
  color: #9b9b9b;
}
.gof-cliches__intro {
  font-size: 0.85rem;
  color: #9b9b9b;
  margin-bottom: 20px;
}
.gof-cliches__list {
  columns: 2;
  column-gap: 32px;
  list-style: decimal;
  padding-left: 20px;
}
.gof-cliches__item {
  font-size: 0.8rem;
  color: #9b9b9b;
  padding: 3px 0;
  break-inside: avoid;
}
.gof-cliches__dissent-note {
  margin-top: 16px;
  font-size: 0.8rem;
  color: #9b9b9b;
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
/* Team divider row — spans full width of the forecast grid */
.gof-forecasts__team-divider {
  grid-column: 1 / -1;
  padding: 10px 0 6px;
  margin-top: 12px;
  font-size: 0.75rem;
  font-weight: 600;
  letter-spacing: 0.08em;
  text-transform: uppercase;
  color: #6b6b6b;
  border-bottom: 1px solid #e8e4de;
}
.gof-forecasts__team-divider:first-child {
  margin-top: 0;
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
  margin-bottom: 14px;
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
@media (max-width: 860px) {
  .gof-participants__grid { grid-template-columns: repeat(2, 1fr); }
}
@media (max-width: 720px) {
  .gof-brief              { grid-template-columns: 1fr; }
  .gof-forecasts__grid    { grid-template-columns: repeat(2, 1fr); }
  .gof-products__grid     { grid-template-columns: 1fr; }
  .gof-cliches__list      { columns: 1; }
  .gof-participants__grid { grid-template-columns: repeat(2, 1fr); }
}
@media (max-width: 480px) {
  .gof-forecasts__grid    { grid-template-columns: 1fr; }
  .gof-participants__grid { grid-template-columns: 1fr; }
}
```

### Section Content Instructions

Write each section in order. Follow the content guidance exactly.

---

#### `<header id="hero" class="gof-hero">`

The hero opens directly with the topic — no section label. The "what is Game
of Future" note appears below the subtitle, visually separated by a rule, so
it reads as a contextual footnote rather than report content.

```html
<header id="hero" class="gof-hero">
  <h1 class="gof-hero__title">[TOPIC]</h1>
  <p class="gof-hero__subtitle">A Game of Future session · [DATE]</p>
  <p class="gof-hero__about">Game of Future is a structured foresight game where AI players produce independent forecasts, form teams, and design products grounded in plausible futures. This document is the record of one complete session.</p>
</header>
```

Substitute: `[TOPIC]` = session topic verbatim. `[DATE]` = human-readable date
(e.g. "June 17, 2026") derived from the session timestamp or the Completed
field in `session.md`.

---

#### `<section id="brief" class="gof-brief">`

**Date caveat (always include):** Above the facts list, add a small note
identifying when the briefing was prepared. This signals to the reader that
the statistics belong to the game's moment in time, not the present day.

**Left column — facts:**
Extract 6–8 of the most concrete, specific facts and observed trends from
`briefing.md`. Use only the **Facts** and **Observed Trends** sections. Do
not use Facilitator Inference here. Prefer facts that contain numbers, named
organisations, or dates. Write each as a single `<li>`.

**Right column — context ("Why this, why now"):**
Write exactly 3 paragraphs. Each paragraph is exactly 2 sentences. The first
sentence states the point plainly. The second sentence gives one concrete
consequence or example. No sentence should contain more than one independent
clause. No em-dashes, no parenthetical asides. Do not summarise the facts —
reframe them. Answer one question per paragraph: what has changed / why it
matters now / what the interesting tension is. A reader should absorb all
three points in 20 seconds.

```html
<section id="brief" class="gof-brief">
  <div class="gof-brief__facts">
    <span class="gof-section-label">The brief</span>
    <p class="gof-brief__date-note">Briefing prepared at session start: [DATE]</p>
    <ul class="gof-brief__facts-list">
      <li>…</li>
    </ul>
  </div>
  <div class="gof-brief__context">
    <span class="gof-section-label">Why this, why now</span>
    <p>…</p>
    <p>…</p>
    <p>…</p>
  </div>
</section>
```

---

#### `<section id="participants" class="gof-participants">`

From `roster.md`. Show all players grouped by team. Each team is a column
in a 4-across grid. Within each team column, list the three players with
their display name and profile label (lowercase, no quotes).

```html
<section id="participants" class="gof-participants">
  <span class="gof-section-label">The players</span>
  <p class="gof-participants__intro">[N] AI players, each with a distinct background, distributed across [T] teams.</p>
  <div class="gof-participants__grid">

    <div class="gof-team-block">
      <h3 class="gof-team-block__name">Team Alpha</h3>
      <ul class="gof-team-block__list">
        <li class="gof-team-block__player">
          <span class="gof-team-block__player-name">…</span>
          <span class="gof-team-block__player-role">…</span>
        </li>
        <!-- one li per player in this team -->
      </ul>
    </div>

    <!-- one gof-team-block per team -->

  </div>
</section>
```

---

#### `<section id="cliches" class="gof-cliches">`

This section is intentionally de-emphasised — the cliché list shaped the
game but is not the game's output. Use the subdued colour overrides already
defined in the CSS (`.gof-cliches .gof-section-label`, `.gof-cliches__item`).

Extract the accepted cliché list from `report.md` (Accepted Clichés section)
or from `public-room.md`. Do not include dissented items in the `<ol>`. After
the list, add the dissent note if any items were dissented.

Dissent note wording: "N ideas were too interesting to dismiss — they became
forecast territory instead." (Replace N with the actual count. If none, omit.)

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

Group forecast cards by team. Before each group of cards, insert a
`.gof-forecasts__team-divider` element that spans the full grid width.
This makes team boundaries explicit without disrupting the card layout.

From the Forecasts section of `report.md`, write one `<article
class="gof-forecast-card">` per player. For each card:

- `gof-forecast-card__player-name`: player display name
- `gof-forecast-card__profile`: profile label in lowercase (e.g. "skeptical
  economist"). Do **not** include the team name here — the team divider above
  the group already carries it.
- `gof-forecast-card__summary`: **Write a fresh 2–3 sentence distillation in
  your own words.** Do not copy text from `report.md` verbatim. Capture: what
  the player predicted and the core causal logic behind it. Target 50–80
  words. Make it readable for someone who has not read the full forecast.

```html
<section id="forecasts" class="gof-forecasts">
  <span class="gof-section-label">The forecasts</span>
  <p class="gof-forecasts__intro">Each player produced one independent forecast before teams were formed. These are the raw materials the products are built from.</p>
  <div class="gof-forecasts__grid">

    <div class="gof-forecasts__team-divider">Team Alpha</div>
    <article class="gof-forecast-card">
      <h3 class="gof-forecast-card__player-name">…</h3>
      <p class="gof-forecast-card__profile">…</p>
      <p class="gof-forecast-card__summary">…</p>
    </article>
    <!-- two more cards for this team -->

    <div class="gof-forecasts__team-divider">Team Beta</div>
    <!-- three cards -->

    <!-- and so on for Gamma, Delta -->

  </div>
</section>
```

---

#### `<section id="products" class="gof-products">` ← PRIMARY SECTION

This is the visual centrepiece. Render the winner card first, followed by the
remaining three in descending vote order.

From the Products section of `report.md`, write one card per team. For each:

- `gof-product-card__team-label`: "Team [Name]"
- `gof-product-card__name`: product name as `<h2>`
- `gof-product-card__core-idea`: **Write 3–4 sentences in plain English for a
  curious outsider who has never worked in enterprise software, HR compliance,
  healthcare administration, or any specialist domain.** Do not copy from
  `report.md`. Do not use jargon. Ground every abstract claim in a concrete
  scenario. Good test: would the product's own target user — a frontline
  worker, a caseworker, a clinic manager — immediately understand what this
  does from reading these sentences?
- `gof-product-card__buyer`: `<strong>For:</strong>` followed by one line
  identifying who pays for this, in plain terms
- `gof-product-card__intersection`: `<strong>Why it works:</strong>` followed
  by one sentence in plain English explaining why the product depends on both
  retained forecasts. Avoid the word "forecast" — say "prediction" or "bet" if
  you need a synonym. A reader who does not know the game's rules should
  understand what is being said.
- `gof-product-card__votes`: "[N] votes"

Winner card: add class `gof-product-card--winner` and include
`<span class="gof-product-card__badge">Winner</span>` as the first child.

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
      <p class="gof-product-card__votes">N votes</p>
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
