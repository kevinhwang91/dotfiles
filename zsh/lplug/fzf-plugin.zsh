if (( ! $+commands[fzf] )) || [[ ! $- =~ i ]]; then
    return
fi

FZF_DEFAULT_OPTS="--height=60% --color=fg:-1,bg:-1,hl:#c3d82c,fg+:15,bg+:#383c4a,hl+:#c3d82c \
--color=gutter:-1,info:2,prompt:12,pointer:1,marker:3,spinner:12,header:12,border:#b3c0ce \
--bind=alt-,:first,alt-.:last,change:first,ctrl-r:toggle-all,alt-p:toggle-preview"

if (( $+commands[xsel] )); then
    FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS,ctrl-y:'execute-silent(echo {} | xsel -i -b)'"
elif (( $+commands[xclip] )); then
    FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS,ctrl-y:'execute-silent(echo {} | xclip -i -selection clipboard)'"
fi

export FZF_DEFAULT_OPTS

if [[ -n $TMUX_PANE ]] && (( $+commands[tmux] )) && (( $+commands[fzfp] )); then
    export TMUX_POPUP_NESTED_FB='test $(tmux display -pF "#{==:#S,floating}") == 1'
    FZF_CMD="$commands[fzfp]"
else
    FZF_CMD=$commands[fzf]
fi

_fzf_fpath=${0:h}/fzf
fpath+=$_fzf_fpath
autoload -U $_fzf_fpath/*(.:t)
unset _fzf_fpath

fzf-redraw-prompt() {
    local precmd
    for precmd in $precmd_functions; do
        $precmd
    done
    zle reset-prompt
}
zle -N fzf-redraw-prompt

zle -N fzf-find-widget
bindkey '^T' fzf-find-widget

fzf-cd-widget() {
    local tokens=(${(z)LBUFFER})
    if (( $#tokens <= 1 )); then
        zle fzf-find-widget 'only_dir'
        if [[ -d $LBUFFER ]]; then
            cd $LBUFFER
            local ret=$?
            LBUFFER=
            zle fzf-redraw-prompt
            return $ret
        fi
    fi
}
zle -N fzf-cd-widget
bindkey '^S' fzf-cd-widget

fzf-history-widget() {
    local num=$(fhistory $LBUFFER)
    local ret=$?
    if [[ -n $num ]]; then
        zle vi-fetch-history -n $num
    fi
    zle reset-prompt
    return $ret
}
zle -N fzf-history-widget
bindkey '^R' fzf-history-widget

fzf-z-cd-widget() {
    local dir=$(fzt)
    if [[ -z $dir ]]; then
        zle redisplay
        return 0
    fi
    cd $dir
    local ret=$?
    zle fzf-redraw-prompt
    return $ret
}
zle -N fzf-z-cd-widget
bindkey '^G' fzf-z-cd-widget

zle -N fzf-completion-widget
bindkey '^I' fzf-completion-widget
