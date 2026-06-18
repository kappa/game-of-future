#!/usr/bin/env bash
# Game of Future — player session runner
# Supports providers: claude-cli-exec, codex-cli-exec
#
# Usage:
#   run-player.sh start          <provider> <session_handle> <session_root> <prompt_file> <log_file> <response_file>
#   run-player.sh resume         <provider> <session_handle> <session_root> <prompt_file> <log_file> <response_file>
#   run-player.sh extract-handle <provider> <log_file>
#   run-player.sh audit          <provider> <log_file>
#   run-player.sh gen-uuid
#   run-player.sh shuf           <item1> [item2 ...]

set -euo pipefail

COMMAND="${1:-}"
shift || true

case "$COMMAND" in

  start)
    PROVIDER="$1"; SESSION_HANDLE="$2"; SESSION_ROOT="$3"
    PROMPT_FILE="$4"; LOG_FILE="$5"; RESPONSE_FILE="$6"
    case "$PROVIDER" in
      claude-cli-exec)
        claude --print --verbose --safe-mode --dangerously-skip-permissions \
          --output-format stream-json \
          --model opus \
          --session-id "$SESSION_HANDLE" \
          --allowedTools "Read,Write,Edit" \
          --add-dir "$SESSION_ROOT" \
          < "$PROMPT_FILE" > "$LOG_FILE"
        jq -r 'select(.type=="result") | .result' "$LOG_FILE" > "$RESPONSE_FILE"
        ;;
      codex-cli-exec)
        codex --ask-for-approval never --sandbox workspace-write \
          -C "$SESSION_ROOT" exec \
          --ignore-user-config --ignore-rules --json --skip-git-repo-check \
          -o "$RESPONSE_FILE" - < "$PROMPT_FILE" > "$LOG_FILE"
        ;;
      *)
        echo "Unknown provider: $PROVIDER" >&2; exit 1 ;;
    esac
    ;;

  resume)
    PROVIDER="$1"; SESSION_HANDLE="$2"; SESSION_ROOT="$3"
    PROMPT_FILE="$4"; LOG_FILE="$5"; RESPONSE_FILE="$6"
    case "$PROVIDER" in
      claude-cli-exec)
        claude --print --verbose --safe-mode --dangerously-skip-permissions \
          --output-format stream-json \
          --model opus \
          --resume "$SESSION_HANDLE" \
          --allowedTools "Read,Write,Edit" \
          --add-dir "$SESSION_ROOT" \
          < "$PROMPT_FILE" > "$LOG_FILE"
        jq -r 'select(.type=="result") | .result' "$LOG_FILE" > "$RESPONSE_FILE"
        ;;
      codex-cli-exec)
        codex --ask-for-approval never --sandbox workspace-write \
          -C "$SESSION_ROOT" exec resume \
          --ignore-user-config --ignore-rules --json --skip-git-repo-check \
          -o "$RESPONSE_FILE" "$SESSION_HANDLE" - < "$PROMPT_FILE" > "$LOG_FILE"
        ;;
      *)
        echo "Unknown provider: $PROVIDER" >&2; exit 1 ;;
    esac
    ;;

  extract-handle)
    # Prints the non-secret session handle from a start log.
    # For claude-cli-exec, the handle is the --session-id UUID passed at start (caller already knows it).
    # For codex-cli-exec, extract thread_id from the thread.started JSONL event.
    PROVIDER="$1"; LOG_FILE="$2"
    case "$PROVIDER" in
      claude-cli-exec)
        echo "handle-is-session-id" ;;
      codex-cli-exec)
        jq -r 'select(.type=="thread.started") | .thread_id' "$LOG_FILE" | head -1 ;;
      *)
        echo "Unknown provider: $PROVIDER" >&2; exit 1 ;;
    esac
    ;;

  audit)
    # Prints tool_use / command events for facilitator allowlist check.
    PROVIDER="$1"; LOG_FILE="$2"
    case "$PROVIDER" in
      claude-cli-exec)
        jq -r 'select(.type=="assistant") |
          .message.content[]? |
          select(.type=="tool_use") |
          "TOOL: \(.name) | PATH: \(.input.file_path // .input.command // "(none)")"' \
          "$LOG_FILE" 2>/dev/null || true
        ;;
      codex-cli-exec)
        jq -r 'select(.type=="command" or .type=="tool_call" or .type=="file_op") |
          "EVENT: \(.type) | \(.command // .name // .path // "(none)")"' \
          "$LOG_FILE" 2>/dev/null || true
        ;;
      *)
        echo "Unknown provider: $PROVIDER" >&2; exit 1 ;;
    esac
    ;;

  gen-uuid)
    python3 -c "import uuid; print(uuid.uuid4())"
    ;;

  shuf)
    printf '%s\n' "$@" | shuf
    ;;

  *)
    echo "Unknown command: ${COMMAND}" >&2
    echo "Usage: run-player.sh start|resume|extract-handle|audit|gen-uuid|shuf [args...]" >&2
    exit 1
    ;;
esac
