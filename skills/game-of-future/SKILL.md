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
- Treat every player session as a participant only, never as a facilitator or
  co-facilitator.
- Assign every selected roster entry a unique, stable per-session player id
  before creating player artifacts or starting player sessions. Freeze roster
  order first, reserve `player` for the copied template paths, then generate
  ids with the deterministic ASCII-only slug-and-suffix procedure defined in
  `references/registries.md`. Assigned player ids must never be exactly
  `player`.
- Keep personality profiles independent from provider bindings.
- Use a separate shared Markdown room for each team.
- Use plain-text prompts, responses, registries, and artifacts.
- Prepend the exact player sandbox guard from
  `references/facilitation.md` to every player-facing turn, including start
  verification, cliché, forecast, revision, team, presentation, clarification,
  voting, and probe or retry turns.
- Do not introduce a custom orchestration program or encoded wire format.
- Treat context reconstruction as a user-approved last resort.
- Treat any off-allowlist read, including skill or repository instruction
  discovery, as a provider policy failure. Preserve artifacts and pause.
- Pause when a persistent player cannot be resumed. Never silently replace,
  remove, recreate, or impersonate a failed player.
- Never use a profile id as the per-session artifact identity. Profile IDs must
  not be used for artifact filenames.

## Session Setup

Create:

`game-of-future/sessions/<timestamp>-<topic-slug>/`

Copy every file from `assets/session-template/` while preserving its directory
structure. Resolve registries, select the roster, assign and record every
unique player id in `roster.md`, then instantiate one forecast file at
`forecasts/<player-id>.md` and one ballot file at `votes/<player-id>.md` per
player and one shared room per team. Remove the copied
`forecasts/player.md` and `votes/player.md` templates only after every
per-player artifact has been instantiated under a non-reserved player id.
Remove the copied `teams/team.md` template only after every team room has been
instantiated under its team id. Use the same player id in artifact metadata,
provider `$PLAYER_ID`, prompts, logs, session-handle labels, and status
records. The provider-issued non-secret session handle remains a separate
value, stored in `roster.md` under that player id. Replace the documented
template variables as the game progresses. Record current phase, random
choices, provider-issued non-secret handle values, session-handle labels, and
facilitator decisions in the artifacts. When current state changes, update any
present-tense state summary or relabel it as historical so later ledger entries
do not contradict it.

The setup checkpoint includes registry resolution, roster selection, unique
player-id assignment, artifact instantiation, provider binding, starting and
verifying one persistent session per player, and completing the shared
briefing. The user-facing setup checkpoint spans Workflow steps 1 and 2, with
no development-mode pause between them, and ends before step 3, the public
cliché phase. `Stop after setup` pauses only after all of this and before the
public cliché phase. In development mode, pause after the setup checkpoint and
after each subsequent canonical phase. In autonomous mode, continue unless a
failure, an explicit `stop after setup` request, or genuine ambiguity requires
user input.

## Workflow

Run these phases in order:

1. Resolve registries, select a diverse roster, assign unique player ids,
   instantiate per-player artifacts, bind providers, and start and verify
   persistent player sessions.
2. Prepare the shared factual briefing.
3. Run the sequential public cliché round with challenges.
4. Collect one private forecast from every player and enforce the forecast
   quality gate.
5. Form teams and randomly assign three forecasts per team.
6. Coordinate turn-based collaboration through each team's shared file.
7. Publish concise team pitches and allow limited clarification.
8. Collect two private votes per player for other teams.
9. Tally official player votes, add separate non-binding facilitator analysis,
   verify artifacts, and complete `report.md`.

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
- `errors.md` records all failures in incident blocks and updates the same block
  with the user decision and resumption before play continues;
- `report.md` distinguishes official votes from facilitator commentary.
