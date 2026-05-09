#!/bin/bash

# An agentic harness for Claude or Copilot to port code from one project to another.

SESSION_NAME_BASE="portgrid"
SESSION_NAME="$SESSION_NAME_BASE"
PARENT_DIR="$1"
PROMPT_FILE="$2"
AGENT_CMD="${3:-claude}"
AGENT_BIN="${AGENT_CMD%% *}"

# Usage information
if [ $# -lt 2 ]; then
    echo "Usage: $0 <parent_directory> <prompt_file> [agent_command]"
    echo "Example: $0 /path/to/parent prompt.md 'copilot --allow-all --model gpt-4.1'"
    exit 1
fi

# Validate parent directory exists
if [ ! -d "$PARENT_DIR" ]; then
    echo "Error: Parent directory '$PARENT_DIR' not found"
    exit 1
fi

# Check if prompt file exists
if [ ! -f "$PROMPT_FILE" ]; then
    echo "Error: Prompt file '$PROMPT_FILE' not found"
    exit 1
fi

# Validate agent command exists
if ! command -v "$AGENT_BIN" >/dev/null 2>&1; then
    echo "Error: Agent command '$AGENT_BIN' not found in PATH"
    echo "Install it first or pass a valid agent command"
    exit 1
fi

# Discover all immediate subdirectories in parent directory
SUBDIRS=()
while IFS= read -r dir; do
    SUBDIRS+=("$(basename "$dir")")
done < <(find "$PARENT_DIR" -mindepth 1 -maxdepth 1 -type d | sort)

if [ ${#SUBDIRS[@]} -eq 0 ]; then
    echo "Error: No subdirectories found in '$PARENT_DIR'"
    exit 1
fi

# Check if tmux session already exists
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "Warning: tmux session '$SESSION_NAME' already exists."
    while true; do
        read -r -p "Create a new session with an incremented name? [y/N]: " create_new
        case "$create_new" in
        [yY] | [yY][eE][sS])
            suffix=1
            while tmux has-session -t "${SESSION_NAME_BASE}${suffix}" 2>/dev/null; do
                ((suffix++))
            done
            SESSION_NAME="${SESSION_NAME_BASE}${suffix}"
            echo "Using new session '$SESSION_NAME'."
            break
            ;;
        [nN] | [nN][oO] | "")
            echo "Keeping existing session. Exiting."
            exit 0
            ;;
        *)
            echo "Please answer yes or no."
            ;;
        esac
    done
fi

# Get absolute path of prompt file
PROMPT_FILE="$(cd "$(dirname "$PROMPT_FILE")" && pwd)/$(basename "$PROMPT_FILE")"

# Launch agent in a window.
# Claude uses piped prompt input.
# Copilot does not accept piped prompt input, so we start it interactively, then send prompt content via delayed tmux paste-buffer.
launch_agent_in_window() {
    local target="$1"
    local repo_dir="$2"

    if [ "$AGENT_BIN" = "copilot" ]; then
        tmux send-keys -t "$target" "cd \"$repo_dir\" && $AGENT_CMD" C-m
        tmux run-shell -b "sleep 4; tmux load-buffer \"$PROMPT_FILE\"; tmux paste-buffer -t \"$target\"; tmux send-keys -t \"$target\" C-m"
    else
        tmux send-keys -t "$target" "cd \"$repo_dir\" && cat \"$PROMPT_FILE\" | $AGENT_CMD" C-m
    fi
}

# Create new tmux session with first window
FIRST_DIR="${SUBDIRS[0]}"
FIRST_REPO_DIR="$PARENT_DIR/$FIRST_DIR"
tmux new-session -d -s "$SESSION_NAME" -n "$FIRST_DIR"
launch_agent_in_window "$SESSION_NAME:$FIRST_DIR" "$FIRST_REPO_DIR"

# Create additional windows for remaining subdirectories
for i in "${!SUBDIRS[@]}"; do
    if [ "$i" -eq 0 ]; then
        continue # Skip first one, already created
    fi

    SUBDIR="${SUBDIRS[$i]}"
    REPO_DIR="$PARENT_DIR/$SUBDIR"
    tmux new-window -t "$SESSION_NAME" -n "$SUBDIR"
    launch_agent_in_window "$SESSION_NAME:$SUBDIR" "$REPO_DIR"
done

# Attach to the tmux session
tmux attach-session -t "$SESSION_NAME"
