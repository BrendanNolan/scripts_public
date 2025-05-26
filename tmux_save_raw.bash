#!/usr/bin/env bash

tmux list-panes -a -F '#{session_name} #{window_index} #{window_name} #{pane_current_path}' | awk -v home="$HOME" '
BEGIN {
    ignore["fish"]
    ignore["bash"]
    ignore["zsh"]
    ignore["nushell"]
    ignore["nu"]
}
{
    session=$1
    window=$2
    title=$3
    path=$4
    if (index(path, home) == 1) {
        path = "$HOME" substr(path, length(home)+1)
    }
    key = session "-" window
    if (!(session in sessions)) {
        sessions_list[++session_count] = session
        sessions[session] = 1
    }
    if (!(key in seen)) {
        seen[key] = 1
        entry = (title in ignore) ? sprintf("{\"dir\":\"%s\"}", path) : sprintf("{\"dir\":\"%s\",\"title\":\"%s\"}", path, title)
        windows[session] = windows[session] entry ","
    }
}
END {
    printf("[")
    for (i = 1; i <= session_count; i++) {
        s = sessions_list[i]
        winlist = windows[s]
        sub(/,$/, "", winlist)
        printf("{\"session\":\"%s\",\"windows\":[%s]}", s, winlist)
        if (i < session_count) printf(",")
    }
    printf("]\n")
}'

