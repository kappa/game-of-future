# Default Providers

## Provider: codex-native-subagent

- Status: enabled
- Session model: One `multi_agent_v1.spawn_agent` result per player.
- Start: Spawn a fresh default agent with the complete player profile, topic, research policy, session root, public file paths, private artifact path, and instruction not to inspect other teams.
- Resume: Use `multi_agent_v1.send_input` with the stored agent id. Send only the new phase instruction and relevant file paths; rely on the persistent private history.
- Wait: After every start or resumed turn, use `multi_agent_v1.wait_agent` and classify completed, errored, and timed-out states before advancing.
- Capacity: Preflight available open-agent capacity. If the roster exceeds it, rotate inactive sessions without losing identity or history: after a player's turn completes, record its agent id and use `multi_agent_v1.close_agent` to free a slot; before its next turn, use `multi_agent_v1.resume_agent`, then `send_input` and `wait_agent`. A resume failure triggers the normal pause/failure policy. This is suspension, not context reconstruction.
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
- waiting for or reading the response and status;
- suspending or closing and later resuming without losing private history, or a verified capacity model that keeps all required sessions available;
- finally closing the session, or documenting a verified automatic terminal cleanup mechanism;
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

Record every non-secret session handle in `roster.md`. Preserve resumable session
identity and history through voting and reporting, but inactive native sessions
may be closed to free capacity and resumed by id. After the final report or
when the user explicitly ends an aborted game, close all sessions.
