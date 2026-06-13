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
