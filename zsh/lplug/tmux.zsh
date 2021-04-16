if (( ! $+commands[tmux] )) || [[ -z $TMUX_PANE ]] || [[ ! $- =~ i ]]; then
    return
fi

_tmux_update_env_preexec() {
    local tmux_event=${TMUX%%,*}-event/client-attached-pane
    if [[ -f $tmux_event-$TMUX_PANE ]]; then
        eval $(tmux showenv -s)
        command rm $tmux_event-$TMUX_PANE 2>/dev/null
    fi
}

local tmux_event=${TMUX%%,*}-event/client-attached-pane
command rm $tmux_event-$TMUX_PANE 2>/dev/null

autoload -U add-zsh-hook
add-zsh-hook preexec _tmux_update_env_preexec

if [[ $TMUX_SESSION == 'floating' ]]; then
    _tmux_floating_precmd() {
        local info=$(tmux display -pF "#{session_attached} #S")
        local attached=${info:0:1}
        local name=${info:2}
        if (( attached )); then
            if [[ $name != $TMUX_SESSION ]]; then
                add-zsh-hook -D precmd _tmux_floating_precmd
                unset -f _tmux_floating_precmd
                unset TMUX_SESSION
            fi
        else
            tmux display -N -d 1000 "$TMUX_SESSION task has done."
        fi
    }

    add-zsh-hook precmd _tmux_floating_precmd
fi
