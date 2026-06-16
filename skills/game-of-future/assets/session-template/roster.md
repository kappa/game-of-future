# Roster

## User Constraints

{{ROSTER_CONSTRAINTS}}

## Players

For each player record player id, display name, profile id, complete temporary
profile when applicable, provider id, non-secret persistent session handle,
team, and status.

Player ids are unique and stable within one session. Freeze roster order and
reserve exact id `player` for the copied template filenames. Process each
display name in roster order: convert only ASCII `A-Z` to `a-z`; copy ASCII
`a-z` and `0-9` unchanged; replace each maximal run of all other characters
with one `-`; trim leading and trailing `-`; and use base `player` if empty.
Use the base if unused, otherwise choose the lowest integer `n >= 2` whose
`<base>-<n>` is unused. Reserve each chosen id immediately. An assigned id
must never be exactly `player` and must not change during the game.

The provider-issued non-secret session handle is a separate value. Store it
under the player id and do not treat it as the player id or as a replacement
for session-handle labels.

## Teams

Record members by player id and display name, plus the diversity rationale for
each team.
