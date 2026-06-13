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
