if [[ ! $- =~ i ]]; then
    return
fi

# misc
setopt auto_cd
setopt multios
setopt long_list_jobs
unsetopt nomatch

# glob
# ERE syntax     zsh extended glob
# (foo)*         (foo)#
# (foo)+         (foo)##
# (foo)?         (|foo)
# (foo|bar)      (foo|bar)
setopt extendedglob

# edit command using EDITOR
autoload -U edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line

# disable ctrl+s
stty -ixon

# enable home and end key
bindkey $terminfo[khome] beginning-of-line
bindkey $terminfo[kend] end-of-line

# use backward-kill-line instead of kill-whole-line
bindkey '^U' backward-kill-line

# expand alias recursively
expand-alias() {
    functions[_t_expand_alias]=$LBUFFER 2>/dev/null
    if (( $+functions[_t_expand_alias] )); then
        LBUFFER="${functions[_t_expand_alias]#$'\t'} "
        unset -f _t_expand_alias
    fi
}
zle -N expand-alias
bindkey '^Xa' expand-alias

# vim key menu select
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char

# reverse menu select
bindkey -M menuselect '^[[Z' reverse-menu-complete

reverse-insert-last-word () { zle insert-last-word 1 -1 }
zle -N reverse-insert-last-word
bindkey '^[>' reverse-insert-last-word

autoload -U copy-earlier-word
zle -N copy-earlier-word
bindkey '^[,' copy-earlier-word

if (( ! $+widgets[insert-last-cmd-out] )); then
    insert-last-cmd-out() {
        LBUFFER+=$(eval $history[$(( HISTCMD-1 ))])
    }
    zle -N insert-last-cmd-out
    bindkey '^[O' insert-last-cmd-out
fi

# esc cancel completion menu
KEYTIMEOUT=1
bindkey -M menuselect '^[' send-break

# calibrate the SHLVL
if (( SHLVL > 1 )); then
    local ttys=("${(@f)$(ps -o tty= -p $$ -p $PPID)}")
    if [[ $ttys[1] != $ttys[2] ]]; then
        SHLVL=1
    fi
fi
