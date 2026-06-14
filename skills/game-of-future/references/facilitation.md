# Facilitation

## Control Modes

In autonomous mode, proceed between phases without asking for approval. Pause
only for a persistent-session failure, inaccessible required file, impossible
roster constraint, provider incompatibility, or ambiguity that changes user
intent.

In development mode, pause after the setup checkpoint and after each
subsequent canonical phase. Report the phase, changed artifacts, validation
results, and the exact next phase.

The setup checkpoint includes registry resolution, roster selection, assigning
and recording unique player ids, instantiating `forecasts/<player-id>.md` and
`votes/<player-id>.md`, provider binding, starting and verifying one
persistent session per player, and completing the shared briefing. `Stop after
setup` pauses only after all of this and before the public cliché phase. The
user-facing setup checkpoint spans canonical Phase 1 Setup and Phase 2 Shared
Briefing, with no development-mode pause between them. Development mode pauses
at that boundary automatically.

Before starting player sessions, determine whether the requested run is
intended to complete voting. A completable run requires at least 3 teams and
enough unique player forecasts to assign 3 per team without replacement
(`player count >= 3 * team count`). A phase-limited development run may use an
undersized roster only if the facilitator records in `session.md` that it
cannot complete later phases and the user explicitly requested the limited
stop. Otherwise, record the impossible roster in `errors.md` and `session.md`,
set `Status: paused` with the current phase in `session.md`, preserve
artifacts, and pause before starting players.

## Player Start Prompt

Start each player with:

```text
You are a persistent player in a Game of Future session.

Player ID:
<assigned per-session player id>

Identity:
<complete player profile>

Topic:
<user-supplied topic>

Session root:
<absolute session path>

Allowed public read paths:
<exact readable public paths>

Private forecast path:
<absolute forecast path>

Private ballot path:
<absolute ballot path>

Assigned team path:
<absolute team path or literal not assigned>

Allowed writable paths:
<exact writable paths for this player>

You retain your private conversation history across the game. Stay in
character, but prioritize plausible forecasts and useful product invention
over theatrical role-play. Read only the exact readable paths named above and
the exact readable files named in each turn. Each turn names the allowed
readable files and exactly one writable file; read or write no other session
paths. Preserve existing content and append or update only the requested
section of the writable file. Do not inspect other teams or other players' ballots.
Wait for the facilitator's phase instruction.
```

Replace angle-bracketed fields with concrete session values before sending.
The facilitator replaces all placeholders with concrete values. Use the literal
`not assigned` for the team path until teams form, then send the assigned
absolute path before team work.

Use the same player id in provider `$PLAYER_ID`, prompt metadata, logs,
session-handle labels, and status records. Never use a profile id as the
per-session artifact identity. The provider-issued non-secret session handle
remains a separate value, stored in `roster.md` under the player id.

## Shared Briefing

Write a compact factual baseline with dated sources. Separate facts, observed
trends, and facilitator inference. Do not include product ideas or forecasts.
Give every player the same briefing path. Setup is complete only after the
briefing exists and every player session needed for later phases has been
started and verified.

If independent research is enabled, tell players to append sources to their
own artifact and label inference. Do not conceal unequal tool access.

## Public Cliché Prompt

Send players sequentially:

```text
Read `<briefing-path>` and `<public-room-path>`. Add up to three assumptions
that are genuinely obvious for this topic. You may instead challenge an
existing item or support a recorded challenge. Explain a challenge in one
sentence. Append your signed contribution only to the requested section of
`<public-room-path>`, preserve existing content, and write to no other file.
Reply with a one-line completion notice.
```

After all turns, adjudicate disputes and record the accepted cliché list.
The facilitator replaces every placeholder with concrete absolute paths.

## Forecast Prompt

Send privately:

```text
Read `<briefing-path>` and `<public-room-path>`. Write one non-cliché forecast
only to `<forecast-path>` using the existing What, Why, and When headings.
Preserve the template headings, write to no other file, make it concrete,
plausible, causally grounded, and normally three to five years away. Cite
independent research if you used it. Reply only after the file is complete.
```

Check every forecast against `references/rules.md`. Request one focused revision
that names the failed criterion or criteria. If the revised forecast is still
invalid, preserve artifacts, append the failure and dependencies to
`errors.md`, set `Status: paused` with the current phase in `session.md`, and
pause rather than loop.
The facilitator replaces every placeholder with concrete absolute paths.

## Random Assignment

Make forecast assignments only with an actual available random operation, for
example `shuf`, never semantic or facilitator ordering. Sample unique forecasts
without replacement. Record the candidate pool, random method or command, and
the resulting order and assignment in `session.md` before team discussion. Each
team receives three forecasts and may discard one. If no trustworthy random
operation is available, preserve artifacts, append the cause and dependencies
to `errors.md`, set `Status: paused` with the current phase in `session.md`,
and pause rather than choose manually.

## Team Room Coordination

Never ask multiple members to edit the same team file simultaneously. For each
round:

1. Tell one member to read the exact relevant forecast paths, public read
   paths, and the current `<team-path>`, then append a signed contribution only
   to `<team-path>`.
2. Wait for completion.
3. Send the next member the updated file path.
4. Continue until the team records a decision.

Use at least one divergence round and one convergence round. Require the team
to explain why its product fails if either retained forecast is removed.
Preserve prior entries and append signed contributions. If a wait or status operation times out, do not advance to another editor; follow Failure Procedure.
The facilitator replaces every placeholder with concrete absolute paths.
Identify every teammate by player id and display name. Require every signed
team contribution to identify its author by player id and display name.

## Presentation Prompt

Teams publish sequentially. For each team, designate one writer, send the
exact public-room path as the only writable target, wait or status-check for
completion, inspect the artifact, then allow the next team. Other members read
only. Preserve existing public-room content and append only the requested
section. Permit only a small number of clarifying questions; those
contributions also use one writer at a time with the same sequence. No
concurrent public-room editors. Ask the designated writer to publish a concise
pitch containing every required product field, then close discussion before
voting. The facilitator replaces every placeholder with concrete absolute
paths.

## Voting Prompt

Send privately:

```text
Read only `<public-room-path>`, where public pitches are published. Vote for
exactly two projects from teams other than your own. Vote in character based
on which ideas deserve further development. Write the choices and a short
rationale only to `<ballot-path>`. Do not vote for your own team or repeat a
choice. Preserve existing ballot content and write to no other file.
```

Reject invalid ballots and request correction.
The facilitator replaces every placeholder with concrete absolute paths.

## Failure Procedure

When a player session fails:

1. Preserve every artifact.
2. Append timestamp, player, provider, phase, failure, attempted action, and
   current dependencies to `errors.md`.
3. Stop the affected team and dependent phases.
4. Pause and ask the user how to proceed.

Do not silently retry with a new identity, replace the provider, shrink the
team, fabricate a response, or reconstruct context. A same-session retry after
confirmed session failure is allowed only after explicit user approval and only
when identity and history are preserved and no pending write exists.

For every pause condition, including session failure, inaccessible file,
impossible roster, provider incompatibility, material ambiguity, unavailable
randomness, or an uncertain post-timeout state, preserve artifacts, set
`Status: paused` and the current phase in `session.md`, append `errors.md` with
timestamp, cause, attempted action when applicable, and current dependencies,
then ask the user how to proceed. On response, record the user decision and resumption in both `errors.md` and `session.md` before continuing. After a
provider wait or status timeout, do not resend or permit another editor until
the same session has been polled with the provider's registry-defined response
or status mechanism (`multi_agent_v1.wait_agent` for native Codex) and the
designated writable artifact has been inspected. If terminal failure is
confirmed, log it, stop the affected team and dependent phases, and pause per
this procedure. No resend until user decision. Log every timeout and any
approved retry. If state remains uncertain, pause.

## Final Report

Report official vote totals first. Label facilitator analysis non-binding.
Assess originality, plausibility, strategic usefulness, forecast intersection,
and undervalued concepts. Treat every product as a hypothesis requiring later
research and validation.
