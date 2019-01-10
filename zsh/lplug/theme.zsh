setopt prompt_subst

_fishy_path() {
    local tree=(${(s:/:)$(print -D $PWD)})
    local dir result
    if [[ $tree[1] == '~' ]]; then
        result=$tree[1]
        shift tree
    fi
    for dir in $tree; do
        if (( $#tree == 1 )); then
            result+=/$tree
            break
        fi
        local part=$dir[1]
        if [[ $part == . ]]; then
            part+=$dir[2]
        fi
        result+=/$part
        shift tree
    done
    print ${result:-/}
}

_path_color() {
    if [[ -z $SSH_CONNECTION ]]; then
        print %F{012}
    else
        print %F{013}
    fi
}

_py_virtual_env () {
    if [[ -n $VIRTUAL_ENV ]]; then
        print "%F{005}${VIRTUAL_ENV:t} "
    fi
}

export VIRTUAL_ENV_DISABLE_PROMPT=1
PROMPT='%B%(?.%F{002}✔ .%F{001}✘ )$(_py_virtual_env)$(_path_color)$(_fishy_path)\
 %(1j.%F{003}[%j] .)%(2L.%F{006}(%L) .)%f%b'
