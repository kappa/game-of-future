# Game of Future Cliche Phase Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Update Phase 3 so AI games run a fast cliche shout round plus a lightweight dissent pass, producing short cliche forecasts instead of nuanced baseline constraints.

**Architecture:** This is a documentation-skill behavior change, not a runtime change. Update the canonical rules, facilitation prompt text, public-room template, and top-level workflow summary so every future facilitator sees the same two-mini-round structure. Verification uses static assertions, installed-skill diffing, and one phase-limited development smoke test.

**Tech Stack:** Codex skill Markdown, session-template Markdown, `rg`, `diff`, `quick_validate.py`, Git.

---

## File Structure

- `skills/game-of-future/references/rules.md`: canonical Phase 3 mechanics and adjudication rubric.
- `skills/game-of-future/references/facilitation.md`: exact player prompts for the fast shout round and light dissent pass.
- `skills/game-of-future/assets/session-template/public-room.md`: public artifact headings for the two mini-rounds.
- `skills/game-of-future/SKILL.md`: concise workflow summary so the top-level skill matches the references.
- `/home/kappa/.codex/skills/game-of-future/`: installed copy to sync after source changes.
- `game-of-future/sessions/<new-test-session>/`: retained smoke-test artifacts for behavior review.

## Task 1: Confirm The Current Failure Pattern

**Files:**
- Read: `game-of-future/sessions/20260614T180958Z-neighborhood-delivery-services-in-2030/public-room.md`
- Read: `game-of-future/sessions/20260615T050351Z-local-ai-assistants-in-professional-work/public-room.md`
- Read: `docs/superpowers/specs/2026-06-16-game-of-future-cliche-phase-redesign.md`

- [ ] **Step 1: Reproduce the two observed extremes**

Run:

```bash
rg -n 'Accepted clichés: none|Removed: "Drones|No challenges were submitted|All 36 signed assumptions' \
  game-of-future/sessions/20260614T180958Z-neighborhood-delivery-services-in-2030/public-room.md \
  game-of-future/sessions/20260615T050351Z-local-ai-assistants-in-professional-work/public-room.md
```

Expected: output includes the first session accepting no cliches and the second
session recording no challenges plus all 36 assumptions retained.

- [ ] **Step 2: Verify the approved spec exists**

Run:

```bash
rg -n 'Fast Shout Round|Light Dissent Pass|short cliche forecasts|not a nuanced baseline' \
  docs/superpowers/specs/2026-06-16-game-of-future-cliche-phase-redesign.md
```

Expected: output shows all four phrases in the approved spec.

- [ ] **Step 3: Verify the source does not already contain the new mechanics**

Run:

```bash
if rg -n 'Fast Shout Round|Light Dissent Pass|Fast cliche shout round|Light dissent pass' \
  skills/game-of-future; then
  exit 1
fi
```

Expected before implementation: exit `0` with no output. If this command prints
matches, inspect them before continuing because part of the change has already
been applied.

## Task 2: Update Canonical Rules

**Files:**
- Modify: `skills/game-of-future/references/rules.md`

- [ ] **Step 1: Replace the Phase 3 section**

In `skills/game-of-future/references/rules.md`, replace the entire section from
`## Phase 3: Public Cliche Round` through the paragraph ending
`Forecasts must not repeat the final cliché list.` with:

```markdown
## Phase 3: Public Cliche Round

Run a fast, lightweight cliche phase in two mini-rounds. The goal is to strike
out short, obvious, boring, ridiculous, or game-ending futures before serious
forecasting begins. Do not turn this phase into a strategy brief or a nuanced
baseline-constraints exercise.

### Fast Shout Round

Run players sequentially. Give each player the current public cliche candidate
list. Each player adds one to three short cliche forecasts: obvious defaults,
lazy assumptions, boring futures, ridiculous extremes, or totalizing scenarios
that would make the game uninteresting.

Good candidates are terse, for example:

- AI does everything.
- Privacy is solved because it is local.
- Nobody trusts it.
- Everything gets regulated away.
- A giant breach kills the market.
- Nothing changes because institutions are slow.
- The cloud wins anyway.
- Global war makes this irrelevant.

Reject or rephrase careful baseline constraints that are useful but not
cliches, such as "workflow integration will matter more than conversational
polish," unless they are rewritten as tired forecasts.

### Light Dissent Pass

Run players sequentially again. Give each player the candidate list and any
existing dissent. A player may challenge only items they believe are not
actually common, obvious, boring, or game-ending. Dissent is optional and must
be one sentence per challenged item. Do not run debate, forecasting, or product
ideation in this pass.

### Adjudication

Keep candidates by default. Remove an item only when significant dissent shows
that it is contested rather than common. Merge duplicates and near-duplicates.
Rephrase long or nuanced items into short cliche form when the intent is clear.
Keep the final list compact enough to guide forecasts without becoming a full
strategy brief. Record removed items, major merges, and facilitator decisions.
Forecasts must not repeat the final cliche list.
```

- [ ] **Step 2: Verify the new canonical mechanics are present**

Run:

```bash
rg -n 'Fast Shout Round|Light Dissent Pass|Keep candidates by default|not repeat the final cliche list' \
  skills/game-of-future/references/rules.md
```

Expected: all four phrases are found.

- [ ] **Step 3: Commit the rules change**

Run:

```bash
git add skills/game-of-future/references/rules.md
git commit -m "fix: define fast cliche shout rules"
```

Expected: commit succeeds.

## Task 3: Update Facilitation Prompts

**Files:**
- Modify: `skills/game-of-future/references/facilitation.md`

- [ ] **Step 1: Replace the Public Cliche Prompt section**

In `skills/game-of-future/references/facilitation.md`, replace the section from
`## Public Cliche Prompt` through the final sentence before
`## Forecast Prompt` with:

````markdown
## Public Cliche Shout Prompt

Prepend the exact Player Turn Guard block above, then send players
sequentially:

```text
Read only `<briefing-path>` and `<public-room-path>`.
Write only `<public-room-path>`.

Fast cliche shout round. Add 1-3 short cliche forecasts for this topic:
obvious defaults, lazy assumptions, boring futures, ridiculous extremes, or
game-ending scenarios the room should strike out before forecasting. Keep each
item short. Do not write nuanced analysis, baseline constraints, product
ideas, or serious forecasts.

Append your signed contribution only to `Cliche Shout Round` in
`<public-room-path>`, preserve existing content, and write to no other file.
Reply with a one-line completion notice.
```

After all shout turns, run the light dissent pass.

## Public Cliche Dissent Prompt

Prepend the exact Player Turn Guard block above, then send players
sequentially:

```text
Read only `<public-room-path>`.
Write only `<public-room-path>`.

Light dissent pass. Review the candidate cliches in `Cliche Shout Round` and
the existing entries in `Light Dissent Pass`. Challenge only items that are not
actually common, obvious, boring, or game-ending. One sentence per challenge.
Do not debate, improve, forecast, or add new cliche candidates.

If you have no dissent, append one signed line saying `No dissent.` to
`Light Dissent Pass`. Otherwise append only your signed dissent entries to
`Light Dissent Pass`. Preserve existing content and write to no other file.
Reply with a one-line completion notice.
```

After all dissent turns, adjudicate candidates according to
`references/rules.md`, merge near-duplicates, rephrase long candidates into
short cliche form when possible, and record the accepted cliche list in
`Final Cliche List`.
The facilitator replaces every angle-bracketed token with concrete absolute
paths.
````

- [ ] **Step 2: Verify both prompts are present**

Run:

```bash
rg -n 'Public Cliche Shout Prompt|Public Cliche Dissent Prompt|Fast cliche shout round|Light dissent pass|No dissent' \
  skills/game-of-future/references/facilitation.md
```

Expected: all five phrases are found.

- [ ] **Step 3: Verify the old generic wording is gone**

Run:

```bash
if rg -n 'assumptions that are genuinely obvious|You may instead challenge an existing item' \
  skills/game-of-future/references/facilitation.md; then
  exit 1
fi
```

Expected: exit `0` with no output.

- [ ] **Step 4: Commit the facilitation change**

Run:

```bash
git add skills/game-of-future/references/facilitation.md
git commit -m "fix: split cliche phase prompts"
```

Expected: commit succeeds.

## Task 4: Update Session Template And Top-Level Workflow

**Files:**
- Modify: `skills/game-of-future/assets/session-template/public-room.md`
- Modify: `skills/game-of-future/SKILL.md`

- [ ] **Step 1: Update public room headings**

In `skills/game-of-future/assets/session-template/public-room.md`, replace:

```markdown
## Cliché Contributions

## Challenges

## Final Cliché List
```

with:

```markdown
## Cliche Shout Round

## Light Dissent Pass

## Final Cliche List
```

- [ ] **Step 2: Update the top-level workflow summary**

In `skills/game-of-future/SKILL.md`, replace workflow item 3:

```markdown
3. Run the sequential public cliché round with challenges.
```

with:

```markdown
3. Run the fast public cliche shout round, light dissent pass, and final cliche
   adjudication.
```

- [ ] **Step 3: Verify template and workflow wording**

Run:

```bash
rg -n 'Cliche Shout Round|Light Dissent Pass|Final Cliche List' \
  skills/game-of-future/assets/session-template/public-room.md
rg -n 'fast public cliche shout round, light dissent pass' \
  skills/game-of-future/SKILL.md
```

Expected: the first command finds all three public-room headings; the second
finds the new workflow sentence.

- [ ] **Step 4: Commit template and workflow updates**

Run:

```bash
git add skills/game-of-future/assets/session-template/public-room.md skills/game-of-future/SKILL.md
git commit -m "fix: update cliche phase artifacts"
```

Expected: commit succeeds.

## Task 5: Static Verification And Installed Skill Sync

**Files:**
- Source: `skills/game-of-future/`
- Install target: `/home/kappa/.codex/skills/game-of-future/`

- [ ] **Step 1: Run static skill validation**

Run:

```bash
python /home/kappa/.codex/skills/.system/skill-creator/scripts/quick_validate.py \
  skills/game-of-future
if rg -n '\b(T[O]DO|F[I]XME|T[B]D|implement[[:space:]]+later)\b' \
  skills/game-of-future; then
  exit 1
fi
test ! -d skills/game-of-future/scripts
test "$(rg -c '^## Player:' skills/game-of-future/references/default-players.md)" -eq 12
test "$(find skills/game-of-future/assets/session-template -type f | wc -l)" -eq 9
git diff --check
```

Expected: validator prints `Skill is valid!`; every other assertion exits `0`.

- [ ] **Step 2: Sync the installed skill**

Run with approval if the sandbox blocks writing outside the repository:

```bash
rsync -a --delete skills/game-of-future/ /home/kappa/.codex/skills/game-of-future/
```

Expected: command exits `0`.

- [ ] **Step 3: Verify installed copy matches source**

Run:

```bash
diff -ru skills/game-of-future /home/kappa/.codex/skills/game-of-future
```

Expected: no output.

- [ ] **Step 4: Commit any sync-related source corrections**

Run:

```bash
git status --short
```

Expected: no tracked source changes remain. If tracked source files changed
during static verification, commit them with:

```bash
git add skills/game-of-future
git commit -m "fix: finalize cliche phase docs"
```

Expected when no source files changed: do not create an empty commit.

## Task 6: Focused Phase 3 Smoke Test

**Files:**
- Generated: `game-of-future/sessions/<timestamp>-workplace-learning-in-2030/`

- [ ] **Step 1: Start a phase-limited development game**

Invoke the installed skill explicitly with this request:

```text
Use $game-of-future.
Topic: workplace learning in 2030.
Control mode: development.
Roster: 4 players in two teams, Codex-only.
Shared briefing only; no independent research.
Stop after the cliche phase.
```

Expected: the facilitator records that the undersized roster is phase-limited,
runs setup and the cliche phase, and pauses after Phase 3.

- [ ] **Step 2: Verify the new artifact shape**

Set the session path:

```bash
SESSION="$(find game-of-future/sessions -mindepth 1 -maxdepth 1 -type d \
  -name '*-workplace-learning-in-2030' | sort | tail -1)"
test -n "$SESSION"
```

Then run:

```bash
rg -n '^## Cliche Shout Round$|^## Light Dissent Pass$|^## Final Cliche List$' \
  "$SESSION/public-room.md"
```

Expected: all three headings are present.

- [ ] **Step 3: Verify cliche candidates are short enough for the intended feel**

Run:

```bash
awk '
  /^## Cliche Shout Round$/ { in_section=1; next }
  /^## Light Dissent Pass$/ { in_section=0 }
  in_section && /^-/ {
    count++;
    words=split($0, parts, /[[:space:]]+/);
    if (words > 18) {
      printf "long candidate: %s\n", $0;
      long++;
    }
  }
  END {
    if (count < 4) {
      printf "too few candidates: %d\n", count;
      exit 2;
    }
    if (long > 0) {
      exit 3;
    }
    printf "candidate_count=%d\n", count;
  }
' "$SESSION/public-room.md"
```

Expected: prints `candidate_count=<number>` and exits `0`.

- [ ] **Step 4: Verify the phase did not become a 30-item baseline brief**

Run:

```bash
final_count="$(awk '
  /^## Final Cliche List$/ { in_section=1; next }
  /^## Team Presentations$/ { in_section=0 }
  in_section && (/^- / || /^[0-9]+[.]/) { count++ }
  END { print count + 0 }
' "$SESSION/public-room.md")"
test "$final_count" -ge 1
test "$final_count" -le 15
printf 'final_cliche_count=%s\n' "$final_count"
```

Expected: `final_cliche_count` is between 1 and 15.

- [ ] **Step 5: Verify the dissent pass ran**

Run:

```bash
rg -n 'No dissent|Challenge|challenge|dissent' "$SESSION/public-room.md"
rg -n 'dissent pass|Light Dissent Pass|Phase 3' "$SESSION/session.md"
```

Expected: the public room records dissent-pass entries or explicit `No
dissent` lines, and `session.md` records Phase 3 completion.

- [ ] **Step 6: Record smoke result in final response**

Do not commit generated session artifacts. They are ignored runtime artifacts.
Report the session path and the Phase 3 validation results in the final
implementation response.

## Task 7: Final Verification

**Files:**
- Source: `skills/game-of-future/`
- Install target: `/home/kappa/.codex/skills/game-of-future/`

- [ ] **Step 1: Re-run static verification**

Run:

```bash
python /home/kappa/.codex/skills/.system/skill-creator/scripts/quick_validate.py \
  skills/game-of-future
diff -ru skills/game-of-future /home/kappa/.codex/skills/game-of-future
git diff --check
git status --short --branch
```

Expected: validator prints `Skill is valid!`; diff has no output; diff check
has no output; git status shows only ignored runtime artifacts, or a clean
tracked tree.

- [ ] **Step 2: Report commits and verification**

Final response must include:

- source commits created for the implementation;
- installed-copy diff result;
- static validator result;
- focused Phase 3 smoke-test path;
- whether the cliche candidates were short, whether the dissent pass ran, and
  final cliche count.
