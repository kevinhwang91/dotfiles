if (( ! $+commands[tmux] )) || [[ -z $TMUX ]] || [[ ! $- =~ i ]]; then
    return
fi

tmux_update_env_preexec() {
    local tmux_event=${TMUX%%,*}-event/client-attached-pane
    if [[ -f $tmux_event-$TMUX_PANE ]]; then
        eval $(tmux showenv -s)
        command rm $tmux_event-$TMUX_PANE 2>/dev/null
    fi
}

local tmux_event=${TMUX%%,*}-event/client-attached-pane
command rm $tmux_event-$TMUX_PANE 2>/dev/null

autoload -U add-zsh-hook
add-zsh-hook preexec tmux_update_env_preexec
