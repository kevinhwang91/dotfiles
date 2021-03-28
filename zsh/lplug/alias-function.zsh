if [[ ! $- =~ i ]]; then
    return
fi

if (( $+commands[exa] )); then
    alias ls='exa -gH --time-style=iso '
    alias la='ls -a -a'
    alias ll='ls -al -a'
else
    alias ls='ls --color=tty --time-style=iso'
    alias la='ls -a'
    alias ll='ls -al'
fi

alias mv='mv -i'
alias cp='cp -i'
alias rm='rm -i'

alias th='trash'

alias gsh='git show'
alias gss='git status'
alias ga='git add'
alias grm='git rm'
alias gd='git diff'
alias gdc='git diff --cached'
alias gdt='git difftool'
alias glt='git log --no-walk --tags --pretty="%h %ci %d %s"'
alias glct='git describe --tags $(git rev-list --tags --max-count=1)'
alias grt='cd "$(git rev-parse --show-toplevel || echo .)"'
alias grmv='git remote -v'
alias grms='git remote set-url'

alias grmsu='_grmsu'
compdef __grmsu_compdef _grmsu
_grmsu() {
    local o_url
    local n_url
    local remote=$1
    o_url=$(git remote get-url $remote)
    (( ? )) && return
    if [[ $o_url =~ ^git ]]; then
        n_url=$(sed -E 's|^git@(.*):/*(.*).git|https://\1/\2.git|' <<<$o_url)
    elif [[ $o_url =~ ^https ]]; then
        n_url=$(sed -E 's|^https://(.*)/(.*)/(.*).git|git@\1:\2/\3.git|' <<<$o_url)
    fi
    print "remote: $remote\nold url: $o_url\nnew url: $n_url"
    read -sk 1 "?(y/N)"
    print
    if [[ $REPLY =~ ^[yY] ]]; then
        git remote set-url $remote $n_url
    fi
}
__grmsu_compdef() {
    (( $+functions[__git_remotes] )) || _git
    _arguments '1: :__git_remotes'
}

alias gf='git fetch'
alias gfa='git fetch --all --prune'
alias gl='git pull --rebase'
alias glm='git pull --merge'
alias gm='git merge'
alias gma='git merge --abort'
alias gmf='git merge --ff-only --squash'
alias gmF='git merge --no-ff'
alias gms='git merge --squash'
alias gmt='git mergetool'

alias gp='git push'
alias gpd='git push -d'
alias gb='git branch'
alias gba='git branch -a'
alias gbd='git branch -D'
alias gbr='git branch --remote'

alias gco='git checkout'
alias gcu='git checkout --'
alias gcb='git checkout -b'
alias gcl='git clone --recurse-submodules'
alias gclean='git clean -id'
alias gcm='git commit -m'
alias gce='git commit'
alias gca='git commit --amend'

alias gcp='git cherry-pick'
alias gcpn='git cherry-pick --no-commit'
alias gcpa='git cherry-pick --abort'
alias gcpc='git cherry-pick --continue'

alias grb='git rebase'
alias grbo='git rebase --strategy-option=ours'
alias grbt='git rebase --strategy-option=theirs'
alias grba='git rebase --abort'
alias grbc='git rebase --continue'
alias grbe='git rebase --edit-todo'
alias grbi='git rebase --interactive'
alias grbs='git rebase --skip'

alias gr='git reset'
alias gru='git reset --'
alias grh='git reset --hard'

alias gst='git stash'
alias gsta='git stash apply'
alias gstc='git stash clear'
alias gstd='git stash drop'
alias gstl='git stash list'
alias gstp='git stash pop'
alias gsts='git stash show -p --ext-diff'
alias gstu='git stash --include-untracked --keep-index'

alias gbs='git bisect'
alias gbsb='git bisect bad'
alias gbsg='git bisect good'
alias gbsr='git bisect reset'
alias gbss='git bisect start'

alias gfp='git format-patch --stdout -1'
alias gaa='git am --abort'
alias gac='git am --continue'
alias gas='git am --skip'
alias ga3='git am --3way <'

alias gsu='git submodule update'
alias gsco='git submodule foreach git checkout'
alias gsl='git submodule foreach git pull'

alias rg5='rg -C 5'

alias umb='udisksctl mount -b'
alias uub='udisksctl unmount -b'

alias dk='docker'
alias dkr='docker run'
alias dhri='docker run -i -t --rm --network=host'
alias dkrd='docker run -d'

alias dke='docker exec -i -t'
alias dkp='docker ps'
alias dkpe='docker ps -f status=exited'
alias dki='docker images'
alias dklf='docker log -f'
alias dkbt='docker build -t'
alias dkis='docker inspect'

alias gor='go run'
alias gob='go build'

alias cco='gcc -o'

alias curljs='curl -X POST -H "Content-Type: application/json" -d @-'

alias -s py='py'
alias py='python'
alias pyhp='python -m http.server'
alias ipy='ipython'
alias pluo='pip list --user --outdated --format=freeze'

alias mux="tmux new -A -s $USER"

alias rr='ranger'

alias rsync-cp='rsync -avz --progress -h'
alias rsync-mv='rsync -avz --progress -h --remove-source-files'
alias rsync-update='rsync -avzu --progress -h'
alias rsync-sync='rsync -avzu --delete --progress -h'

alias qc='qalc'

alias jq='jq --indent 4'

alias yg='yarn global'

alias zz='z -'

alias clocf='cloc --by-file --vcs=git .'
alias clocl='cloc --by-file-by-lang --vcs=git .'

if (( $+commands[htop] )); then
    alias top='htop'
fi

alias topp='top -p'

alias lsf='lsof -w'
alias lsfp='lsof -w -p'

alias vmst='vmstat -SM 1'
alias iost='iostat -y -d -h -t 1'

if (( $+commands[nvim] )); then
    alias nrg='_nrg'
    compdef __nrg_compdef _nrg
    _nrg() {
        opts=$(printf '%q ' "$@")
        nvim +"Grepper -noprompt -dir cwd -grepprg rg $opts -H --no-heading --vimgrep -C0 --color=never"
    }
    __nrg_compdef() {
        _rg
    }

    alias ng='_ng'
    _ng() {
        git status >/dev/null && nvim +Git +'winc o' +'bw 1'
    }

    alias ngl='_ngl'
    compdef __ngl_compdef _ngl
    _ngl() {
        git status >/dev/null && nvim +"Flog -raw-args=$*" +'bw 1'
    }
    __ngl_compdef() {
        (( $+functions[_git-log] )) || _git
        _git-log
    }

    alias ngdt='_ngdt'
    compdef __ngdt_compdef _ngdt
    _ngdt() {
        git status >/dev/null && nvim +"Git difftool -y $*" +'bw 1'
    }
    __ngdt_compdef() {
        (( $+functions[_git-difftool] )) || _git
        _git-difftool
    }

    if (( $+commands[gdb] )); then
        alias ngdb='_ngdb'
        compdef __ngdb_compdef _ngdb
        _ngdb() {
            nvim +"GdbStart gdb $*" +'bw 1'
        }
        __ngdb_compdef() {
            _gdb
        }
    fi

    if (( $+commands[python] )); then
        alias npdb='_npdb'
        _npdb() {
            nvim +"GdbStartPDB python -m pdb $*" +'bw 1'
        }
    fi
fi

alias Sudo='command sudo '

alias sudo='_sudo'
_sudo() {
    local cmd=$1
    local type=$(which -w $cmd | cut -d\  -f2)

    if [[ $type == function ]]; then
        shift
        # TODO issue with calling nested function
        command sudo -E zsh -c "$(typeset -f $cmd);$cmd $*"
    elif [[ $type == alias ]]; then
        functions[_t_expand_alias]=$@ 2>/dev/null
        if (( $+functions[_t_expand_alias] )); then
            set -- ${(z)functions[_t_expand_alias]#$'\t'}
            unset -f _t_expand_alias

            local cmd=$1
            type=$(which -w $1 | cut -d\  -f2)
            if [[ $type == function ]]; then
                shift
                command sudo -E zsh -c "$(typeset -f $cmd);$cmd $*"
            else
                eval "command sudo -E $@"
            fi
        fi
    else
        command sudo -E $@
    fi
}
