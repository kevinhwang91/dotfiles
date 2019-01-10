# misc
setopt auto_cd
setopt multios
unsetopt nomatch

# edit command using EDITOR
autoload -U edit-command-line
zle -N edit-command-line
bindkey '\C-x\C-e' edit-command-line

# disable ctrl+s
stty -ixon

# enable key home and end
bindkey "${terminfo[khome]}" beginning-of-line
bindkey "${terminfo[kend]}" end-of-line

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

if ! functions insert-last-command-output >/dev/null; then
    insert-last-command-output() {
        LBUFFER+="$(eval $history[$((HISTCMD-1))])"
    }
    zle -N insert-last-command-output
    bindkey '^[j' insert-last-command-output
fi

KEYTIMEOUT=1
bindkey -M menuselect '\e' send-break
