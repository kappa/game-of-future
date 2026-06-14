# Canonical Game Rules

## Purpose

Produce surprising product hypotheses from plausible near-future forecasts.
The game is a structured imagination exercise, not precise prediction or final
strategy.

## Phase 1: Setup

Require a user-supplied topic. Apply user roster constraints before defaults.
Resolve registries, create a diverse roster, and assign every selected roster
entry a unique, stable per-session player id before any player contribution.
Freeze the selected roster order first, reserve `player` for the copied
template paths, then generate the player id with the deterministic ASCII-only
slug-and-suffix procedure defined in `references/registries.md`. Record the
player id in `roster.md` before creating player artifacts or starting
sessions, and do not change it during the game. Assigned player ids must
never be exactly `player`. Profile IDs must not be used for artifact
filenames.

Instantiate `forecasts/<player-id>.md` and `votes/<player-id>.md`, bind each
player to a provider, and start and verify one persistent session per player
before setup is complete. Use the same player id in prompts, provider
`$PLAYER_ID`, logs, session-handle labels, status records, and artifact
metadata. The provider-issued non-secret session handle remains a separate
value, stored in `roster.md` under that player id. Record the roster and all
random decisions. Remove the copied `forecasts/player.md` and
`votes/player.md` templates only after every per-player artifact has been
instantiated under a non-reserved player id. Remove the copied
`teams/team.md` template only after every team room has been instantiated
under its team id.

## Phase 2: Shared Briefing

Prepare a compact, cited baseline of present facts and established trends.
Avoid forecasts and product recommendations in the briefing. Mark inference
as inference. If independent research is enabled, require players to cite it
in their artifacts.

The user-facing setup checkpoint spans Phase 1 Setup and Phase 2 Shared
Briefing, with no development-mode pause between them, and ends only after the
shared briefing is complete and before Phase 3 Public Cliche Round. `Stop
after setup` pauses only at that boundary.

## Phase 3: Public Cliche Round

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

## Phase 5: Teams And Assignment

Default to four teams of three. Prefer teams with varied expertise, worldview,
risk tolerance, creative style, and provider when available.

Randomly assign three forecasts to each team. Record the assignment before
collaboration. Each team may discard one forecast and must retain two.
Identify every team member by player id and display name. Every signed team
contribution must also identify its author by player id and display name.

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

## Phase 9: Final Report

Report official vote totals first. Then separately assess:

- originality;
- forecast plausibility;
- strategic usefulness;
- strength of the forecast intersection;
- promising concepts that voting may have undervalued.

Label this analysis non-binding. Complete `report.md` in this phase.

## Exclusions

Do not run or imitate the optional gesture or sign-language phase. Do not claim
forecast certainty, product validation, or a final strategic decision.
