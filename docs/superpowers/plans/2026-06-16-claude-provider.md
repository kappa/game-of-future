# Claude Provider Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add `claude-cli-exec` as an enabled player provider and update the Player Turn Guard to be provider-agnostic, then verify with a mixed-provider smoke test.

**Architecture:** Two Markdown file edits in `skills/game-of-future/references/`. No runtime code. Verification is static assertions plus an operational preflight and cliché-phase smoke test run by the Claude Code facilitator with a mixed Codex + Claude Code player roster.

**Tech Stack:** Markdown, `rg`, `jq`, `diff`, `quick_validate.py`, `claude --version`, Git.

---

## File Structure

- Modify: `skills/game-of-future/references/default-providers.md` — add `claude-cli-exec` entry; update External Command Providers intro sentence.
- Modify: `skills/game-of-future/references/facilitation.md` — add `~/.claude, .claude/` to Player Turn Guard forbidden path list.
- Sync: `/home/kappa/.codex/skills/game-of-future/` — installed copy must match source after both edits.
- Generated: `game-of-future/sessions/<timestamp>-<topic>/` — smoke test session artifacts (gitignored).

---

## Task 1: Add claude-cli-exec Provider Entry

**Files:**
- Modify: `skills/game-of-future/references/default-providers.md`

- [ ] **Step 1: Verify the entry does not already exist**

Run:

```bash
if rg -n 'claude-cli-exec' skills/game-of-future/references/default-providers.md; then
  echo "ALREADY EXISTS — inspect before continuing"
  exit 1
fi
```

Expected: exit `0` with no output.

- [ ] **Step 2: Add the provider entry**

In `skills/game-of-future/references/default-providers.md`, insert the following block immediately after the last line of the `codex-cli-exec` entry (after the `- Limitations:` line for `codex-cli-exec`, before `## External Command Providers`):

```markdown

## Provider: claude-cli-exec

- Status: enabled
- Session model: One persistent Claude Code CLI thread per player.
- Start: Generate a UUID for `$SESSION_HANDLE` with `python3 -c "import uuid; print(uuid.uuid4())"` or `uuidgen`. Then run:
  `claude --print --safe-mode --dangerously-skip-permissions --output-format stream-json --session-id "$SESSION_HANDLE" --tools "Read,Write,Edit" --add-dir "$SESSION_ROOT" < "$PROMPT_FILE" > "$LOG_FILE"` followed by `jq -r 'select(.type=="result") | .result' "$LOG_FILE" > "$RESPONSE_FILE"`.
- Resume: `claude --print --safe-mode --dangerously-skip-permissions --output-format stream-json --resume "$SESSION_HANDLE" --tools "Read,Write,Edit" --add-dir "$SESSION_ROOT" < "$PROMPT_FILE" > "$LOG_FILE"` followed by `jq -r 'select(.type=="result") | .result' "$LOG_FILE" > "$RESPONSE_FILE"`.
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
```

- [ ] **Step 3: Update the External Command Providers intro sentence**

In `skills/game-of-future/references/default-providers.md`, replace:

```
The tested Codex CLI provider above is the only enabled command default. Add
other external engines in project `game-of-future/registry/providers.md`.
```

with:

```
The Codex CLI and Claude Code CLI providers above are the enabled command
defaults. Add other external engines in project
`game-of-future/registry/providers.md`.
```

- [ ] **Step 4: Verify the entry is present and correct**

Run:

```bash
rg -n '^## Provider: claude-cli-exec$' \
  skills/game-of-future/references/default-providers.md
rg -n 'Status: enabled' \
  skills/game-of-future/references/default-providers.md
rg -n 'safe-mode' \
  skills/game-of-future/references/default-providers.md
rg -n 'Codex CLI and Claude Code CLI providers above are the enabled' \
  skills/game-of-future/references/default-providers.md
```

Expected: all four commands produce matches.

- [ ] **Step 5: Commit**

```bash
git add skills/game-of-future/references/default-providers.md
git commit -m "feat: add claude-cli-exec player provider"
```

---

## Task 2: Update Player Turn Guard

**Files:**
- Modify: `skills/game-of-future/references/facilitation.md`

- [ ] **Step 1: Verify current guard text before editing**

Run:

```bash
rg -n 'CODEX_HOME, .codex, .agents,' \
  skills/game-of-future/references/facilitation.md
```

Expected: one match containing `skills/, docs/, registries` — no `~/.claude` yet.

- [ ] **Step 2: Update the forbidden path list**

In `skills/game-of-future/references/facilitation.md`, replace:

```
this turn's allowlists are forbidden, including $CODEX_HOME, .codex, .agents,
skills/, docs/, registries, and other session artifacts.
```

with:

```
this turn's allowlists are forbidden, including $CODEX_HOME, .codex, .agents,
~/.claude, .claude/, skills/, docs/, registries, and other session artifacts.
```

- [ ] **Step 3: Verify the update**

Run:

```bash
rg -n '~/.claude, .claude/' \
  skills/game-of-future/references/facilitation.md
```

Expected: one match inside the Player Turn Guard block.

- [ ] **Step 4: Verify the guard appears exactly once**

Run:

```bash
rg -c 'CODEX_HOME, .codex, .agents' \
  skills/game-of-future/references/facilitation.md
```

Expected: `1` — the guard block was not accidentally duplicated.

- [ ] **Step 5: Commit**

```bash
git add skills/game-of-future/references/facilitation.md
git commit -m "fix: make player turn guard provider-agnostic"
```

---

## Task 3: Static Validation and Installed Skill Sync

**Files:**
- Read: `skills/game-of-future/`
- Sync: `/home/kappa/.codex/skills/game-of-future/`

- [ ] **Step 1: Run the official skill validator**

Run:

```bash
python /home/kappa/.codex/skills/.system/skill-creator/scripts/quick_validate.py \
  skills/game-of-future
```

Expected:

```
Skill is valid!
```

- [ ] **Step 2: Run content assertions**

Run:

```bash
rg -n '^## Provider: claude-cli-exec$' \
  skills/game-of-future/references/default-providers.md
rg -n '^## Provider: codex-cli-exec$' \
  skills/game-of-future/references/default-providers.md
rg -n '~/.claude, .claude/' \
  skills/game-of-future/references/facilitation.md
test "$(rg -c '^## Player:' \
  skills/game-of-future/references/default-players.md)" -eq 12
test "$(find skills/game-of-future/assets/session-template -type f | wc -l)" -eq 9
! rg -n '\b(T[O]DO|F[I]XME|T[B]D)\b' skills/game-of-future
```

Expected: all commands exit `0` with the expected matches; the final search has no output.

- [ ] **Step 3: Sync installed copy**

Run:

```bash
rsync -a --delete skills/game-of-future/ /home/kappa/.codex/skills/game-of-future/
```

Expected: exit `0`.

- [ ] **Step 4: Verify installed copy matches source**

Run:

```bash
diff -ru skills/game-of-future /home/kappa/.codex/skills/game-of-future
```

Expected: no output.

---

## Task 4: Run Mixed-Provider Smoke Test

**Files:**
- Generated: `game-of-future/sessions/<timestamp>-urban-mobility-in-2030/`

This task exercises both providers together with the Claude Code facilitator. Run it only after Task 3 passes. The facilitator performs the zero-access preflight for the `claude-cli-exec` provider automatically as part of setup; verify the preflight evidence in Task 5.

- [ ] **Step 1: Record the installed claude version**

Run:

```bash
claude --version
codex --version 2>/dev/null || echo "codex version unavailable via --version"
```

Record both outputs — the smoke test session's `session.md` should contain the provider versions from the preflight.

- [ ] **Step 2: Start the smoke test game**

In this Claude Code session, invoke:

```
Use $game-of-future.
Topic: urban mobility in 2030.
Control mode: development.
Roster: 4 players in two teams of two.
  - Bind mira-chen and elias-ward to codex-cli-exec.
  - Bind rosa-martinez and noor-haddad to claude-cli-exec.
Shared briefing only; no independent research.
Stop after the cliche phase.
```

Expected: the facilitator runs the zero-access preflight for both providers, completes setup and briefing, runs the cliché shout round and dissent pass with all four players, adjudicates, and pauses after Phase 3.

- [ ] **Step 3: Find the session directory**

Run:

```bash
SESSION="$(find game-of-future/sessions -mindepth 1 -maxdepth 1 -type d \
  -name '*-urban-mobility-in-2030' | sort | tail -1)"
test -n "$SESSION"
echo "$SESSION"
```

Expected: prints a path.

---

## Task 5: Verify Smoke Test Artifacts

**Files:**
- Read: session directory found in Task 4 Step 3

- [ ] **Step 0: Re-derive session path**

Run:

```bash
SESSION="$(find game-of-future/sessions -mindepth 1 -maxdepth 1 -type d \
  -name '*-urban-mobility-in-2030' | sort | tail -1)"
test -n "$SESSION"
echo "$SESSION"
```

Expected: prints a path.

- [ ] **Step 1: Verify setup artifacts**

```bash
test -f "$SESSION/session.md"
test -f "$SESSION/roster.md"
test -f "$SESSION/briefing.md"
test -f "$SESSION/public-room.md"
```

Expected: all four files exist.

- [ ] **Step 2: Verify both providers are recorded in roster**

Run:

```bash
rg -n 'codex-cli-exec' "$SESSION/roster.md"
rg -n 'claude-cli-exec' "$SESSION/roster.md"
```

Expected: at least one match each.

- [ ] **Step 3: Verify trace logs exist for all four players**

Run:

```bash
ls "$SESSION/logs/"
```

Expected: `.jsonl` log files for all four players across at least the start and cliché turns (e.g., `mira-chen-start.jsonl`, `rosa-martinez-start.jsonl`, etc.).

- [ ] **Step 4: Verify zero-access preflight for claude-cli-exec player**

The preflight player for `claude-cli-exec` is rosa-martinez (first bound player). Run:

```bash
test -f "$SESSION/logs/rosa-martinez-start.jsonl"
# Zero-access start must have no tool_use events
tool_use_count=$(jq -c 'select(.type=="assistant") | .message.content[] | select(.type=="tool_use")' \
  "$SESSION/logs/rosa-martinez-start.jsonl" 2>/dev/null | wc -l)
echo "tool_use events in rosa-martinez start: $tool_use_count"
test "$tool_use_count" -eq 0
```

Expected: `tool_use events in rosa-martinez start: 0`.

- [ ] **Step 5: Verify the cliché phase ran with all providers**

Run:

```bash
rg -n '^## Cliche Shout Round$' "$SESSION/public-room.md"
rg -n '^## Light Dissent Pass$' "$SESSION/public-room.md"
rg -n '^## Final Cliche List$' "$SESSION/public-room.md"
```

Expected: all three headings present.

- [ ] **Step 6: Verify contributions from both provider types**

Run:

```bash
# mira-chen and elias-ward are codex players; rosa-martinez and noor-haddad are claude players
rg -n 'mira-chen\|Mira Chen' "$SESSION/public-room.md"
rg -n 'rosa-martinez\|Rosa Martinez' "$SESSION/public-room.md"
```

Expected: signed contributions from both codex-cli-exec and claude-cli-exec players in the public room.

- [ ] **Step 7: Verify session.md records both provider versions**

Run:

```bash
rg -n 'claude-cli-exec\|codex-cli-exec' "$SESSION/session.md"
```

Expected: both providers named in the facilitator ledger (preflight records).

- [ ] **Step 8: Report result**

Record in the final response:
- smoke test session path;
- whether both providers completed start and cliché turns;
- zero-access preflight result for `claude-cli-exec`;
- any trace-audit violations encountered;
- final cliché count.
