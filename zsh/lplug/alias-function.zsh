if [[ ! $- =~ i ]]; then
    return
fi

if (( $+commands[exa] )); then
    alias ls='exa -gH --time-style=iso'
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
alias reset='reset && source ~/.zshrc'

alias th='trash'

alias gsh='git show'
alias gss='git status'
alias ga='git add'
alias grm='git rm'
alias gd='git diff'
alias gd1='git diff @{1}'
alias gd2='git diff @'
alias gdc='git diff --cached'
alias gdt='git difftool'
alias glt='git log --no-walk --tags --pretty="%h %ci %d %s"'
alias glp='git log --pretty="%h %ci %d %s" --first-parent'
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
        if [[ $o_url =~ \.git$ ]]; then
            n_url=$(sed -E 's|^https://(.*)/(.*)/(.*)|git@\1:\2/\3|' <<<$o_url)
        else
            n_url=$(sed -E 's|^https://(.*)/(.*)/(.*)|git@\1:\2/\3.git|' <<<$o_url)
        fi
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
alias gmF='git merge --no-ff'
alias gms='git merge --ff-only --squash'
alias gmt='git mergetool'

alias gp='git push'
alias gpd='git push -d'
alias gps='git push --set-upstream'
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
alias grh1='git reset --hard @{1}'

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

alias gw='git worktree'
alias gwl='git worktree list'
alias gwa='git worktree add'
alias gwr='git worktree remove'

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
alias dklf='docker logs -f'
alias dkbt='docker build -t'
alias dkis='docker inspect'

# personal go version for suppressing 'declared but not used' and 'imported and not used'
if (( $+commands[kgo] )); then
    alias go='kgo'
fi
alias gor='go run'
alias gob='go build'
alias got='go test'
alias gotv='go test -v'
alias gomi='go mod init'
alias gomt='go mod tidy'
alias gopf='go tool pprof'

alias cco='gcc -o'

alias curljs='curl -X POST -H "Content-Type: application/json" -d @-'

alias -s py='py'
alias py='python'
alias pyhp='python -m http.server'
alias ipy='ipython'
alias pluo='pip list --user --outdated --format=freeze'

alias mux="tmux new -A -s $USER"
alias mlog="tmux new -A -s log"
alias mssh="tmux new -A -s ssh"

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

alias sleepi='sleep infinity'

if (( $+commands[nvim] )); then
    alias nrg='_nrg'
    compdef __nrg_compdef _nrg
    _nrg() {
        if [[ $* ]]; then
            nvim +'pa nvim-treesitter' \
                +"Grepper -noprompt -dir cwd -grepprg rg $* --max-columns=200 -H --no-heading --vimgrep -C0 --color=never"
        else
            rg
        fi
    }
    __nrg_compdef() {
        _rg
    }

    alias ng='_ng'
    _ng() {
        git rev-parse >/dev/null 2>&1 && nvim +"lua require('plugs.fugitive').index()"
    }

    alias ngl='_ngl'
    compdef __ngl_compdef _ngl
    _ngl() {
        git rev-parse >/dev/null 2>&1 && nvim +"Flog -raw-args=${*:+${(q)*}}" +'bw 1'
    }
    __ngl_compdef() {
        (( $+functions[_git-log] )) || _git
        _git-log
    }

    alias ngdt='_ngdt'
    compdef __ngdt_compdef _ngdt
    _ngdt() {
        git rev-parse >/dev/null 2>&1 && nvim +"Git difftool -y $*"
    }
    __ngdt_compdef() {
        (( $+functions[_git-difftool] )) || _git
        _git-difftool
    }

    if (( $+commands[gdb] )); then
        alias ngdb='_ngdb'
        compdef __ngdb_compdef _ngdb
        _ngdb() {
            nvim +"GdbStart gdb $*"
        }
        __ngdb_compdef() {
            _gdb
        }
    fi

    if (( $+commands[python] )); then
        alias npdb='_npdb'
        _npdb() {
            nvim +"GdbStartPDB python -m pdb $*"
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
