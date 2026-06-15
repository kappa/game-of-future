# Default Providers

## Provider: codex-native-subagent

- Status: enabled
- Session model: One `multi_agent_v1.spawn_agent` result per player.
- Start: Spawn a fresh default agent with the assigned player id, complete
  player profile, topic, research policy, session root, public file paths,
  private artifact path, and the exact player sandbox guard from
  `references/facilitation.md`. When the provider surface supports disabling
  automatic skill or project-instruction discovery, enable that narrower mode.
- Resume: Use `multi_agent_v1.send_input` with the stored agent id. Send only
  the new phase instruction and relevant file paths, prepend the exact player
  sandbox guard to the prompt, and rely on the persistent private history.
- Wait: After every start or resumed turn, use `multi_agent_v1.wait_agent`,
  classify completed, errored, and timed-out states before advancing, and
  audit the command or tool log for any read outside the exact allowlists
  before accepting the turn.
- Capacity: Preflight available open-agent capacity. If the roster exceeds it,
  rotate inactive sessions without losing identity or history: after a player's
  turn completes, record its agent id and use `multi_agent_v1.close_agent` to
  free a slot; before its next turn, use `multi_agent_v1.resume_agent`, then
  `send_input` and `wait_agent`. A resume failure triggers the normal
  pause-failure policy. This is suspension, not context reconstruction.
- Working directory: The project root containing `game-of-future/sessions/`.
- File access: Public artifacts, the player's forecast and ballot files, and
  the assigned team file.
- Research tools: Inherited tools only when the game enables independent
  research.
- Failure signal: Tool error, missing agent id, closed session, timeout that
  prevents phase completion, an agent response that reports it cannot access
  required files, or any off-allowlist read observed in the command or tool
  log.
- Limitations: Shared-project filesystem access may exceed game-level
  visibility rules. Enforce privacy through prompts, path disclosure, and log
  auditing unless stronger isolation is available. Do not describe this as OS
  isolation.

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
- disabling automatic skill or project-instruction discovery when the provider
  supports it, or documenting that it does not;
- suspending or closing and later resuming without losing private history, or a
  verified capacity model that keeps all required sessions available;
- finally closing the session, or documenting a verified automatic terminal
  cleanup mechanism;
- detecting command failure;
- confirming the engine can read the assigned files;
- exposing command or tool logs, or another verified turn trace, that the
  facilitator can inspect for off-allowlist reads before accepting a turn.

Commands may use documented shell variables such as `$PLAYER_ID`,
`$SESSION_ROOT`, and `$PROMPT_FILE`. `$PLAYER_ID` is the unique per-session
player id, not the profile id, and should be reused in prompts, logs, and
non-secret status or handle labels. These variables are plain-text invocation
conventions, not an encoded protocol.

The provider-issued non-secret session handle remains a separate value. Record
it in `roster.md` under the assigned player id.

Profile IDs must not be used for artifact filenames.

Do not guess Claude, Gemini, or another vendor's current CLI syntax. Verify the
installed command and official documentation before enabling an entry.

If a provider cannot disable automatic instruction discovery, prepend the exact
player sandbox guard from `references/facilitation.md` to every player prompt
and audit the provider's command or tool logs before accepting the turn. Any
off-allowlist read is a provider policy failure: preserve artifacts and pause.
If a provider offers neither a discovery-disable control nor an auditable turn
trace, do not enable it for player sessions.

## Persistence Rule

Prefer dropping provider support to replaying the complete conversation on
every turn. Context reconstruction is permitted only for a specific incident
after the user approves it.

## Session Lifecycle

Record every provider-issued non-secret session handle in `roster.md` under
the assigned player id. Preserve resumable session identity and history
through voting and reporting, but inactive native sessions may be closed to
free capacity and resumed by id. After the final report or when the user
explicitly ends an aborted game, close all sessions.
