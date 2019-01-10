# history
if [ -z $HISTFILE ]; then
    HISTFILE=$HOME/.zsh_history
fi

HISTSIZE=10000000
SAVEHIST=10000000

setopt extended_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_verify
setopt hist_reduce_blanks
setopt inc_append_history
setopt share_history
