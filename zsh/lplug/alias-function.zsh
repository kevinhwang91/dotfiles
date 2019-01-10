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
alias grmsu='_grmsu'

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

alias -s py='py'
alias py='python'
alias ipy='ipython'
alias pluo='pip list --user --outdated --format=freeze'

alias mux='tmux attach 2>/dev/null || tmux'

alias rr='ranger'

alias qc='qalc'

alias jq='jq --indent 4'

alias yg='yarn global'

alias Sudo='command sudo '

alias sudo='_sudo'
_sudo() {
    local cmd=$1
    local type=$(which -w $cmd | cut -d\  -f2)

    if [[ $type == function ]]; then
        shift
        command sudo -E zsh -c "$(declare -f $cmd);$cmd $*"
    elif [[ $type == alias ]]; then
        alias _sudo='command sudo -E '
        eval "_sudo $@"
        unalias _sudo
    else
        command sudo -E $@
    fi
}

if (( $+commands[nvim] )); then
    alias ng='_ng'
    _ng() {
        git status >/dev/null && nvim +Git +'wincmd o' +'bwipeout #'
    }

    alias ngl='_ngl'
    _ngl() {
        git status >/dev/null && nvim +"Flog -raw-args=$*" +1tabclose
    }
fi
