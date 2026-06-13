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
