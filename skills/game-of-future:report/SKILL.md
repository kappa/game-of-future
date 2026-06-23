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

### Font and Resource Constraints

- ALL CSS goes in one `<style>` block in `<head>`. No other `<link rel="stylesheet">`.
- Three `<link>` tags for Google Fonts are required in `<head>` — see Document
  Skeleton. All other resources must be self-contained.
- No `<script src="">`. No inline JS.
- No `<img src="">` pointing to a URL. No other remote resources.
- The report requires an internet connection for the Bricolage Grotesque, Hanken
  Grotesk, and Space Mono typefaces. Without a connection the browser uses system
  fallbacks, which degrade the visual design but remain readable.

### Naming and Structure Rules

- Use `<div class="wrap">` as the document wrapper
- Use `<header>`, `<section>`, and `<footer>` for top-level blocks
- The class names in the CSS Specification below are exact and complete; do not
  invent new classes or add BEM namespacing
- Team colour classes `.t-alpha`, `.t-beta`, `.t-gamma`, `.t-delta` supply three
  CSS custom properties — `--tc` (main colour), `--ts` (surface tint), `--ti`
  (ink/dark shade) — used by descendant elements via `var()`
- Apply the appropriate `.t-[name]` class to each team's container element in
  every section that groups content by team

### Language Rule

Read the session language from the `Language:` field in `session.md`.

All strings in the Section Content Instructions below are English templates.
Every string that is not sourced verbatim from a session artifact (topic, player
names, forecast text, vote counts, dates, session IDs) must be rendered in the
session language. This covers: the kicker label, the lede, eyebrow labels,
section headings, the "Why this, why now" box heading and paragraphs, the discard
intro and stamp text, forecast and product intro sentences, the vote section
heading and tally labels, the verdict note, and the footer line. Set `<html
lang="">` to the BCP 47 code for the session language.

### Player Initials Tokens

Each player card shows a two-letter token. Derive it: first letter of the
player's first name + first letter of last name, both uppercase (e.g. "Mira
Chen" → "MC").

### Vote Bar Widths

In the tally section, each bar's fill width is a percentage of the winner's vote
count. Calculate: `(this_product_votes / winner_votes) × 100`%. The winner's bar
is always 100%. Round to the nearest whole percent.

### Document Skeleton

```html
<!DOCTYPE html>
<html lang="[SESSION-LANG-CODE]">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>[TOPIC] — Game of Future</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Bricolage+Grotesque:opsz,wght@12..96,500;12..96,600;12..96,700;12..96,800&family=Hanken+Grotesk:wght@400;500;600;700&family=Space+Mono:wght@400;700&display=swap" rel="stylesheet">
  <style>
    /* ALL CSS HERE */
  </style>
</head>
<body>
<div class="wrap">
  <header>…</header>                               <!-- hero -->
  <section class="briefing">…</section>            <!-- brief + why now -->
  <section>…</section>                             <!-- players -->
  <section class="discard">…</section>             <!-- clichés -->
  <section>…</section>                             <!-- forecasts -->
  <section>…</section>                             <!-- products -->
  <section>…</section>                             <!-- vote tally -->
  <section style="margin-bottom:40px">…</section>  <!-- verdict -->
  <footer>…</footer>
</div>
</body>
</html>
```

### CSS Specification

Write exactly this CSS in the `<style>` block:

```css
*{box-sizing:border-box}
html,body{margin:0;padding:0}
body{background:#f3ead9;background-image:radial-gradient(#e1d5bd 1.4px,transparent 1.4px);background-size:26px 26px;font:400 16px/1.6 'Hanken Grotesk',system-ui,sans-serif;color:#2a2118}
.wrap{max-width:1000px;margin:0 auto;padding:0 28px 96px}
section{margin-bottom:64px}
h1,h2,h3{text-wrap:balance}
.t-alpha{--tc:#df5338;--ts:#fbe4dd;--ti:#b23a26}
.t-beta{--tc:#cf871f;--ts:#f7e9cd;--ti:#9a6210}
.t-gamma{--tc:#1f9b78;--ts:#d4eee5;--ti:#136e56}
.t-delta{--tc:#7a5cc4;--ts:#e9e1f8;--ti:#583ea0}
.eyebrow{display:flex;align-items:center;gap:9px;margin-bottom:14px}
.eyebrow i{width:8px;height:8px;border-radius:50%;background:var(--dot,#df5338)}
.eyebrow b{font:700 12px 'Space Mono',monospace;letter-spacing:.14em;text-transform:uppercase;color:var(--lc,#8a7c64)}
.h2{font:800 40px/1.04 'Bricolage Grotesque',sans-serif;letter-spacing:-.03em;margin:0 0 14px}
.intro{font-size:15px;color:#5f5747;margin:0 0 28px;max-width:560px}
.sectintro{font-size:16px;color:#5f5747;margin:0 0 34px;max-width:620px}
header{padding:72px 0 36px}
.kicker{display:inline-flex;align-items:center;gap:9px;background:#2a2118;color:#f3ead9;font:700 11px/1 'Space Mono',monospace;letter-spacing:.14em;text-transform:uppercase;padding:9px 14px;border-radius:999px;margin-bottom:28px}
.kicker i{width:7px;height:7px;background:#df5338;border-radius:50%}
header h1{font:800 76px/.97 'Bricolage Grotesque',sans-serif;letter-spacing:-.035em;margin:0 0 22px;max-width:15ch}
.diamonds{display:flex;gap:8px;margin:0 0 22px}
.diamonds i{width:11px;height:11px;transform:rotate(45deg)}
.sub{font:700 13px/1.5 'Space Mono',monospace;letter-spacing:.04em;text-transform:uppercase;color:#9a8a6e;margin:0 0 20px}
.lede{max-width:600px;font-size:16px;line-height:1.62;color:#5f5747;margin:0}
.briefing{display:grid;grid-template-columns:1.1fr 1fr;gap:44px;align-items:start}
.note{font:400 12.5px/1.5 'Space Mono',monospace;color:#a8997d;margin:0 0 20px}
.facts{list-style:none;margin:0;padding:0}
.facts li{display:flex;gap:14px;padding:12px 0;border-bottom:1px solid #e2d6bd;align-items:start}
.facts .n{flex:none;width:26px;height:26px;border-radius:8px;background:#2a2118;color:#f3ead9;font:700 11px/26px 'Space Mono',monospace;text-align:center}
.facts .txt{font-size:14px;line-height:1.55;color:#4a4030}
.why{background:#fffdf7;border:2px solid #2a2118;border-radius:18px;padding:30px 32px;box-shadow:7px 7px 0 #df5338}
.why h3{font:700 24px/1.1 'Bricolage Grotesque',sans-serif;letter-spacing:-.02em;margin:0 0 18px}
.why p{font-size:15px;line-height:1.7;color:#4a4030;margin:0 0 16px}
.why p:last-child{margin:0}
.teams{display:grid;grid-template-columns:repeat(2,1fr);gap:26px}
.players{display:grid;grid-template-columns:repeat(3,1fr);gap:10px}
.chip{display:inline-block;background:var(--tc);color:#fff;border:2px solid #2a2118;border-radius:999px;padding:7px 16px;font:700 12px 'Space Mono',monospace;letter-spacing:.08em;text-transform:uppercase;box-shadow:3px 3px 0 #2a2118;margin-bottom:16px}
.chip.soft{background:var(--ts);color:var(--ti);box-shadow:none;padding:5px 14px;font-size:11px}
.pcard{background:#fffdf7;border:2px solid #2a2118;border-radius:14px;padding:14px 12px;box-shadow:3px 3px 0 var(--tc)}
.tok{display:flex;align-items:center;justify-content:center;width:40px;height:40px;border-radius:12px;background:var(--tc);color:#fff;font:800 15px 'Bricolage Grotesque',sans-serif;margin-bottom:12px}
.pname{font:700 15px/1.12 'Bricolage Grotesque',sans-serif;letter-spacing:-.01em;margin-bottom:8px}
.role{display:inline-block;background:var(--ts);color:var(--ti);font:600 10px/1.3 'Space Mono',monospace;padding:4px 8px;border-radius:999px}
.discard{position:relative;background:#ebe0c8;border:2px dashed #b8a988;border-radius:20px;padding:34px 32px 28px}
.stamp{position:absolute;top:-15px;right:26px;transform:rotate(-7deg);border:3px solid #c0492f;color:#c0492f;font:700 15px 'Space Mono',monospace;letter-spacing:.12em;padding:7px 15px;border-radius:8px;background:#f3ead9;box-shadow:2px 3px 0 rgba(42,33,24,.12)}
.discard .intro{color:#9a8556}
.clist{columns:3;column-gap:30px;list-style:none;margin:0;padding:0}
.clist li{break-inside:avoid;font-size:11.5px;line-height:1.42;color:#8f7d56;padding:4px 0;display:flex;gap:7px}
.clist i{color:#c0492f;font-weight:700;flex:none}
.dissent{font:400 12px/1.45 'Space Mono',monospace;color:#a08856;margin:18px 0 0}
.teamblock{margin-top:30px}
.fgrid{display:grid;grid-template-columns:repeat(3,1fr);gap:18px}
.fcard{background:#fffdf7;border:2px solid #2a2118;border-top:6px solid var(--tc);border-radius:14px;padding:20px;box-shadow:4px 4px 0 var(--tc)}
.fhead{display:flex;align-items:center;gap:10px;margin-bottom:14px}
.tok-sm{flex:none;display:flex;align-items:center;justify-content:center;width:34px;height:34px;border-radius:10px;background:var(--tc);color:#fff;font:800 13px 'Bricolage Grotesque',sans-serif}
.fname{font:700 15px/1.05 'Bricolage Grotesque',sans-serif;letter-spacing:-.01em}
.fmeta{font:400 10.5px/1.3 'Space Mono',monospace;color:var(--ti);margin-top:2px}
.fbody{font-size:12.5px;line-height:1.55;color:#534a39;margin:0}
.prod{background:#fffdf7;border:2px solid #2a2118;border-radius:18px;overflow:hidden;margin-bottom:20px;box-shadow:6px 6px 0 var(--tc)}
.prod-band{background:var(--ts);border-bottom:2px solid #2a2118;padding:14px 30px;display:flex;align-items:center;gap:8px;font:700 11px 'Space Mono',monospace;letter-spacing:.1em;text-transform:uppercase;color:var(--ti)}
.prod-band i{width:9px;height:9px;border-radius:50%;background:var(--tc)}
.prod-body{padding:30px 32px}
.codename{font:700 10px 'Space Mono',monospace;letter-spacing:.16em;text-transform:uppercase;color:var(--ti);margin-bottom:7px}
.pn{font:800 30px/1.02 'Bricolage Grotesque',sans-serif;letter-spacing:-.025em;margin:0 0 16px}
.lead{font-size:15px;line-height:1.68;color:#403728;margin:0 0 22px;max-width:66ch}
.cols{display:grid;grid-template-columns:1fr 1fr;gap:30px;padding-top:20px;border-top:2px solid #efe5d0}
.mlabel{font:700 11px 'Space Mono',monospace;letter-spacing:.1em;text-transform:uppercase;color:var(--ti);margin-bottom:9px}
.mtext{font-size:13.5px;line-height:1.6;color:#4a4030;margin:0}
.winbar{display:flex;align-items:center;gap:22px;background:#f4c542;border:3px solid #2a2118;border-radius:22px;padding:24px 30px;margin-bottom:26px;box-shadow:9px 9px 0 #2a2118}
.rosette{flex:none;display:flex;flex-direction:column;align-items:center;justify-content:center;width:72px;height:72px;border-radius:50%;background:#fffdf7;border:3px solid #2a2118;font:800 24px/.85 'Bricolage Grotesque',sans-serif;color:#2a2118}
.rosette i{font:700 10px 'Space Mono',monospace;letter-spacing:.05em}
.winlabel{font:700 11px 'Space Mono',monospace;letter-spacing:.14em;text-transform:uppercase;color:#8a6406;margin-bottom:4px}
.winname{font:800 46px/.96 'Bricolage Grotesque',sans-serif;letter-spacing:-.03em;color:#2a2118}
.winteam{font:700 11px 'Space Mono',monospace;letter-spacing:.08em;text-transform:uppercase;color:#8a6406;margin-top:5px}
.tally{background:#fffdf7;border:2px solid #2a2118;border-radius:18px;padding:24px 30px 12px;box-shadow:6px 6px 0 #2a2118}
.tally-h{display:flex;align-items:center;justify-content:space-between;padding-bottom:14px;border-bottom:2px solid #efe5d0;margin-bottom:4px}
.tally-h b{font:700 12px 'Space Mono',monospace;letter-spacing:.1em;text-transform:uppercase;color:#2a2118}
.tally-h span{font:600 11px 'Space Mono',monospace;color:#a8997d}
.trow{display:flex;align-items:center;gap:18px;padding:15px 0;border-bottom:1px solid #efe5d0}
.tinfo{flex:none;width:200px}
.tinfo .top{display:flex;align-items:center;gap:8px}
.tinfo .top i{flex:none;width:10px;height:10px;border-radius:50%;background:var(--tc)}
.tinfo .top b{font:700 17px/1 'Bricolage Grotesque',sans-serif;letter-spacing:-.01em}
.tinfo .top .star{font:700 11px 'Space Mono',monospace;color:#c79400}
.tinfo .tm{font:600 10px 'Space Mono',monospace;letter-spacing:.06em;text-transform:uppercase;color:var(--ti);margin-top:5px}
.bar{flex:1;height:16px;background:#efe5d0;border-radius:999px;overflow:hidden;border:1px solid #e2d6bd}
.bar i{display:block;height:100%;background:var(--tc);border-radius:999px}
.tv{flex:none;width:74px;text-align:right}
.tv b{font:800 22px 'Bricolage Grotesque',sans-serif}
.tv span{font:600 10px 'Space Mono',monospace;color:#a8997d}
.vnote{font:400 13px/1.5 'Space Mono',monospace;color:#a8997d;margin:0 0 22px}
.verdict{background:#2a2118;border:2px solid #2a2118;border-radius:18px;padding:36px 40px;box-shadow:7px 7px 0 #cf871f}
.verdict p{font-size:15.5px;line-height:1.78;color:#ece2cf;margin:0 0 18px;max-width:72ch}
.verdict p:last-child{margin:0}
footer{text-align:center;padding-top:20px}
footer p{font:700 11px 'Space Mono',monospace;letter-spacing:.08em;text-transform:uppercase;color:#a8997d;margin:0}
@media(max-width:720px){.briefing,.teams{grid-template-columns:1fr}.players,.fgrid,.clist{grid-template-columns:1fr;columns:1}.cols{grid-template-columns:1fr}header h1{font-size:48px}}
```

### Section Content Instructions

Write each section in the order below. Follow the content guidance exactly.

---

#### `<header>` — Hero

The dark pill kicker opens the page. Four coloured diamond shapes (one per team,
in Alpha → Beta → Gamma → Delta order) appear below the title as a visual accent.

```html
<header>
  <span class="kicker"><i></i>Game of Future · Session Record</span>
  <h1>[TOPIC]</h1>
  <div class="diamonds">
    <i style="background:#df5338"></i>
    <i style="background:#cf871f"></i>
    <i style="background:#1f9b78"></i>
    <i style="background:#7a5cc4"></i>
  </div>
  <p class="sub">A Game of Future session · [DATE]</p>
  <p class="lede">Game of Future is a structured foresight game where AI players produce independent forecasts, form teams, and design products grounded in plausible futures. This document is the record of one complete session.</p>
</header>
```

Substitute: `[TOPIC]` = session topic verbatim. `[DATE]` = human-readable date
(e.g. "June 17, 2026"). Translate all fixed strings to the session language.

---

#### `<section class="briefing">` — Brief + Why Now

**Left column — numbered facts:**
Extract 6–8 of the most concrete, specific facts and observed trends from
`briefing.md`. Use only the **Facts** and **Observed Trends** sections; do not
use Facilitator Inference. Prefer facts that contain numbers, named organisations,
or dates. Number sequentially as two-digit strings: `01`, `02`, etc.

The amber eyebrow dot (`--dot:#cf871f`) signals this section belongs to the
pre-game context.

**Right column — "Why this, why now" box:**
Write exactly 3 paragraphs. Each paragraph is exactly 2 sentences. The first
sentence states the point plainly. The second gives one concrete consequence or
example. No sentence should contain more than one independent clause. No
em-dashes, no parenthetical asides. Do not summarise the facts — reframe them.
Answer one question per paragraph: what has changed / why it matters now / what
the interesting tension is. A reader should absorb all three points in 20 seconds.

```html
<section class="briefing">
  <div>
    <div class="eyebrow" style="--dot:#cf871f"><i></i><b>Before play · The briefing</b></div>
    <p class="note">Briefing prepared at session start: [DATE]. Facts reflect the state of the topic at that time.</p>
    <ul class="facts">
      <li><span class="n">01</span><span class="txt">…</span></li>
      <li><span class="n">02</span><span class="txt">…</span></li>
      <!-- up to 08 -->
    </ul>
  </div>
  <div class="why">
    <h3>Why this, why now</h3>
    <p>…</p>
    <p>…</p>
    <p>…</p>
  </div>
</section>
```

---

#### `<section>` — Players

From `roster.md`. The `.teams` grid holds one div per team (2×2 for 4 teams).
Each team div gets the team colour class (`.t-alpha`, etc.). Inside, a `.chip`
pill names the team. The `.players` grid holds one `.pcard` per player.

Each `.pcard` contains:
- `.tok` — two-letter initials (see Player Initials Tokens rule above)
- `.pname` — player display name
- `.role` — profile label, lowercase

```html
<section>
  <div class="eyebrow" style="--dot:#1f9b78"><i></i><b>The players · [N] across [T] teams</b></div>
  <p class="intro" style="max-width:540px">[N] AI players, each with a distinct background and worldview, distributed across [T] teams.</p>
  <div class="teams">

    <div class="t-alpha">
      <span class="chip">Team Alpha</span>
      <div class="players">
        <div class="pcard">
          <span class="tok">[XX]</span>
          <div class="pname">[Player Name]</div>
          <span class="role">[profile label]</span>
        </div>
        <!-- two more pcard for this team -->
      </div>
    </div>

    <div class="t-beta">…</div>
    <div class="t-gamma">…</div>
    <div class="t-delta">…</div>

  </div>
</section>
```

---

#### `<section class="discard">` — Clichés (Discard Pile)

Rough parchment styling with a rotated "DISCARDED" stamp. Extract the accepted
cliché list from `report.md` or `public-room.md`. Do not include dissented items.
Each `<li>` has a `<i>✕</i>` icon element followed by a `<span>` with the text.

The eyebrow uses muted amber (`--dot:#b07a3a; --lc:#a08856`). Translate the
stamp text, eyebrow label, intro, and dissent note to the session language.

```html
<section class="discard">
  <span class="stamp">DISCARDED</span>
  <div class="eyebrow" style="--dot:#b07a3a;--lc:#a08856"><i></i><b>Round 0 · The discard pile</b></div>
  <p class="intro">The obvious futures the game throws out before play begins. Any product that merely instantiated one of these was disqualified on sight.</p>
  <ol class="clist">
    <li><i>✕</i><span>…</span></li>
    <!-- one li per accepted cliché -->
  </ol>
  <p class="dissent">N ideas were too interesting to dismiss — they became forecast territory instead.</p>
</section>
```

Omit `<p class="dissent">` if no items were dissented.

---

#### `<section>` — Forecasts

Group forecast cards by team. Each team block (`.teamblock`) gets the team colour
class and contains a `.chip.soft` team label plus a `.fgrid` of three `.fcard`
elements.

For each card:
- `.tok-sm` — two-letter initials token
- `.fname` — player display name
- `.fmeta` — profile label in lowercase
- `.fbody` — **Write a fresh 2–3 sentence distillation in your own words.** Do
  not copy text from `report.md` verbatim. Capture: what the player predicted and
  the core causal logic behind it. Target 50–80 words.

```html
<section>
  <div class="eyebrow" style="--dot:#7a5cc4"><i></i><b>Round 1 · The forecasts</b></div>
  <p class="intro" style="margin-bottom:8px">Each player produced one independent forecast before teams were formed. These are the raw materials the products are built from.</p>

  <div class="teamblock t-alpha">
    <span class="chip soft">Team Alpha</span>
    <div class="fgrid">
      <article class="fcard">
        <div class="fhead">
          <span class="tok-sm">[XX]</span>
          <div>
            <div class="fname">[Player Name]</div>
            <div class="fmeta">[profile label]</div>
          </div>
        </div>
        <p class="fbody">…</p>
      </article>
      <!-- two more fcard for this team -->
    </div>
  </div>

  <div class="teamblock t-beta">…</div>
  <div class="teamblock t-gamma">…</div>
  <div class="teamblock t-delta">…</div>
</section>
```

---

#### `<section>` — Products ← PRIMARY SECTION

Show all products in descending vote order (winner first). Each product is a
full-width `.prod` article. Apply the team colour class directly to the `.prod`
element.

The `.prod-band` is the coloured header strip with a team dot and team label.
The `.prod-body` contains:
- `.codename` — the fixed label "Product codename" (translate to session language)
- `.pn` — the product name
- `.lead` — **Write 3–4 sentences in plain language for a curious outsider who
  has never worked in the relevant specialist domain.** Do not copy from
  `report.md`. Do not use jargon. Ground every abstract claim in a concrete
  scenario.
- `.cols` — two-column footer with:
  - Left: `.mlabel` "For" + `.mtext` (who pays, in plain terms)
  - Right: `.mlabel` "Why it works" + `.mtext` — one sentence explaining why the
    product depends on both retained forecasts. Avoid the word "forecast" — say
    "prediction" or "bet" if you need a synonym.

```html
<section>
  <div class="eyebrow" style="--dot:#df5338;--lc:#c0492f"><i></i><b>Round 2 · The build — four contestants</b></div>
  <h2 class="h2" style="max-width:20ch">Four products, each built from the intersection of two forecasts.</h2>
  <p class="sectintro">Each team discarded one of their three assigned forecasts and designed a product that only works when the remaining two are combined. These are the four contestants.</p>

  <!-- Winner first, then remaining in descending vote order -->
  <article class="prod t-[teamname]">
    <div class="prod-band"><i></i>Team [Name]</div>
    <div class="prod-body">
      <div class="codename">Product codename</div>
      <div class="pn">[Product Name]</div>
      <p class="lead">…</p>
      <div class="cols">
        <div>
          <div class="mlabel">For</div>
          <p class="mtext">…</p>
        </div>
        <div>
          <div class="mlabel">Why it works</div>
          <p class="mtext">…</p>
        </div>
      </div>
    </div>
  </article>

  <!-- Repeat article for each remaining product -->
</section>
```

---

#### `<section>` — Vote

Show the winner bar first, then the full tally box. Total votes cast = player
count × 2.

**Winner bar:** Rosette shows the winner's vote count (large) and "1ST" label
(small, inside `.rosette i`). The text to the right shows the winning product
name and team.

**Tally box:** One `.trow` per product in descending vote order. Apply the team
colour class to each `.trow`. The winner row includes `<span class="star">★</span>`
after the product name. Bar fill = vote percentage of winner's count.

```html
<section>
  <div class="eyebrow" style="--dot:#cf871f"><i></i><b>Round 3 · The vote — main event</b></div>
  <h2 class="h2" style="max-width:18ch">And the players chose…</h2>
  <p class="sectintro">Once the pitches were in, every player privately cast two votes — for products built by other teams, never their own. [TOTAL] votes in total, and one clear result.</p>

  <div class="winbar">
    <span class="rosette">[N]<i>1ST</i></span>
    <div>
      <div class="winlabel">★ Winner · [N] of [TOTAL] votes</div>
      <div class="winname">[Winning Product Name]</div>
      <div class="winteam">Team [Name]</div>
    </div>
  </div>

  <div class="tally">
    <div class="tally-h"><b>Final tally</b><span>[PLAYER_COUNT] players · 2 votes each · [TOTAL] cast</span></div>

    <!-- One trow per product, descending vote order -->
    <div class="trow t-[teamname]">
      <div class="tinfo">
        <div class="top"><i></i><b>[Product Name]</b><span class="star">★</span></div>
        <!-- Remove the star span on non-winner rows -->
        <div class="tm">Team [Name]</div>
      </div>
      <div class="bar"><i style="width:[PCT]%"></i></div>
      <div class="tv"><b>[N]</b><span> votes</span></div>
    </div>

  </div>
</section>
```

---

#### `<section style="margin-bottom:40px">` — Verdict

From the Non-Binding Facilitator Analysis in `report.md`. **Do not reproduce all
subsections.** Select the 3–4 most interesting observations and **rewrite them as
flowing prose paragraphs** inside the dark `.verdict` card. No headers. No bullet
points. Target: 200–280 words across 2–3 paragraphs.

```html
<section style="margin-bottom:40px">
  <div class="eyebrow" style="--dot:#2a2118"><i></i><b>Final whistle · The verdict</b></div>
  <p class="vnote">Non-binding commentary — this is the facilitator's read, not a player verdict.</p>
  <div class="verdict">
    <p>…</p>
    <p>…</p>
    <p>…</p>
  </div>
</section>
```

---

#### `<footer>` — Footer

```html
<footer>
  <p>Session [SESSION-ID] · [DATE] · Generated by Game of Future</p>
</footer>
```

---

## Step 4 — Open the File

After writing `report.html`, open it in the default browser:

- Linux: `xdg-open [full-path-to-report.html]`
- macOS: `open [full-path-to-report.html]`

Then report to the user: "report.html written to [path] and opened in browser."
