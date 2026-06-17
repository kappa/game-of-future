# Claude Code Player Provider

## Purpose

Add `claude-cli-exec` as an enabled player provider in `default-providers.md` so
game sessions can run players using the Claude Code CLI (`claude`), alongside or
instead of the existing `codex-cli-exec` provider. Update the Player Turn Guard
in `facilitation.md` to be provider-agnostic by adding Claude Code-specific
forbidden paths.

The first game using this provider will be run with the facilitator in a Claude
Code session and a mixed roster: some players on `codex-cli-exec`, some on
`claude-cli-exec`.

## Scope

Two source files change:

- `skills/game-of-future/references/default-providers.md` — add `claude-cli-exec`
  entry after the existing `codex-cli-exec` entry.
- `skills/game-of-future/references/facilitation.md` — update the Player Turn
  Guard forbidden path list to include `~/.claude` and `.claude/`.

The installed copy at `/home/kappa/.codex/skills/game-of-future/` is synced after
source changes, following the established pattern.

No other files change. SKILL.md, rules.md, registries.md, and session templates
are already provider-agnostic.

## `claude-cli-exec` Provider Entry

### Session Handle

Before starting a player's first turn, the facilitator generates a UUID:

```bash
python3 -c "import uuid; print(uuid.uuid4())"
# or: uuidgen
```

This UUID is the session handle. Record it in `roster.md` under the player's
assigned player id. Pass it to `--session-id` at start and `--resume` on every
subsequent turn.

### Start Command

```
claude --print --safe-mode --dangerously-skip-permissions \
  --output-format stream-json \
  --session-id "$SESSION_HANDLE" \
  --tools "Read,Write,Edit" \
  --add-dir "$SESSION_ROOT" \
  < "$PROMPT_FILE" > "$LOG_FILE"
jq -r 'select(.type=="result") | .result' "$LOG_FILE" > "$RESPONSE_FILE"
```

### Resume Command

```
claude --print --safe-mode --dangerously-skip-permissions \
  --output-format stream-json \
  --resume "$SESSION_HANDLE" \
  --tools "Read,Write,Edit" \
  --add-dir "$SESSION_ROOT" \
  < "$PROMPT_FILE" > "$LOG_FILE"
jq -r 'select(.type=="result") | .result' "$LOG_FILE" > "$RESPONSE_FILE"
```

### Wait Mechanism

`--print` runs in the foreground and exits when the turn completes. Accept no
turn result until the process exits, the log file exists, and the trace audit
passes.

### Finish

No explicit archive command is required. Claude Code sessions persist on disk by
UUID. After final reporting or an explicitly ended aborted game, sessions can be
left as-is or cleaned up manually.

### Working Directory

`--add-dir "$SESSION_ROOT"` grants Read, Write, and Edit tool access to the
session directory tree. No `-C` flag is needed; the game uses absolute paths in
all prompts.

### Discovery Control

`--safe-mode` disables CLAUDE.md, skills, plugins, hooks, and MCP servers for
the session. This is a verified declarative flag — stronger than `codex-cli-exec`'s
`--ignore-rules`, which that entry notes is unverified for full discovery
suppression. Trace audit remains mandatory regardless.

### Preloaded Context

`--safe-mode` suppresses skills, plugins, and CLAUDE.md. The platform system
prompt and built-in tool definitions are still present in model context without
a traced file read. The player guard remains authoritative. Reject the provider
if preloaded platform instructions cause any unauthorized action in the zero-access
preflight or any later turn.

### Turn Trace

Set `$LOG_FILE` to `$SESSION_ROOT/logs/$PLAYER_ID-$TURN.jsonl` (stream-json
events from `--output-format stream-json`). Set `$RESPONSE_FILE` to
`$SESSION_ROOT/logs/$PLAYER_ID-$TURN.last.txt` (response text extracted from the
log by `jq`).

### Trace Audit

Inspect every event in `$LOG_FILE` where `type == "assistant"`. For each entry
in `message.content[]` where `type == "tool_use"`:

- `name` must be `Read`, `Write`, or `Edit`. (`Bash` is unavailable; any other
  tool name is a violation.)
- For `Read`: check `input.file_path` against the turn's read allowlist.
- For `Write`: check `input.file_path` against the turn's write allowlist.
- For `Edit`: check `input.file_path` against the turn's write allowlist.

A zero-access turn must contain no `tool_use` events at all.

Reject a missing or incomplete log, an unexpected tool name, an ambiguous path,
or any off-allowlist path as a provider policy failure: preserve artifacts and
pause.

### Failure Signal

Nonzero exit status, missing `result` event in the log, missing log file, failed
`--resume` (session not found or expired), or any trace-audit violation.

### Limitations

`--safe-mode` suppresses customizations but the platform system prompt is still
present. Trace audits operate at the model-observable tool-call level, not the
OS call level. File access beyond the prompt allowlist is behaviorally isolated
through `--tools` restriction and trace audit, not OS filesystem isolation.

## Player Turn Guard Update

### Current Text (in `facilitation.md`)

```
Paths outside this turn's allowlists are forbidden, including $CODEX_HOME,
.codex, .agents, skills/, docs/, registries, and other session artifacts.
```

### Updated Text

```
Paths outside this turn's allowlists are forbidden, including $CODEX_HOME,
.codex, .agents, ~/.claude, .claude/, skills/, docs/, registries, and other
session artifacts.
```

This change applies to every player-facing prompt regardless of provider. Both
Codex and Claude Code players receive the same rule. Future providers benefit
automatically.

## Provider Entry Shape

The `claude-cli-exec` entry uses the standard provider shape from
`references/registries.md`, with all required fields including `Discovery
control`, `Preloaded context`, `Turn trace`, and `Trace audit` populated with
verified, concrete values.

## Verification

### Static

- `quick_validate.py skills/game-of-future` passes.
- `default-providers.md` contains `## Provider: claude-cli-exec` with `Status: enabled`.
- `facilitation.md` Player Turn Guard contains `~/.claude, .claude/`.
- `diff -ru skills/game-of-future /home/kappa/.codex/skills/game-of-future` has no output.

### Operational Preflight (zero-access probe)

Before running any player on `claude-cli-exec`, execute the standard zero-access
start and resume preflight from `references/facilitation.md` using the first
bound player:

1. Generate a UUID and record it as the session handle.
2. Run the start command with the zero-access Player Start Prompt.
3. Verify the log contains a `result` event and no `tool_use` events.
4. Run the resume command with the Start Verification Prompt.
5. Verify the same conditions.
6. Record provider version (`claude --version`), exact invocation, handle, trace
   paths, completeness, and audit result in `session.md`.

### Smoke Test

A development-mode game with a mixed roster — some players on `codex-cli-exec`,
some on `claude-cli-exec` — run by the facilitator in a Claude Code session.
Stop after the cliché phase. Verify:

- Both provider types complete start and verification turns.
- `roster.md` records session handles and provider ids for all players.
- All players contribute to the cliché shout round and dissent pass.
- Trace logs exist for every player turn.
- No trace-audit violations.
