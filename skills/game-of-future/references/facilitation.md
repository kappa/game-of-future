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
setup` pauses only after all of this and before the public cliche phase. The
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

Before enabling any provider for player sessions, verify its registry entry
against `references/registries.md`. Reject the provider unless either:

1. `Discovery control` gives an exact, verifiable control that disables
   automatic skill or project-instruction discovery for player turns; or
2. `Turn trace` identifies the exact per-turn artifact or channel that exposes
   all file, command, and tool accesses, and `Trace audit` gives a concrete
   allowlist-check procedure the facilitator can run before accepting the turn.

Do not assume native Codex subagent tracing exists unless the provider entry
states the exact verified control or trace surface. If verification is missing,
record provider incompatibility and pause instead of starting players.

For each distinct provider used by the roster, make its first bound player the
operational preflight player:

1. Record the installed provider version and the exact relevant local help or
   verified invocation documentation in `session.md`.
2. Start that actual player with the zero-access Player Start Prompt below.
3. Extract and record the non-secret persistent session handle.
4. Verify the configured response and status mechanism.
5. Audit the start trace when tracing is required.
6. Resume the same handle with the zero-access Start Verification Prompt.
7. Audit the resume trace and record the exact trace paths, completeness result,
   and allowlist result in `session.md`.
8. Only after both turns pass may the facilitator start the provider's remaining
   players. Reuse the preflight player's verified session for the game.

If version/help inspection, command parsing, handle extraction, persistence,
trace completeness, or either zero-access response fails, record one incident,
preserve artifacts, and pause. A registry entry alone never proves
compatibility.

Provider traces enforce observable behavioral path isolation. They do not prove
the absence of hidden platform system context. Disclose known preloaded context
in the registry, keep the exact guard on every turn, and reject the provider if
preloaded instructions cause any unauthorized action.

## Player Turn Guard

Prepend this exact guard verbatim to every player-facing prompt, including
start verification, cliche, forecast, forecast revision, team-room turns,
presentation, clarification, voting, and any probe or retry turn. Do not
paraphrase it.

```text
Player role only: you are a participant in this Game of Future session, never
the facilitator.

Do not invoke, load, discover, or follow the Game of Future skill or any other
installed or repository skill, AGENTS/CLAUDE/GEMINI instructions, plan, spec,
or source file.

All authority for this turn is contained in this facilitator prompt. Do not
inspect the working directory, repository, or skill implementation.

Use only the exact read and write paths listed in this prompt. Paths outside
this turn's allowlists are forbidden, including $CODEX_HOME, .codex, .agents,
skills/, docs/, registries, and other session artifacts.

If your provider defaults conflict, follow this narrower player sandbox
instruction or report inability without reading extra files.
```

## Player Start Prompt

Prepend the exact Player Turn Guard block above, then send:

```text
You are a persistent player in a Game of Future session.

Player ID:
<assigned per-session player id>

Identity:
<complete player profile>

Topic:
<user-supplied topic>

Read paths: none.
Write paths: none.
Do not read or write any file.

You retain your private conversation history across the game. Stay in
character, but prioritize plausible forecasts and useful product invention
over theatrical role-play. Future turns will name their exact readable files
and at most one writable file. Never infer access from prior turns. Do not
inspect other teams or other players' ballots. Reply `READY <player-id>` and
take no other action.
```

Replace angle-bracketed fields with concrete session values before sending.
The facilitator replaces all placeholders with concrete values.

Use the same player id in provider `$PLAYER_ID`, prompt metadata, logs,
session-handle labels, and status records. Never use a profile id as the
per-session artifact identity. The provider-issued non-secret session handle
remains a separate value, stored in `roster.md` under the player id.

## Start Verification Prompt

After the start prompt, prepend the exact Player Turn Guard block above and
send:

```text
This is a start verification turn.
Read paths: none.
Write paths: none.
Do not read or write any file.
Reply in one line with your player id and confirmation that you are a player
participant only and will use only the listed paths.
```

## Shared Briefing

Write a compact factual baseline with dated sources. Separate facts, observed
trends, and facilitator inference. Do not include product ideas or forecasts.
Give every player the same briefing path. Setup is complete only after the
briefing exists and every player session needed for later phases has been
started and verified.

If independent research is enabled, tell players to append sources to their
own artifact and label inference. Do not conceal unequal tool access.

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
ideas, or serious forecasts. Use plain language, not jargon. Submit only items
that would be boring to develop. A good cliche makes the room roll its eyes,
not lean forward; if it raises an interesting question worth forecasting or
building around, do not submit it.

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
the existing entries in `Light Dissent Pass`. Challenge an item only when it is
not actually common, obvious, boring, or game-ending; is unclear or
jargon-heavy; or is interesting enough to forecast around. One sentence per
challenge. Do not debate, improve, forecast, or add new cliche candidates.

If you have no dissent, append one signed line saying `No dissent.` to
`Light Dissent Pass`. Otherwise append only your signed dissent entries to
`Light Dissent Pass`. Preserve existing content and write to no other file.
Reply with a one-line completion notice.
```

After all dissent turns, adjudicate candidates according to
`references/rules.md`, merge near-duplicates, rephrase long candidates into
short cliche form when possible, clean up unclear wording into plain language,
generalize narrow submissions into more obvious cliches when that preserves
the intent, and record the accepted cliche list in `Final Cliche List`.
The facilitator replaces every angle-bracketed token with concrete absolute
paths.

## Forecast Prompt

Prepend the exact Player Turn Guard block above, then send privately:

```text
Read only `<briefing-path>` and `<public-room-path>`. Write one non-cliche
forecast only to `<forecast-path>` using the existing What, Why, and When
headings. Preserve the template headings, write to no other file, make it
concrete, plausible, causally grounded, and normally three to five years away.
Cite independent research if you used it. Reply only after the file is
complete.
```

Check every forecast against `references/rules.md`. Request one focused
revision that names the failed criterion or criteria. If the revised forecast
is still invalid, preserve artifacts, append the failure and dependencies to
`errors.md`, set `Status: paused` with the current phase in `session.md`, and
pause rather than loop.
The facilitator replaces every placeholder with concrete absolute paths.

## Forecast Revision Prompt

When a forecast needs one revision, prepend the exact Player Turn Guard block
above and send:

```text
Read only `<briefing-path>`, `<public-room-path>`, and `<forecast-path>`.
Revise only `<forecast-path>`. Address exactly these failed criteria:
<failed-criteria>. Preserve the existing headings and any valid content, update
only what is needed to satisfy the named criteria, and write to no other file.
Reply only after the file is complete.
```

## Random Assignment

Make forecast assignments only with an actual available random operation, for
example `shuf`, never semantic or facilitator ordering. Sample unique
forecasts without replacement. Record the candidate pool, random method or
command, and the resulting order and assignment in `session.md` before team
discussion. Each team receives three forecasts and may discard one. If no
trustworthy random operation is available, preserve artifacts, append the
cause and dependencies to `errors.md`, set `Status: paused` with the current
phase in `session.md`, and pause rather than choose manually.

## Team Room Coordination

Never ask multiple members to edit the same team file simultaneously. For each
round:

1. Prepend the exact Player Turn Guard block above, then tell one member:

   ```text
   Read only `<briefing-path>`, `<public-room-path>`, the exact assigned
   `<forecast-paths>`, and `<team-path>`. Append your signed contribution only
   to the requested section of `<team-path>`, preserve all existing content,
   and write to no other file. Sign with your player id and display name.
   Reply with a one-line completion notice.
   ```

2. Wait for completion.
3. Send the next member the updated file path.
4. Continue until the team records a decision.

Use at least one divergence round and one convergence round. Require the team
to explain why its product fails if either retained forecast is removed.
Preserve prior entries and append signed contributions. If a wait or status
operation times out, do not advance to another editor; follow Failure
Procedure. The facilitator replaces every placeholder with concrete absolute
paths. Identify every teammate by player id and display name. Require every
signed team contribution to identify its author by player id and display name.

## Presentation Prompt

Teams publish sequentially. For each team, designate one writer, send the
exact public-room path as the only writable target, wait or status-check for
completion, inspect the artifact, then allow the next team. Other members read
only. Preserve existing public-room content and append only the requested
section. Permit only a small number of clarifying questions; those
contributions also use one writer at a time with the same sequence. No
concurrent public-room editors. Ask the designated writer to publish a concise
pitch containing every required product field, then close discussion before
voting. Prepend the exact Player Turn Guard block above, then send:

```text
Read only `<team-path>` and `<public-room-path>`. Append the requested team
pitch only to `<public-room-path>`, preserve existing public content, and
write to no other file. Include every required product field. Reply with a
one-line completion notice.
```

The facilitator replaces every placeholder with concrete absolute paths.

## Clarification Prompt

When allowing a clarification question or answer, prepend the exact Player Turn
Guard block above and send:

```text
Read only `<public-room-path>` and, if needed, your own `<team-path>`. Append
only the requested clarification entry to `<public-room-path>`, preserve
existing content, and write to no other file. Keep it concise and reply with a
one-line completion notice.
```

## Voting Prompt

Prepend the exact Player Turn Guard block above, then send privately:

```text
Read only `<public-room-path>`, where public pitches are published. Vote for
exactly two projects from teams other than your own. Vote in character based
on which ideas deserve further development. Write the choices and a short
rationale only to `<ballot-path>`. Do not vote for your own team or repeat a
choice. Preserve existing ballot content and write to no other file.
```

Reject invalid ballots and request correction.
The facilitator replaces every placeholder with concrete absolute paths.

## Session Ledger Hygiene

When the current state changes, update or replace any stale present-tense
summary in `session.md`. If a note is being kept for history, label it
explicitly as historical and add a timestamp or phase marker. Do not leave a
present-tense facilitator-ledger claim that is contradicted by a later phase
record or user decision.

## Failure Procedure

When a player session fails:

1. Preserve every artifact.
2. Append one new incident block to `errors.md` using the template schema
   without editing the header or schema instructions.
3. Stop the affected team and dependent phases.
4. Pause and ask the user how to proceed.

Do not silently retry with a new identity, replace the provider, shrink the
team, fabricate a response, or reconstruct context. A same-session retry after
confirmed session failure is allowed only after explicit user approval and only
when identity and history are preserved and no pending write exists.

For every pause condition, including session failure, inaccessible file,
impossible roster, provider incompatibility, provider policy failure such as an
off-allowlist read, material ambiguity, unavailable randomness, or an
uncertain post-timeout state, preserve artifacts, set `Status: paused` and the
current phase in `session.md`, append one new incident block to `errors.md`,
then ask the user how to proceed. On response, update `User decision` and
`Resumption` inside that same incident block before continuing, and record the
same outcome in `session.md`. Never place live incident values in the template
instructions or in a generic header. After a provider wait or status timeout,
do not resend or permit another editor until the same session has been polled
with the provider's registry-defined response or status mechanism
(`multi_agent_v1.wait_agent` for native Codex) and the designated writable
artifact has been inspected. If terminal failure is confirmed, log it in the
same incident block, stop the affected team and dependent phases, and pause
per this procedure. No resend until user decision. Log every timeout, approved
retry, and resumption in that same incident block. If state remains uncertain,
pause.

## Probe Or Retry Prompt

After a timeout or uncertain completion state, prepend the exact Player Turn
Guard block above and, if the same session remains valid, send:

```text
This is a probe or approved retry turn. Read only `<allowed-read-paths>` and
inspect only `<writable-path>` for the last requested work. Do not write any
file unless this prompt explicitly names `<writable-path>` as writable. Report
whether the requested write is complete, incomplete, or uncertain. If you
cannot comply without reading another path, say so and stop.
```

## Final Report

Report official vote totals first. Label facilitator analysis non-binding.
Assess originality, plausibility, strategic usefulness, forecast intersection,
and undervalued concepts. Treat every product as a hypothesis requiring later
research and validation.
