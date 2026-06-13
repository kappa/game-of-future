# Game of Future Skill Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build, validate, install, and forward-test a prompt-driven `game-of-future` Codex skill that runs persistent multi-agent foresight games and retains complete plain-text session artifacts.

**Architecture:** Keep the version-controlled source in `skills/game-of-future/` and install a verified copy into `${CODEX_HOME:-$HOME/.codex}/skills/game-of-future/`. The active Codex agent is the facilitator; player profiles, provider guidance, canonical rules, and facilitation policy live in focused Markdown references, while copyable Markdown assets define every retained session artifact. No custom runtime or orchestration script is introduced.

**Tech Stack:** Codex skills (`SKILL.md`, `agents/openai.yaml`), Markdown references and templates, native `multi_agent_v1` subagents, optional project-defined external AI commands, Git, shell assertions, and the official `skill-creator` validator.

---

## File Structure

Create or modify these files:

- `.gitignore`: ignore editor swap files and generated game sessions.
- `skills/game-of-future/SKILL.md`: concise trigger and facilitator workflow.
- `skills/game-of-future/agents/openai.yaml`: user-facing skill metadata.
- `skills/game-of-future/references/rules.md`: canonical phase rules and quality gates.
- `skills/game-of-future/references/registries.md`: registry precedence, schemas, roster selection, and temporary-profile policy.
- `skills/game-of-future/references/default-players.md`: 12 reusable, provider-neutral player profiles.
- `skills/game-of-future/references/default-providers.md`: native Codex provider and external-command compatibility contract.
- `skills/game-of-future/references/facilitation.md`: prompts, control modes, research, file coordination, failures, and reporting.
- `skills/game-of-future/assets/session-template/session.md`: facilitator ledger.
- `skills/game-of-future/assets/session-template/roster.md`: roster and persistent-session handles.
- `skills/game-of-future/assets/session-template/briefing.md`: shared research briefing.
- `skills/game-of-future/assets/session-template/public-room.md`: public announcements, clichés, pitches, and results.
- `skills/game-of-future/assets/session-template/errors.md`: failure and recovery log.
- `skills/game-of-future/assets/session-template/report.md`: final report.
- `skills/game-of-future/assets/session-template/forecasts/player.md`: per-player forecast.
- `skills/game-of-future/assets/session-template/teams/team.md`: shared team room.
- `skills/game-of-future/assets/session-template/votes/player.md`: private ballot.

Do not create runtime scripts. Generated sessions belong under
`game-of-future/sessions/` and remain outside version control.

### Task 1: Initialize The Skill Source

**Files:**
- Create: `skills/game-of-future/`
- Create: `skills/game-of-future/agents/openai.yaml`
- Create: `skills/game-of-future/references/`
- Create: `skills/game-of-future/assets/`
- Create: `.gitignore`

- [ ] **Step 1: Verify the skill source does not already exist**

Run:

```bash
test ! -e skills/game-of-future
```

Expected: exit `0`. If the path exists, stop and inspect it instead of
overwriting it.

- [ ] **Step 2: Run the official skill initializer**

Run:

```bash
python /home/kappa/.codex/skills/.system/skill-creator/scripts/init_skill.py \
  game-of-future \
  --path skills \
  --resources references,assets \
  --interface display_name='Game of Future' \
  --interface short_description='Run persistent multi-agent foresight games' \
  --interface default_prompt='Use $game-of-future to run a Game of Future session on my supplied topic.'
```

Expected: output confirms creation of `skills/game-of-future`, `SKILL.md`,
`agents/openai.yaml`, `references/`, and `assets/`.

- [ ] **Step 3: Add repository ignores**

Create `.gitignore` with:

```gitignore
*.swp
game-of-future/sessions/
```

- [ ] **Step 4: Verify initializer output and metadata**

Run:

```bash
test -f skills/game-of-future/SKILL.md
test -f skills/game-of-future/agents/openai.yaml
test -d skills/game-of-future/references
test -d skills/game-of-future/assets
rg -n 'display_name: "Game of Future"' skills/game-of-future/agents/openai.yaml
rg -F 'default_prompt: "Use $game-of-future' skills/game-of-future/agents/openai.yaml
```

Expected: every command exits `0`.

Do not commit the generated placeholder `SKILL.md`; replace it in Task 2 first.

### Task 2: Write The Core Skill Workflow

**Files:**
- Modify: `skills/game-of-future/SKILL.md`

- [ ] **Step 1: Prove the generated skill still contains placeholders**

Run:

```bash
rg -n 'T[O]DO|Structuring This Skill' skills/game-of-future/SKILL.md
```

Expected: at least one match.

- [ ] **Step 2: Replace `SKILL.md` with the complete workflow**

Use this content:

```markdown
---
name: game-of-future
description: Run an autonomous or phase-gated Game of Future foresight simulation with a separate facilitator and persistent AI player sessions. Use when the user supplies a topic and wants multiple personality-driven agents, optionally across different providers, to remove clichés, create plausible forecasts, form teams, invent products from randomized forecast intersections, present them, vote, and retain complete plain-text artifacts.
---

# Game of Future

Run a structured foresight game using persistent, independent player sessions.
Optimize for surprising product concepts grounded in plausible, strategically
useful forecasts.

## Required Input

Require a user-supplied topic. Accept optional roster constraints, control mode,
and research policy.

Use these defaults when omitted:

- 12 players in four teams of three
- autonomous mode
- shared briefing
- no independent player research
- two votes per player for other teams

Do not refine, replace, or autonomously choose the topic.

## Load Instructions

Before setup:

1. Read `references/rules.md`.
2. Read `references/registries.md`.
3. Read `references/default-players.md`.
4. Read `references/default-providers.md`.
5. Read `references/facilitation.md`.

Resolve project overrides from `game-of-future/registry/` as described in
`references/registries.md`.

## Non-Negotiable Model

- Act as the facilitator; do not create a separate facilitator subagent.
- Give every player a distinct persistent private session.
- Keep personality profiles independent from provider bindings.
- Use a separate shared Markdown room for each team.
- Use plain-text prompts, responses, registries, and artifacts.
- Do not introduce a custom orchestration program or encoded wire format.
- Treat context reconstruction as a user-approved last resort.
- Pause when a persistent player cannot be resumed. Never silently replace,
  remove, recreate, or impersonate a failed player.

## Session Setup

Create:

`game-of-future/sessions/<timestamp>-<topic-slug>/`

Copy every file from `assets/session-template/` while preserving its directory
structure. Instantiate one forecast and one ballot file per player and one
shared room per team; remove the copied `player.md` and `team.md` template
filenames after instantiation. Replace the documented template variables as
the game progresses. Record current phase, random choices, session handles,
and facilitator decisions in the artifacts.

In development mode, pause after setup and after every phase. In autonomous
mode, continue unless a failure or genuine ambiguity requires user input.

## Workflow

Run these phases in order:

1. Resolve registries, select a diverse roster, bind providers, and start
   persistent player sessions.
2. Prepare the shared factual briefing.
3. Run the sequential public cliché round with challenges.
4. Collect one private forecast from every player and enforce the forecast
   quality gate.
5. Form teams and randomly assign three forecasts per team.
6. Coordinate turn-based collaboration through each team's shared file.
7. Publish concise team pitches and allow limited clarification.
8. Collect two private votes per player for other teams.
9. Tally official player votes and add separate non-binding facilitator
   analysis.
10. Verify artifacts and complete `report.md`.

Follow the detailed mechanics in `references/rules.md` and the operational
prompts and failure behavior in `references/facilitation.md`.

## Completion Gate

Do not mark a game complete until:

- every selected player has a persistent session or the user approved an
  explicit exception;
- every phase is recorded in `session.md`;
- every player has a forecast and valid ballot;
- every team has a shared room and structured pitch;
- products genuinely combine two assigned forecasts;
- vote totals exclude own-team votes;
- `errors.md` records all failures and user decisions;
- `report.md` distinguishes official votes from facilitator commentary.
```

- [ ] **Step 3: Validate frontmatter and placeholder removal**

Run:

```bash
python /home/kappa/.codex/skills/.system/skill-creator/scripts/quick_validate.py \
  skills/game-of-future
! rg -n 'T[O]DO|F[I]XME|Structuring This Skill' skills/game-of-future/SKILL.md
```

Expected:

```text
Skill is valid!
```

The second command exits `0` with no output.

- [ ] **Step 4: Commit the scaffold and core workflow**

```bash
git add .gitignore skills/game-of-future/SKILL.md skills/game-of-future/agents/openai.yaml
git commit -m "feat: scaffold Game of Future skill"
```

### Task 3: Add Canonical Game Rules

**Files:**
- Create: `skills/game-of-future/references/rules.md`

- [ ] **Step 1: Verify the rules reference is absent**

Run:

```bash
test ! -f skills/game-of-future/references/rules.md
```

Expected: exit `0`.

- [ ] **Step 2: Create the canonical rules**

Create `skills/game-of-future/references/rules.md` with:

```markdown
# Canonical Game Rules

## Purpose

Produce surprising product hypotheses from plausible near-future forecasts.
The game is a structured imagination exercise, not precise prediction or final
strategy.

## Phase 1: Setup

Require a user-supplied topic. Apply user roster constraints before defaults.
Create a diverse roster and persistent sessions before any player contribution.
Record the roster and all random decisions.

## Phase 2: Shared Briefing

Prepare a compact, cited baseline of present facts and established trends.
Avoid forecasts and product recommendations in the briefing. Mark inference
as inference. If independent research is enabled, require players to cite it
in their artifacts.

## Phase 3: Public Cliché Round

Run players sequentially. Give each player the current public list. A player
may add obvious assumptions, challenge an item as non-obvious, or support a
challenge.

Keep an item when it is broadly treated as obvious. Remove it when meaningful
disagreement shows it is not common knowledge. Record the challenge and the
facilitator decision. Forecasts must not repeat the final cliché list.

## Phase 4: Individual Forecasts

Each player privately writes one forecast:

- What will happen?
- Why will it happen?
- When will it happen?

Accept a forecast only when it is:

- within the supplied topic;
- distinct from accepted clichés;
- concrete and understandable;
- plausible rather than arbitrary science fiction;
- causally grounded in facts, trends, or highly reliable assumptions;
- normally three to five years away, or explicitly justified otherwise.

Request one focused revision when a forecast fails. Pause only if repeated
failure makes a valid game impossible.

## Phase 5: Teams And Random Assignment

Default to four teams of three. Prefer teams with varied expertise, worldview,
risk tolerance, creative style, and provider when available.

Randomly assign three forecasts to each team. Record the assignment before
collaboration. Each team may discard one forecast and must retain two.

## Phase 6: Product Design

Require the product to depend materially on the intersection of both retained
forecasts. Reject concepts that would be unchanged if either forecast were
removed.

Every product must state:

- name;
- core idea;
- target audience;
- underlying need;
- unique value;
- where and how it is used;
- what prevents it from existing now;
- first implementation step;
- why the team considers it important.

## Phase 7: Presentations

Publish one concise pitch per team. Permit only limited clarification
questions. Prevent extended debate before voting.

## Phase 8: Voting

Each player privately votes for exactly two projects from other teams. Reject
and correct ballots that include the player's own team or duplicate one choice.
Player votes are the official result.

## Phase 9: Facilitator Analysis

After tallying votes, separately assess:

- originality;
- forecast plausibility;
- strategic usefulness;
- strength of the forecast intersection;
- promising concepts that voting may have undervalued.

Label this analysis non-binding.

## Exclusions

Do not run or imitate the optional gesture or sign-language phase. Do not claim
forecast certainty, product validation, or a final strategic decision.
```

- [ ] **Step 3: Verify every phase and exclusion is present**

Run:

```bash
for heading in \
  'Phase 1: Setup' \
  'Phase 2: Shared Briefing' \
  'Phase 3: Public Cliché Round' \
  'Phase 4: Individual Forecasts' \
  'Phase 5: Teams And Random Assignment' \
  'Phase 6: Product Design' \
  'Phase 7: Presentations' \
  'Phase 8: Voting' \
  'Phase 9: Facilitator Analysis' \
  'Exclusions'
do
  rg -F "## $heading" skills/game-of-future/references/rules.md
done
```

Expected: one matching heading per loop iteration.

- [ ] **Step 4: Commit the canonical rules**

```bash
git add skills/game-of-future/references/rules.md
git commit -m "feat: define Game of Future rules"
```

### Task 4: Add Registry Semantics And Default Players

**Files:**
- Create: `skills/game-of-future/references/registries.md`
- Create: `skills/game-of-future/references/default-players.md`

- [ ] **Step 1: Verify registry references are absent**

Run:

```bash
test ! -f skills/game-of-future/references/registries.md
test ! -f skills/game-of-future/references/default-players.md
```

Expected: both commands exit `0`.

- [ ] **Step 2: Create registry semantics**

Create `skills/game-of-future/references/registries.md` with:

````markdown
# Registries

## Resolution

Read skill defaults first, then merge project files from:

`game-of-future/registry/`

Supported project files:

- `players.md`
- `providers.md`
- `bindings.md`
- `rosters.md`

For a matching identifier, the project entry replaces the skill default.
Project-only identifiers are additions. Project values therefore have final
precedence.

## Player Entry

Use this human-readable shape:

```markdown
## Player: identifier

- Name:
- Perspective:
- Expertise:
- Temperament:
- Productive bias:
- Communication style:
- Productive tension:
```

Profiles are provider-neutral. Do not include commands, models, credentials,
or session handles in a player profile.

## Provider Entry

Use this shape:

```markdown
## Provider: identifier

- Status: enabled | disabled
- Session model:
- Start:
- Resume:
- Working directory:
- File access:
- Research tools:
- Failure signal:
- Limitations:
```

`Start` and `Resume` may describe native tool calls or exact external commands.
Use plain text only. Never store secrets.

## Binding Entry

Bindings are preferences, not identity:

```markdown
## Binding: player-identifier

- Preferred providers:
- Forbidden providers:
- Reason:
```

When no binding exists, choose any enabled compatible provider that satisfies
roster constraints.

## Roster Entry

Reusable roster constraints may specify:

- player and team count;
- required or excluded profiles;
- minimum expertise or perspective coverage;
- provider mix;
- maximum repeated provider or perspective;
- control mode and research defaults.

## Selection

Default to 12 players and four teams of three. Satisfy explicit user
constraints first. Then maximize meaningful differences in expertise,
worldview, incentives, risk tolerance, and creative style.

Do not equate provider diversity with personality diversity. Prefer a
personality-balanced roster even when all players use one provider.

Use curated profiles first. Generate a temporary profile only to fill an
unmet diversity gap. Record the complete generated profile in `roster.md` and
do not promote it into a registry automatically.

## Compatibility Gate

Reject a provider binding unless it supports:

- a distinct persistent private session;
- reliable resume behavior;
- plain-text prompts and responses;
- access to the public files and assigned team room;
- a detectable operational failure.

Do not silently reconstruct context to make an incompatible provider appear
supported.
````

- [ ] **Step 3: Create the 12 default player profiles**

Create `skills/game-of-future/references/default-players.md` with:

```markdown
# Default Player Profiles

## Player: systems-futurist

- Name: Mira Chen
- Perspective: Maps second-order effects across institutions and technologies.
- Expertise: Systems thinking, foresight, scenario design.
- Temperament: Curious, synthetic, patient.
- Productive bias: Looks for feedback loops and unintended consequences.
- Communication style: Structured and connective.
- Productive tension: Challenges narrow products that ignore surrounding systems.

## Player: skeptical-economist

- Name: Elias Ward
- Perspective: Tests incentives, scarcity, adoption costs, and market structure.
- Expertise: Economics, pricing, labor, institutions.
- Temperament: Skeptical, precise, calm.
- Productive bias: Assumes incentives overpower stated intentions.
- Communication style: Concise questions and causal arguments.
- Productive tension: Forces exciting ideas to explain who pays and why.

## Player: frontline-operator

- Name: Rosa Martinez
- Perspective: Judges ideas from daily operational reality.
- Expertise: Service delivery, logistics, process improvement.
- Temperament: Practical, direct, collaborative.
- Productive bias: Values reliability and usability over novelty.
- Communication style: Concrete examples and failure cases.
- Productive tension: Exposes concepts that cannot survive real workflows.

## Player: privacy-advocate

- Name: Noor Haddad
- Perspective: Examines surveillance, consent, power, and data misuse.
- Expertise: Privacy, security, digital rights.
- Temperament: Principled, alert, constructive.
- Productive bias: Treats data accumulation as a liability.
- Communication style: Clear boundaries and adversarial scenarios.
- Productive tension: Makes teams design trust and restraint into products.

## Player: accessibility-advocate

- Name: Jamie Okafor
- Perspective: Centers people excluded by default assumptions.
- Expertise: Accessibility, inclusive design, assistive technology.
- Temperament: Empathetic, exacting, inventive.
- Productive bias: Universal access improves the core product.
- Communication style: User journeys and concrete barriers.
- Productive tension: Rejects target audiences defined too narrowly.

## Player: product-strategist

- Name: Priya Raman
- Perspective: Converts future needs into focused product propositions.
- Expertise: Product discovery, positioning, adoption.
- Temperament: Decisive, curious, outcome-oriented.
- Productive bias: Prefers one sharp use case to broad feature lists.
- Communication style: Crisp framing and prioritization.
- Productive tension: Forces teams to name the user, need, and wedge.

## Player: resilience-planner

- Name: Owen Brooks
- Perspective: Tests products against climate, infrastructure, and supply shocks.
- Expertise: Resilience, urban systems, climate adaptation.
- Temperament: Long-range, sober, resourceful.
- Productive bias: Designs for disruption rather than stable conditions.
- Communication style: Scenarios, dependencies, and contingencies.
- Productive tension: Reveals brittle assumptions in optimistic concepts.

## Player: community-sociologist

- Name: Sofia Petrov
- Perspective: Studies norms, belonging, status, and collective behavior.
- Expertise: Sociology, communities, organizational culture.
- Temperament: Observant, nuanced, dialogic.
- Productive bias: Social adoption matters more than technical capability.
- Communication style: Motivations, rituals, and group dynamics.
- Productive tension: Challenges products that treat people as isolated users.

## Player: pragmatic-founder

- Name: Marcus Lee
- Perspective: Searches for a small executable wedge and a path to scale.
- Expertise: Startups, sales, partnerships, experimentation.
- Temperament: Energetic, opportunistic, resilient.
- Productive bias: Learning through action beats prolonged analysis.
- Communication style: Experiments, offers, and first customers.
- Productive tension: Pushes teams toward a credible first implementation step.

## Player: public-policy-analyst

- Name: Amara Singh
- Perspective: Examines regulation, public value, legitimacy, and institutions.
- Expertise: Policy analysis, public services, governance.
- Temperament: Deliberate, balanced, evidence-minded.
- Productive bias: Durable products align private incentives with public outcomes.
- Communication style: Stakeholder maps and implementation constraints.
- Productive tension: Surfaces legal and institutional blockers.

## Player: applied-technologist

- Name: Theo Nakamura
- Perspective: Distinguishes feasible technical change from marketing claims.
- Expertise: Software systems, AI, automation, infrastructure.
- Temperament: Experimental, candid, detail-aware.
- Productive bias: Capability curves matter, but integration is the bottleneck.
- Communication style: Mechanisms, architectures, and technical limits.
- Productive tension: Grounds forecasts without suppressing invention.

## Player: contrarian-historian

- Name: Lena Fischer
- Perspective: Uses historical analogies to question novelty and inevitability.
- Expertise: Technology history, institutions, cultural change.
- Temperament: Wry, independent, reflective.
- Productive bias: Most futures recombine old patterns under new conditions.
- Communication style: Analogies followed by sharp distinctions.
- Productive tension: Prevents cliché forecasts disguised as technological novelty.
```

- [ ] **Step 4: Verify profile count and required fields**

Run:

```bash
test "$(rg -c '^## Player:' skills/game-of-future/references/default-players.md)" -eq 12
for field in \
  'Name:' \
  'Perspective:' \
  'Expertise:' \
  'Temperament:' \
  'Productive bias:' \
  'Communication style:' \
  'Productive tension:'
do
  test "$(rg -c -- "- $field" skills/game-of-future/references/default-players.md)" -eq 12
done
```

Expected: all commands exit `0`.

- [ ] **Step 5: Commit registries and profiles**

```bash
git add \
  skills/game-of-future/references/registries.md \
  skills/game-of-future/references/default-players.md
git commit -m "feat: add Game of Future registries"
```

### Task 5: Define Provider Support

**Files:**
- Create: `skills/game-of-future/references/default-providers.md`

- [ ] **Step 1: Verify the provider reference is absent**

Run:

```bash
test ! -f skills/game-of-future/references/default-providers.md
```

Expected: exit `0`.

- [ ] **Step 2: Create provider guidance**

Create `skills/game-of-future/references/default-providers.md` with:

```markdown
# Default Providers

## Provider: codex-native-subagent

- Status: enabled
- Session model: One `multi_agent_v1.spawn_agent` result per player.
- Start: Spawn a fresh default agent with the complete player profile, topic, research policy, session root, public file paths, private artifact path, and instruction not to inspect other teams.
- Resume: Use `multi_agent_v1.send_input` with the stored agent id. Send only the new phase instruction and relevant file paths; rely on the persistent private history.
- Working directory: The project root containing `game-of-future/sessions/`.
- File access: Public artifacts, the player's forecast and ballot files, and the assigned team file.
- Research tools: Inherited tools only when the game enables independent research.
- Failure signal: Tool error, missing agent id, closed session, timeout that prevents phase completion, or an agent response that reports it cannot access required files.
- Limitations: Shared-project filesystem access may exceed game-level visibility rules. Enforce privacy through prompts and path disclosure unless stronger isolation is available.

## External Command Providers

No external command is enabled globally without verified start and resume
instructions. Add external engines in project
`game-of-future/registry/providers.md`.

An external entry is supported only when it states exact commands for:

- starting a named persistent session;
- resuming that same session with a new plain-text prompt;
- setting the project working directory;
- exposing non-secret session handles;
- detecting command failure;
- confirming the engine can read the assigned files.

Commands may use documented shell variables such as `$PLAYER_ID`,
`$SESSION_ROOT`, and `$PROMPT_FILE`. These variables are plain-text invocation
conventions, not an encoded protocol.

Do not guess Claude, Gemini, or another vendor's current CLI syntax. Verify the
installed command and official documentation before enabling an entry.

## Persistence Rule

Prefer dropping provider support to replaying the complete conversation on
every turn. Context reconstruction is permitted only for a specific incident
after the user approves it.

## Session Lifecycle

Record every non-secret session handle in `roster.md`. Keep sessions alive
through voting and reporting. Close native or external sessions only after the
final report is complete or the user explicitly ends an aborted game.
```

- [ ] **Step 3: Verify strict persistence and disabled unverified vendors**

Run:

```bash
rg -n '^## Provider: codex-native-subagent$' \
  skills/game-of-future/references/default-providers.md
rg -n 'No external command is enabled globally' \
  skills/game-of-future/references/default-providers.md
rg -n 'Context reconstruction is permitted only' \
  skills/game-of-future/references/default-providers.md
```

Expected: all three assertions match.

- [ ] **Step 4: Commit provider support**

```bash
git add skills/game-of-future/references/default-providers.md
git commit -m "feat: define persistent player providers"
```

### Task 6: Add Facilitation And Failure Policy

**Files:**
- Create: `skills/game-of-future/references/facilitation.md`

- [ ] **Step 1: Verify the facilitation reference is absent**

Run:

```bash
test ! -f skills/game-of-future/references/facilitation.md
```

Expected: exit `0`.

- [ ] **Step 2: Create operational facilitation guidance**

Create `skills/game-of-future/references/facilitation.md` with:

````markdown
# Facilitation

## Control Modes

In autonomous mode, proceed between phases without asking for approval. Pause
only for a persistent-session failure, inaccessible required file, impossible
roster constraint, provider incompatibility, or ambiguity that changes user
intent.

In development mode, pause after setup and after every phase. Report the phase,
changed artifacts, validation results, and the exact next phase.

## Player Start Prompt

Start each player with:

```text
You are a persistent player in a Game of Future session.

Identity:
<complete player profile>

Topic:
<user-supplied topic>

Session root:
<absolute session path>

You retain your private conversation history across the game. Stay in
character, but prioritize plausible forecasts and useful product invention
over theatrical role-play. Read only the public artifacts, your own private
files, and your assigned team file. Do not inspect other teams or ballots.
Wait for the facilitator's phase instruction.
```

Replace angle-bracketed fields with concrete session values before sending.

## Shared Briefing

Write a compact factual baseline with dated sources. Separate facts, observed
trends, and facilitator inference. Do not include product ideas or forecasts.
Give every player the same briefing path.

If independent research is enabled, tell players to append sources to their
own artifact and label inference. Do not conceal unequal tool access.

## Public Cliché Prompt

Send players sequentially:

```text
Read the current public room and shared briefing. Add up to three assumptions
that are genuinely obvious for this topic. You may instead challenge an
existing item or support a recorded challenge. Explain a challenge in one
sentence. Append your signed contribution to the public room and reply with a
one-line completion notice.
```

After all turns, adjudicate disputes and record the accepted cliché list.

## Forecast Prompt

Send privately:

```text
Read the briefing and final cliché list. Write one non-cliché forecast in your
forecast file using What, Why, and When. Make it concrete, plausible, causally
grounded, and normally three to five years away. Cite independent research if
you used it. Reply only after the file is complete.
```

Check every forecast against `references/rules.md`. Request a focused revision
that names the failed criterion.

## Random Assignment

Make forecast assignments without choosing for thematic convenience. Record
the complete assignment in `session.md` before team discussion. Each team
receives three forecasts and may discard one.

## Team Room Coordination

Never ask multiple members to edit the same team file simultaneously. For each
round:

1. Tell one member to read the current team room and append a signed
   contribution.
2. Wait for completion.
3. Send the next member the updated file path.
4. Continue until the team records a decision.

Use at least one divergence round and one convergence round. Require the team
to explain why its product fails if either retained forecast is removed.

## Presentation Prompt

Ask the team to publish a concise pitch containing every required product
field. Permit limited clarifying questions in the public room, then close
discussion before voting.

## Voting Prompt

Send privately:

```text
Read all public pitches. Vote for exactly two projects from teams other than
your own. Vote in character based on which ideas deserve further development.
Write the choices and a short rationale in your ballot file. Do not vote for
your own team or repeat a choice.
```

Reject invalid ballots and request correction.

## Failure Procedure

When a player session fails:

1. Preserve every artifact.
2. Append timestamp, player, provider, phase, failure, attempted action, and
   current dependencies to `errors.md`.
3. Stop the affected team and dependent phases.
4. Pause and ask the user how to proceed.

Do not silently retry with a new identity, replace the provider, shrink the
team, fabricate a response, or reconstruct context. A same-session retry is
allowed only when it cannot alter identity or history.

## Final Report

Report official vote totals first. Label facilitator analysis non-binding.
Assess originality, plausibility, strategic usefulness, forecast intersection,
and undervalued concepts. Treat every product as a hypothesis requiring later
research and validation.
````

- [ ] **Step 3: Verify required prompts and failure rules**

Run:

```bash
for heading in \
  'Control Modes' \
  'Player Start Prompt' \
  'Shared Briefing' \
  'Public Cliché Prompt' \
  'Forecast Prompt' \
  'Random Assignment' \
  'Team Room Coordination' \
  'Presentation Prompt' \
  'Voting Prompt' \
  'Failure Procedure' \
  'Final Report'
do
  rg -F "## $heading" skills/game-of-future/references/facilitation.md
done
rg -n 'Do not silently retry with a new identity' \
  skills/game-of-future/references/facilitation.md
```

Expected: every heading and the strict failure rule match.

- [ ] **Step 4: Commit facilitation policy**

```bash
git add skills/game-of-future/references/facilitation.md
git commit -m "feat: add Game of Future facilitation policy"
```

### Task 7: Add Session Artifact Templates

**Files:**
- Create: `skills/game-of-future/assets/session-template/session.md`
- Create: `skills/game-of-future/assets/session-template/roster.md`
- Create: `skills/game-of-future/assets/session-template/briefing.md`
- Create: `skills/game-of-future/assets/session-template/public-room.md`
- Create: `skills/game-of-future/assets/session-template/errors.md`
- Create: `skills/game-of-future/assets/session-template/report.md`
- Create: `skills/game-of-future/assets/session-template/forecasts/player.md`
- Create: `skills/game-of-future/assets/session-template/teams/team.md`
- Create: `skills/game-of-future/assets/session-template/votes/player.md`

The `{{VARIABLE}}` markers below are intentional template variables, not
unfinished implementation placeholders.

- [ ] **Step 1: Verify no session template exists**

Run:

```bash
test ! -d skills/game-of-future/assets/session-template
```

Expected: exit `0`.

- [ ] **Step 2: Create the template directories**

Run:

```bash
mkdir -p \
  skills/game-of-future/assets/session-template/forecasts \
  skills/game-of-future/assets/session-template/teams \
  skills/game-of-future/assets/session-template/votes
```

- [ ] **Step 3: Create the facilitator ledger template**

Create `skills/game-of-future/assets/session-template/session.md`:

```markdown
# Game Of Future Session

- Topic: {{TOPIC}}
- Started: {{STARTED_AT}}
- Control mode: {{CONTROL_MODE}}
- Research policy: {{RESEARCH_POLICY}}
- Player count: {{PLAYER_COUNT}}
- Team count: {{TEAM_COUNT}}
- Current phase: setup
- Status: active

## Phase History

## Random Decisions

## Facilitator Ledger

## Completion Checklist

- [ ] Briefing complete
- [ ] Cliché list adjudicated
- [ ] Every forecast accepted
- [ ] Teams and assignments recorded
- [ ] Every team pitch complete
- [ ] Every ballot valid
- [ ] Votes tallied
- [ ] Final report complete
```

- [ ] **Step 4: Create roster and briefing templates**

Create `skills/game-of-future/assets/session-template/roster.md`:

```markdown
# Roster

## User Constraints

{{ROSTER_CONSTRAINTS}}

## Players

For each player record profile id, complete temporary profile when applicable,
provider id, non-secret persistent session handle, team, and status.

## Teams

Record members and the diversity rationale for each team.
```

Create `skills/game-of-future/assets/session-template/briefing.md`:

```markdown
# Shared Briefing

- Topic: {{TOPIC}}
- Prepared: {{PREPARED_AT}}
- Independent research: {{INDEPENDENT_RESEARCH}}

## Facts

## Observed Trends

## Facilitator Inference

## Sources
```

- [ ] **Step 5: Create public, error, and report templates**

Create `skills/game-of-future/assets/session-template/public-room.md`:

```markdown
# Public Room

## Announcements

## Cliché Contributions

## Challenges

## Final Cliché List

## Team Presentations

## Clarifying Questions

## Official Results
```

Create `skills/game-of-future/assets/session-template/errors.md`:

```markdown
# Error And Recovery Log

For every incident record:

- Timestamp:
- Player or team:
- Provider:
- Phase:
- Failure:
- Attempted action:
- Preserved state:
- Dependent work stopped:
- User decision:
- Resumption:
```

Create `skills/game-of-future/assets/session-template/report.md`:

```markdown
# Game Of Future Report

## Topic And Parameters

## Accepted Clichés

## Forecasts

## Products

## Official Vote Totals

## Winning Concepts

## Non-Binding Facilitator Analysis

### Originality

### Forecast Plausibility

### Strategic Usefulness

### Forecast Intersection

### Undervalued Concepts

## Recommended Follow-Up Research

## Limitations
```

- [ ] **Step 6: Create player and team templates**

Create `skills/game-of-future/assets/session-template/forecasts/player.md`:

```markdown
# Forecast: {{PLAYER_NAME}}

- Profile: {{PROFILE_ID}}
- Provider: {{PROVIDER_ID}}
- Team: {{TEAM_ID}}

## What

## Why

## When

## Sources

## Facilitator Quality Check

- [ ] Within topic
- [ ] Not an accepted cliché
- [ ] Concrete
- [ ] Plausible
- [ ] Causally grounded
- [ ] Horizon appropriate
```

Create `skills/game-of-future/assets/session-template/teams/team.md`:

```markdown
# Team: {{TEAM_ID}}

## Members

## Assigned Forecasts

## Divergence Round

Append signed contributions in facilitator-assigned turn order.

## Forecast Selection

- Discarded forecast:
- Retained forecast 1:
- Retained forecast 2:
- Why the intersection creates a future niche:

## Convergence Round

Append signed contributions in facilitator-assigned turn order.

## Product

- Name:
- Core idea:
- Target audience:
- Underlying need:
- Unique value:
- Where and how it is used:
- What prevents it from existing now:
- First implementation step:
- Why it matters:

## Intersection Test

- Product without forecast 1:
- Product without forecast 2:
- Why both forecasts are necessary:

## Final Pitch
```

Create `skills/game-of-future/assets/session-template/votes/player.md`:

```markdown
# Ballot: {{PLAYER_NAME}}

- Player team: {{TEAM_ID}}
- First choice:
- Second choice:
- Rationale:

## Validation

- [ ] Exactly two distinct choices
- [ ] Neither choice is the player's team
```

- [ ] **Step 7: Verify the exact template inventory**

Run:

```bash
find skills/game-of-future/assets/session-template -type f | sort
test "$(find skills/game-of-future/assets/session-template -type f | wc -l)" -eq 9
for file in \
  session.md \
  roster.md \
  briefing.md \
  public-room.md \
  errors.md \
  report.md \
  forecasts/player.md \
  teams/team.md \
  votes/player.md
do
  test -f "skills/game-of-future/assets/session-template/$file"
done
```

Expected: nine listed files and all assertions exit `0`.

- [ ] **Step 8: Commit session templates**

```bash
git add skills/game-of-future/assets/session-template
git commit -m "feat: add Game of Future session templates"
```

### Task 8: Run Static Validation And Content Audit

**Files:**
- Modify only if validation finds a defect:
  - `skills/game-of-future/SKILL.md`
  - `skills/game-of-future/agents/openai.yaml`
  - `skills/game-of-future/references/*.md`
  - `skills/game-of-future/assets/session-template/**/*.md`

- [ ] **Step 1: Run the official validator**

Run:

```bash
python /home/kappa/.codex/skills/.system/skill-creator/scripts/quick_validate.py \
  skills/game-of-future
```

Expected:

```text
Skill is valid!
```

- [ ] **Step 2: Audit metadata constraints**

Run:

```bash
python - <<'PY'
from pathlib import Path
import yaml

data = yaml.safe_load(Path("skills/game-of-future/agents/openai.yaml").read_text())
interface = data["interface"]
assert interface["display_name"] == "Game of Future"
assert 25 <= len(interface["short_description"]) <= 64
assert "$game-of-future" in interface["default_prompt"]
print("openai.yaml metadata valid")
PY
```

Expected:

```text
openai.yaml metadata valid
```

- [ ] **Step 3: Audit references, templates, and forbidden implementation**

Run:

```bash
for file in \
  rules.md \
  registries.md \
  default-players.md \
  default-providers.md \
  facilitation.md
do
  test -f "skills/game-of-future/references/$file"
done

test "$(rg -c '^## Player:' skills/game-of-future/references/default-players.md)" -eq 12
test "$(find skills/game-of-future/assets/session-template -type f | wc -l)" -eq 9
test ! -d skills/game-of-future/scripts
! rg -n '\b(T[O]DO|F[I]XME|T[B]D|implement[[:space:]]+later)\b' skills/game-of-future
```

Expected: all commands exit `0`; the final search has no output.

- [ ] **Step 4: Audit spec coverage**

Run:

```bash
for phrase in \
  'persistent' \
  'autonomous mode' \
  'development mode' \
  'shared Markdown room' \
  'Context reconstruction' \
  'two projects' \
  'gesture or sign-language'
do
  rg -i "$phrase" skills/game-of-future
done
```

Expected: every requirement has at least one match.

- [ ] **Step 5: Commit validation fixes if any**

If validation required edits:

```bash
git add skills/game-of-future
git commit -m "fix: satisfy Game of Future skill validation"
```

If no edits were needed, do not create an empty commit.

### Task 9: Install And Smoke-Test Skill Discovery

**Files:**
- Install verified copy to: `${CODEX_HOME:-$HOME/.codex}/skills/game-of-future/`

- [ ] **Step 1: Verify the source is clean and valid**

Run:

```bash
git status --short
python /home/kappa/.codex/skills/.system/skill-creator/scripts/quick_validate.py \
  skills/game-of-future
```

Expected: `git status --short` shows no tracked changes and the validator prints
`Skill is valid!`. An unrelated ignored swap file is acceptable.

- [ ] **Step 2: Check for an existing installation**

Run:

```bash
INSTALL_ROOT="${CODEX_HOME:-$HOME/.codex}/skills"
test ! -e "$INSTALL_ROOT/game-of-future"
```

Expected: exit `0`. If an installation exists, stop and inspect it; do not
overwrite it without explicit approval.

- [ ] **Step 3: Install the verified skill**

Run with approval if the destination is outside the workspace:

```bash
INSTALL_ROOT="${CODEX_HOME:-$HOME/.codex}/skills"
mkdir -p "$INSTALL_ROOT/game-of-future"
cp -a skills/game-of-future/. "$INSTALL_ROOT/game-of-future/"
```

Expected: exit `0`.

- [ ] **Step 4: Verify installed content matches source**

Run:

```bash
INSTALL_ROOT="${CODEX_HOME:-$HOME/.codex}/skills"
diff -ru skills/game-of-future "$INSTALL_ROOT/game-of-future"
python /home/kappa/.codex/skills/.system/skill-creator/scripts/quick_validate.py \
  "$INSTALL_ROOT/game-of-future"
```

Expected: `diff` has no output and the validator prints `Skill is valid!`.

- [ ] **Step 5: Start a discovery smoke test**

In a fresh Codex thread, use this exact prompt:

```text
Use $game-of-future. Topic: neighborhood delivery services in 2030.
Control mode: development. Stop after setup.
Roster: 3 players in one team, Codex-only.
Research: shared briefing only.
```

Expected:

- the skill triggers;
- the facilitator creates a session directory;
- three distinct persistent player sessions are recorded;
- setup artifacts exist;
- the facilitator pauses before the cliché phase.

Do not continue this smoke session.

### Task 10: Forward-Test Development Mode

**Files:**
- Generated, retained test session:
  `game-of-future/sessions/<timestamp>-neighborhood-delivery-services-in-2030/`

- [ ] **Step 1: Inspect setup artifacts from the smoke test**

Run:

```bash
SESSION_DIR="$(find game-of-future/sessions -mindepth 1 -maxdepth 1 -type d \
  -name '*-neighborhood-delivery-services-in-2030' | sort | tail -1)"
test -n "$SESSION_DIR"
test -f "$SESSION_DIR/session.md"
test -f "$SESSION_DIR/roster.md"
test -f "$SESSION_DIR/briefing.md"
test -f "$SESSION_DIR/public-room.md"
rg -n 'Current phase: setup|Status: active' "$SESSION_DIR/session.md"
```

Expected: every assertion exits `0`.

- [ ] **Step 2: Resume the same facilitator and player sessions**

Tell the facilitator:

```text
Continue through the cliché phase only, then pause as required by development
mode. Preserve the same player sessions.
```

Expected: the facilitator uses existing session handles, runs players
sequentially, records additions and challenges, adjudicates the final list,
and pauses.

- [ ] **Step 3: Verify sequential public interaction**

Run:

```bash
rg -n '^## Cliché Contributions|^## Challenges|^## Final Cliché List' \
  "$SESSION_DIR/public-room.md"
rg -n 'cliché|challenge|accepted|removed' "$SESSION_DIR/public-room.md"
```

Expected: the required sections exist and contain signed player activity plus
facilitator adjudication.

- [ ] **Step 4: Continue through forecasts and team design**

Tell the facilitator:

```text
Continue through individual forecasts, random assignment, and team product
design. Pause after team design. Preserve every persistent player session.
```

Expected: three accepted forecast files exist, one team file records three
assigned forecasts, one discarded forecast, divergence and convergence rounds,
and a completed intersection test.

- [ ] **Step 5: Verify forecast and team artifacts**

Run:

```bash
test "$(find "$SESSION_DIR/forecasts" -type f | wc -l)" -eq 3
test "$(find "$SESSION_DIR/teams" -type f | wc -l)" -eq 1
TEAM_FILE="$(find "$SESSION_DIR/teams" -type f | head -1)"
rg -n '^## Divergence Round|^## Forecast Selection|^## Convergence Round|^## Product|^## Intersection Test' \
  "$TEAM_FILE"
```

Expected: all assertions exit `0`.

- [ ] **Step 6: Test presentation and impossible voting**

Tell the facilitator:

```text
Publish the team presentation and attempt to enter voting. Because this
one-team smoke session cannot cast valid cross-team ballots, pause and record
that limitation instead of fabricating votes or marking the game complete.
```

Expected: the session remains paused with the voting limitation explicitly
recorded in `errors.md` and `session.md`. This verifies honest handling of a
deliberately undersized development roster. The full autonomous test covers
successful voting and completion.

### Task 11: Forward-Test A Full Autonomous Game

**Files:**
- Generated, retained test session:
  `game-of-future/sessions/<timestamp>-local-ai-assistants-in-professional-work/`

- [ ] **Step 1: Start the default-size autonomous test**

In a fresh Codex thread, use:

```text
Use $game-of-future.
Topic: local AI assistants in professional work.
Control mode: autonomous.
Roster: default 12 players in four teams, Codex-only.
Research: shared briefing only.
Run to completion unless a real failure or ambiguity requires me.
```

Expected: the game proceeds without phase approval prompts and creates four
teams of three.

- [ ] **Step 2: Verify complete retained artifacts**

After completion, run:

```bash
SESSION_DIR="$(find game-of-future/sessions -mindepth 1 -maxdepth 1 -type d \
  -name '*-local-ai-assistants-in-professional-work' | sort | tail -1)"
test -n "$SESSION_DIR"
test "$(find "$SESSION_DIR/forecasts" -type f | wc -l)" -eq 12
test "$(find "$SESSION_DIR/teams" -type f | wc -l)" -eq 4
test "$(find "$SESSION_DIR/votes" -type f | wc -l)" -eq 12
test -f "$SESSION_DIR/report.md"
rg -n '^## Official Vote Totals|^## Non-Binding Facilitator Analysis' \
  "$SESSION_DIR/report.md"
rg -n 'Status: complete' "$SESSION_DIR/session.md"
```

Expected: all assertions exit `0`.

- [ ] **Step 3: Audit forecast quality**

Run:

```bash
for file in "$SESSION_DIR"/forecasts/*.md
do
  rg -n '^## What$|^## Why$|^## When$' "$file"
  rg -n '\[x\] Within topic' "$file"
  rg -n '\[x\] Not an accepted cliché' "$file"
  rg -n '\[x\] Plausible' "$file"
  rg -n '\[x\] Causally grounded' "$file"
done
```

Expected: every forecast passes every assertion.

- [ ] **Step 4: Audit product intersections and ballots**

Run:

```bash
for file in "$SESSION_DIR"/teams/*.md
do
  rg -n '^## Intersection Test$' "$file"
  rg -n 'Why both forecasts are necessary:' "$file"
done

for file in "$SESSION_DIR"/votes/*.md
do
  rg -n '\[x\] Exactly two distinct choices' "$file"
  rg -n "\[x\] Neither choice is the player's team" "$file"
done
```

Expected: every team and ballot passes.

### Task 12: Verify Failure Preservation And Optional External Providers

**Files:**
- Generated failure-test session under `game-of-future/sessions/`
- Optional project registry:
  `game-of-future/registry/providers.md`

- [ ] **Step 1: Start a development failure test**

Start a fresh three-player development session:

```text
Use $game-of-future.
Topic: resilient community energy systems.
Control mode: development.
Roster: 3 players in one team, Codex-only.
Stop after forecasts.
```

Approve each development-mode gate through the forecast phase.

Expected: setup, cliché, and forecast artifacts exist and the game pauses after
forecasts.

- [ ] **Step 2: Simulate a persistent-session failure**

Close one player agent using `multi_agent_v1.close_agent`, then tell the
facilitator:

```text
Continue to team formation and product design.
```

Expected: the facilitator attempts to resume the recorded player, detects the
failure, writes `errors.md`, preserves all artifacts, stops dependent work, and
asks the user how to proceed. It does not spawn a replacement.

- [ ] **Step 3: Verify preserved failure state**

Run:

```bash
FAILURE_SESSION="$(find game-of-future/sessions -mindepth 1 -maxdepth 1 -type d \
  -name '*-resilient-community-energy-systems' | sort | tail -1)"
test -n "$FAILURE_SESSION"
rg -n 'player|provider|phase|failure|preserved|user decision' \
  "$FAILURE_SESSION/errors.md"
rg -n 'Status: active|Status: paused' "$FAILURE_SESSION/session.md"
```

Expected: failure details are present and the session is not marked complete.

- [ ] **Step 4: Discover installed external-agent skills and tools**

Use `tool_search` with:

```json
{
  "query": "persistent Claude Gemini external agent sessions with start resume and working-directory support"
}
```

Expected: zero or more tools or skills. Evaluate each result against the
provider compatibility gate before using it. Do not assume that a tool's
existence implies persistent-session support.

- [ ] **Step 5: Detect available external engines**

Run:

```bash
command -v claude || true
command -v gemini || true
```

Expected: zero, one, or both commands may be available.

- [ ] **Step 6: Verify official CLI behavior before enabling an engine**

For each available command:

1. Read its installed `--help`.
2. Consult current official vendor documentation.
3. Confirm exact start, resume, working-directory, and failure behavior.
4. Add a complete enabled provider entry to
   `game-of-future/registry/providers.md`.
5. Never record credentials.

If no command supports persistent resume and file access, do not create an
enabled entry. Record that mixed-provider forward testing is unavailable
rather than adding reconstruction logic.

- [ ] **Step 7: Run a mixed-provider smoke test when compatible**

When at least one external provider passes the compatibility gate, run:

```text
Use $game-of-future.
Topic: continuing education for mid-career professionals.
Control mode: development.
Roster: 4 players in two teams, use at least one Codex player and one verified
external provider player.
Stop after the cliché phase.
```

Expected: persistent sessions from both provider types contribute
sequentially, and `roster.md` records non-secret handles and provider ids.

If no compatible external provider exists, mark this test `SKIPPED` with the
reason in the implementation summary. Do not weaken the persistence contract.

### Task 13: Final Verification And Commit

**Files:**
- All tracked skill source files
- No generated session artifacts

- [ ] **Step 1: Run final static verification**

Run:

```bash
python /home/kappa/.codex/skills/.system/skill-creator/scripts/quick_validate.py \
  skills/game-of-future
! rg -n '\b(T[O]DO|F[I]XME|T[B]D|implement[[:space:]]+later)\b' skills/game-of-future
test ! -d skills/game-of-future/scripts
test "$(rg -c '^## Player:' skills/game-of-future/references/default-players.md)" -eq 12
test "$(find skills/game-of-future/assets/session-template -type f | wc -l)" -eq 9
```

Expected: validator prints `Skill is valid!`; every assertion exits `0`.

- [ ] **Step 2: Verify installed copy still matches**

Run:

```bash
INSTALL_ROOT="${CODEX_HOME:-$HOME/.codex}/skills"
diff -ru skills/game-of-future "$INSTALL_ROOT/game-of-future"
```

Expected: no output.

If source fixes occurred after installation, copy the source again with
approval and rerun `diff`.

- [ ] **Step 3: Review tracked changes**

Run:

```bash
git status --short
git diff --check
git diff --stat HEAD
```

Expected:

- only intended source files are tracked as changed;
- no generated session directory is listed;
- `git diff --check` has no output.

- [ ] **Step 4: Commit any final source corrections**

If final verification changed source files:

```bash
git add .gitignore skills/game-of-future
git commit -m "fix: finalize Game of Future skill"
```

If no source corrections remain, do not create an empty commit.

- [ ] **Step 5: Record verification evidence**

In the final implementation response, report:

- official validator result;
- installed-copy diff result;
- development-mode test outcome;
- autonomous 12-player test outcome;
- failure-preservation test outcome;
- mixed-provider outcome or explicit compatibility-based skip;
- commits created;
- paths to retained test sessions.
