#!/bin/bash
export PATH="/opt/homebrew/bin:$PATH"

PROJECTS_DIR="${1:-$HOME/projects/github.com/Brendan-MacKenzie}"  # Accept dir as argument, default to set

# Skip hidden folders and only get actual directories
for path in "$PROJECTS_DIR"/*/; do
    [[ ! -d "$path" ]] && continue
    
    name=$(basename "$path")
    
    # Skip if session already exists (lets you re-run safely)
    tmux has-session -t "$name" 2>/dev/null && continue
    
    tmux new-session -d -s "$name" -c "$path" -n "code"
    tmux send-keys -t "$name:code" "nvim" Enter
    
    tmux new-window -t "$name" -c "$path" -n "git"
    tmux send-keys -t "$name:git" "lazygit" Enter
done

first_session=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | head -1)
[[ -n "$first_session" ]] && tmux attach -t "$first_session"
