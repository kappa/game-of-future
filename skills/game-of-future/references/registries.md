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

Profile identifiers are reusable registry keys, not per-session artifact
identity. Do not treat a profile id as a unique player instance.

## Session Player Identity

For each selected roster entry, assign a unique, stable player id for that
session before creating per-player artifacts or starting a provider session.
Freeze the selected roster order first. Before processing any roster entry,
reserve `player` because `forecasts/player.md` and `votes/player.md` exist as
copied template paths until instantiation is complete. The assigned player-id
contract forbids the exact value `player`. Then process entries in roster
order. For each entry:

1. Read the roster display name.
2. Scan its characters in order.
3. Convert only ASCII `A-Z` to `a-z`.
4. Copy ASCII `a-z` and `0-9` unchanged.
5. Replace each maximal run of all other characters with one `-`.
6. Trim leading and trailing `-`.
7. Use base `player` if the result is empty.
8. Use the base if it is unused.
9. Otherwise choose the lowest integer `n >= 2` whose `<base>-<n>` is unused.
10. Reserve the chosen id immediately before processing the next entry.

There is no locale-specific transliteration. This procedure is deterministic
and handles preexisting suffixed bases such as `rosa-martinez-2` without
special cases because every reserved id blocks later reuse. An empty slug or a
display name such as `Player` therefore allocates `player-2` or the next
lowest unused suffix, never `player`.

Record the assigned player id in `roster.md` and do not change it during the
game. Use that player id for `forecasts/<player-id>.md`,
`votes/<player-id>.md`, provider `$PLAYER_ID`, prompts, logs, non-secret
session-handle labels, status records, and artifact metadata. Never use a
profile id as the per-session artifact identity. Assigned player ids must
never be exactly `player`. Profile IDs must not be used for artifact
filenames.

The provider-issued non-secret session handle remains a separate value. Store
it in `roster.md` under the assigned player id rather than treating it as the
player id or as a substitute for session-handle labels.

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
- Discovery control:
- Preloaded context:
- Turn trace:
- Trace audit:
- Failure signal:
- Limitations:
```

`Start` and `Resume` may describe native tool calls or exact external commands.
Use plain text only. Never store secrets.

`Discovery control` must state the exact verified flag, setting, tool option,
or other provider control that disables automatic skill or project-instruction
discovery for player turns. If no such control is verified, say so plainly.

`Preloaded context` must disclose known provider-level system instructions,
skills, plugins, or project instructions that may be placed in model context
without a traced file read. Complete platform prompt provenance is not assumed
to be available. The game enforces behavioral path isolation: preloaded context
must not cause the player to read, write, invoke, or follow anything outside
the facilitator prompt and its exact allowlists.

`Turn trace` must name the exact per-turn artifact path, output file, log
channel, transcript stream, or other evidence source that exposes every
observable file, command, and tool access relevant to the player turn. If no
such source is verified, say so plainly.

`Trace audit` must describe the exact allowlist-check procedure the facilitator
performs before accepting a player turn. It must identify what to inspect in
the trace and when to reject the turn as a provider policy failure.

## Binding Entry

Bindings are preferences, not identity:

```markdown
## Binding: profile-identifier

- Preferred providers:
- Forbidden providers:
- Reason:
```

Reusable bindings target profile ids, never per-session player ids. When no
binding exists, choose any enabled compatible provider that satisfies roster
constraints.

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

Team membership records must identify members by player id and display name.

## Compatibility Gate

Reject a provider binding unless it supports:

- a distinct persistent private session;
- reliable resume behavior;
- plain-text prompts and responses;
- access to the public files and assigned team room;
- a detectable operational failure;
- either a verified `Discovery control`, or both an exact `Turn trace` and a
  concrete `Trace audit` that checks all traced file, command, and tool
  accesses against the per-turn allowlists before the facilitator accepts the
  turn;
- a successful zero-access start and resume probe using one actual bound player,
  with provider version, exact invocation, handle extraction, response, trace
  completeness, and audit result recorded in `session.md`.

Do not silently reconstruct context to make an incompatible provider appear
supported.

Do not assume native tool surfaces expose tracing. If a registry entry cannot
name the exact verified discovery-disable control or exact auditable trace
surface, mark that provider disabled or incompatible for player sessions.

Trace auditing proves observable behavior, not the absence of hidden provider
system context. Reject a provider when undisclosed or conflicting preloaded
context causes the zero-access probe or any later turn to violate the guard.
