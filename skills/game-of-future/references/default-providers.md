# Default Providers

## Provider: codex-native-subagent

- Status: disabled
- Session model: One `multi_agent_v1.spawn_agent` result per player.
- Start: Spawn a fresh default agent with the assigned player id, complete
  player profile, topic, research policy, session root, public file paths,
  private artifact path, and the exact player sandbox guard from
  `references/facilitation.md`.
- Resume: Use `multi_agent_v1.send_input` with the stored agent id. Send only
  the new phase instruction and relevant file paths, prepend the exact player
  sandbox guard to the prompt, and rely on the persistent private history.
- Wait: After every start or resumed turn, use `multi_agent_v1.wait_agent`,
  classify completed, errored, and timed-out states before advancing.
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
- Discovery control: Unverified on the current native `multi_agent_v1` surface.
  Do not enable this provider until the exact discovery-disable control is
  verified and documented here.
- Preloaded context: The native agent inherits platform instructions and may
  receive skill or project context not represented as a traced file read.
- Turn trace: Unverified on the current native `multi_agent_v1` surface. No
  exact per-turn artifact or channel is currently documented here for auditing
  every file, command, and tool access.
- Trace audit: Not available until a verified `Discovery control` or exact
  `Turn trace` is documented here. Treat the provider as incompatible for
  player sessions until one of those controls exists and is verified.
- Failure signal: Tool error, missing agent id, closed session, timeout that
  prevents phase completion, an agent response that reports it cannot access
  required files, or failure to verify the required discovery or trace
  contract before player start.
- Limitations: Shared-project filesystem access may exceed game-level
  visibility rules. Enforce privacy through prompts, path disclosure, and log
  auditing only after the provider exposes a verified control or auditable
  trace surface. Do not describe this as OS isolation.

## Provider: codex-cli-exec

- Status: enabled
- Session model: One persistent Codex CLI thread per player.
- Start: `codex --ask-for-approval never --sandbox workspace-write -C "$SESSION_ROOT" exec --ignore-user-config --ignore-rules --json --skip-git-repo-check -o "$RESPONSE_FILE" - < "$PROMPT_FILE" > "$LOG_FILE"`
- Resume: `codex --ask-for-approval never --sandbox workspace-write -C "$SESSION_ROOT" exec resume --ignore-user-config --ignore-rules --json --skip-git-repo-check -o "$RESPONSE_FILE" "$SESSION_HANDLE" - < "$PROMPT_FILE" > "$LOG_FILE"`
- Wait: The foreground command is the wait mechanism. Accept no turn until the
  process exits, the response exists, and the trace audit passes.
- Finish: After final reporting or an explicitly ended aborted game, run
  `codex archive "$SESSION_HANDLE"` for each player.
- Working directory: `$SESSION_ROOT`, the absolute session directory.
- File access: The process has workspace access broader than the game
  allowlists. The exact guard, per-turn paths, and trace audit enforce the game
  boundary behaviorally.
- Research tools: Do not pass `--search` unless the game enables independent
  research.
- Discovery control: `--ignore-user-config` and `--ignore-rules` reduce
  inherited configuration and exec-policy rules, but no verified switch
  disables every form of automatic instruction discovery. Trace audit is
  mandatory.
- Preloaded context: Codex platform instructions and the available-skill
  catalog may be present without a traced read. The exact player guard remains
  authoritative for game behavior.
- Turn trace: Set `$LOG_FILE` to
  `$SESSION_ROOT/logs/$PLAYER_ID-$TURN.jsonl`; stdout from `--json` is the
  retained per-turn trace. Set `$RESPONSE_FILE` separately to
  `$SESSION_ROOT/logs/$PLAYER_ID-$TURN.last.txt`.
- Trace audit: Inspect every JSONL event before accepting the turn. For each
  command execution, tool call, and file operation, resolve referenced paths
  and compare them with that prompt's exact read and write allowlists. A
  zero-access turn must contain no command, tool, or file-operation event.
  Reject a missing or incomplete trace, unexpected command or tool, ambiguous
  path, or off-allowlist access as a provider policy failure.
- Failure signal: Missing command, nonzero status, JSONL error event, missing
  `thread.started` id on start, missing response, incomplete trace, failed
  resume, failed archive, or any trace-audit violation.
- Limitations: This is behavioral prompt-and-audit isolation, not OS
  filesystem isolation or proof of complete provider prompt provenance. Treat
  the provider as incompatible for the run unless operational preflight passes.

## Provider: claude-cli-exec

- Status: enabled
- Session model: One persistent Claude Code CLI thread per player.
- Start: Generate a UUID for `$SESSION_HANDLE` with `python3 -c "import uuid; print(uuid.uuid4())"` or `uuidgen`. Then run:
  `claude --print --verbose --safe-mode --dangerously-skip-permissions --output-format stream-json --session-id "$SESSION_HANDLE" --tools "Read,Write,Edit" --add-dir "$SESSION_ROOT" < "$PROMPT_FILE" > "$LOG_FILE"` followed by `jq -r 'select(.type=="result") | .result' "$LOG_FILE" > "$RESPONSE_FILE"`.
- Resume: `claude --print --verbose --safe-mode --dangerously-skip-permissions --output-format stream-json --resume "$SESSION_HANDLE" --tools "Read,Write,Edit" --add-dir "$SESSION_ROOT" < "$PROMPT_FILE" > "$LOG_FILE"` followed by `jq -r 'select(.type=="result") | .result' "$LOG_FILE" > "$RESPONSE_FILE"`.
- Wait: The foreground command is the wait mechanism. Accept no turn until the process exits, the log exists, and the trace audit passes.
- Finish: No explicit close command required. Sessions persist on disk by UUID and may be left as-is after the game ends.
- Working directory: `$SESSION_ROOT`, passed via `--add-dir`. No `-C` flag needed; all prompts use absolute paths.
- File access: `--tools "Read,Write,Edit"` restricts players to file operations only. `--add-dir "$SESSION_ROOT"` grants access to the session directory tree. Bash is unavailable to players.
- Research tools: Do not pass web search or other tools unless the game enables independent research.
- Discovery control: `--safe-mode` disables CLAUDE.md, skills, plugins, hooks, and MCP servers for the session. This is a verified declarative flag — stronger than `codex-cli-exec`'s `--ignore-rules`, which that entry notes is unverified for full discovery suppression. Trace audit is mandatory.
- Preloaded context: `--safe-mode` suppresses skills, plugins, and CLAUDE.md. The platform system prompt and built-in tool definitions are present in model context without a traced read. The exact player guard remains authoritative; reject the provider if preloaded instructions cause unauthorized action in the zero-access preflight or any later turn.
- Turn trace: Set `$LOG_FILE` to `$SESSION_ROOT/logs/$PLAYER_ID-$TURN.jsonl`; stream-json output from `--output-format stream-json` is the retained per-turn trace. Set `$RESPONSE_FILE` separately to `$SESSION_ROOT/logs/$PLAYER_ID-$TURN.last.txt`.
- Trace audit: Inspect every event in `$LOG_FILE` where `type == "assistant"`. For each entry in `message.content[]` where `type == "tool_use"`: `name` must be `Read`, `Write`, or `Edit` (Bash is unavailable; any other tool name is a violation); check `input.file_path` against the turn's read allowlist (for `Read`) or write allowlist (for `Write` and `Edit`). A zero-access turn must contain no `tool_use` events. Reject a missing or incomplete log, unexpected tool name, ambiguous path, or off-allowlist access as a provider policy failure: preserve artifacts and pause.
- Failure signal: Nonzero exit status, missing `result` event in log, missing log file, failed `--resume` (session not found or expired), or any trace-audit violation.
- Limitations: `--safe-mode` suppresses customizations but the platform system prompt is still present in model context. Trace audits operate at the model-observable tool-call level, not the OS call level. This is behavioral prompt-and-audit isolation, not OS filesystem isolation. Treat the provider as incompatible for the run unless operational preflight passes.

## External Command Providers

The Codex CLI and Claude Code CLI providers above are the enabled command
defaults. Add other external engines in project
`game-of-future/registry/providers.md`.

An external entry is supported only when it states exact commands for:

- starting a named persistent session;
- resuming that same session with a new plain-text prompt;
- setting the project working directory;
- exposing non-secret session handles;
- waiting for or reading the response and status;
- documenting `Discovery control` with the exact discovery-disable setting,
  flag, or declared lack of support;
- documenting `Preloaded context`, including any untraced system, skill, plugin,
  or project instructions known to be injected;
- suspending or closing and later resuming without losing private history, or a
  verified capacity model that keeps all required sessions available;
- finally closing the session, or documenting a verified automatic terminal
  cleanup mechanism;
- detecting command failure;
- confirming the engine can read the assigned files;
- documenting `Turn trace` with the exact artifact path or channel used for
  each turn;
- documenting `Trace audit` with the exact procedure that checks every traced
  file, command, and tool access against the per-turn allowlists before the
  facilitator accepts the turn.

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

If `Discovery control` is not verifiably disabled, `Turn trace` and
`Trace audit` are mandatory. Any off-allowlist read is a provider policy
failure: preserve artifacts and pause. If a provider offers neither a verified
discovery-disable control nor an auditable turn trace, do not enable it for
player sessions.

Before using any external entry for a roster, execute the start-and-resume
zero-access preflight in `references/facilitation.md`. Registry prose without a
passing recorded probe is insufficient.

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
