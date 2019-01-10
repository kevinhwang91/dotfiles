prompt_preexec() {
    typeset -gA git_info
    if [[ -n $git_info[top] ]]; then
        if [[ $2 =~ git\ (.*\ )?(pull|fetch)(\ .*)?$ ]]; then
            async_flush_jobs 'git_prompt'
        fi

        if [[ $2 =~ git\ (.*\ )?status(\ .*)?$ ]]; then
            git_info[last_dirty_check_timestamp]=
            git_info[cached]=
            git_info[fast_check]=
            async_flush_jobs 'git_prompt'
        fi
    fi
}

prompt_render() {
    local branch_color
    local dirty_color
    typeset -gA git_info

    if (( git_info[cached] == 1 )); then
        branch_color=$git_colors[cached]
        dirty_color=$git_colors[cached]
    else
        branch_color=$git_colors[branch]
        dirty_color=$git_colors[dirty]
    fi

    local git_prompt
    if [[ -n $git_info[branch] ]]; then
        local branch="%F{$branch_color}$git_info[branch]"
        if [[ -n $git_info[action] ]]; then
            branch+="%F{$git_colors[upright]}|"
            branch+="%F{$git_colors[action]}$git_info[action]%F{$branch_color}%f"
        fi
        git_prompt+="$branch%F{$dirty_color}$git_info[dirty]%f"
    fi
    if [[ -n $git_info[arrow] ]]; then
        git_prompt+="%F{$git_colors[arrow]}$git_info[arrow]%f"
    fi
    if [[ -n $git_info[stash] ]]; then
        git_prompt+="%F{$git_colors[stash]}$git_info[stash]%f"
    fi

    RPROMPT=$git_prompt

    local expanded_prompt
    expanded_prompt=${(%%)RPROMPT}
    if [[ $last_prompt != $expanded_prompt ]]; then
        zle && zle reset-prompt
    fi
    typeset -g last_prompt=$expanded_prompt
}

prompt_precmd() {
    prompt_async_git_tasks
}

git_stash_count() {
    command git stash list | wc -l
}

git_simple_info_task() {
    zstyle ':vcs_info:*' enable git
    zstyle ':vcs_info:*' use-simple true
    zstyle ':vcs_info:*' max-exports 3
    zstyle ':vcs_info:git*' formats '%b' '%R'
    zstyle ':vcs_info:git*' actionformats '%b' '%R' '%a'

    vcs_info

    local -A info
    info[pwd]=$PWD
    info[top]=$vcs_info_msg_1_
    info[branch]=$vcs_info_msg_0_
    info[action]=$vcs_info_msg_2_

    print -r - ${(@kvq)info}
}

git_dirty_task() {
    local -i fast_check=$1
    if (( fast_check == 1 )); then
        test -z $(git status --porcelain --ignore-submodules -uno)
    else
        test -z $(git status --porcelain --ignore-submodules -unormal)
    fi
    return $?
}

git_fetch_task() {
    export GIT_TERMINAL_PROMPT=0
    command git -c gc.auto=0 fetch >/dev/null || return 99
    git_arrows_task
}

git_arrows_task() {
    command git rev-list --left-right --count HEAD...@'{u}'
}

prompt_async_git_tasks() {
    if (( ! ${prompt_async_init:-0} )); then
        RPROMPT=
        async_start_worker 'git_prompt' -u -n
        async_register_callback 'git_prompt' prompt_async_callback
        typeset -g prompt_async_init=1
    fi

    async_worker_eval 'git_prompt' builtin cd -q $PWD

    typeset -gA git_info
    if [[ $PWD != ${git_info[top]}* ]]; then
        async_flush_jobs 'git_prompt'
        git_info=
    fi

    async_job 'git_prompt' git_simple_info_task
    if [[ -n $git_info[top] ]]; then
        git_refresh
    fi
}

git_refresh() {
    if [[ $git_info[top] != $HOME ]]; then
        async_job 'git_prompt' git_fetch_task
    fi

    local -i last_dirty_check=$(( EPOCHSECONDS - ${git_info[last_dirty_check_timestamp]:-0} ))
    if (( last_dirty_check > ${GIT_DIRTY_TIMEOUT:-60} )); then
        git_info[last_dirty_check_timestamp]=
        async_job 'git_prompt' git_dirty_task ${git_info[fast_check]:-0}
    fi

    async_job 'git_prompt' git_stash_count
    async_job 'git_prompt' git_arrows_task
}

check_git_arrows() {
    local arrows left=${1:-0} right=${2:-0}
    typeset -gA git_symbols

    if (( right > 0 )); then
        arrows+=$git_symbols[arrow_down]
        arrows+=$right
    fi

    if (( left > 0 )); then
        arrows+=$git_symbols[arrow_up]
        arrows+=$left
    fi

    if [[ -n $arrows ]]; then
        print $arrows
    fi
}

prompt_async_callback() {
    local job=$1 code=$2 output=$3 exec_time=$4 next_pending=$6
    local do_render=0

    typeset -gA git_info
    typeset -gA git_symbols
    case $job in
        \[async])
            if (( code == 2 )); then
                typeset -g prompt_async_init=0
            fi
            ;;
        git_simple_info_task)
            local -A info
            info=("${(Q@)${(z)output}}")
            if [[ $info[pwd] != $PWD ]]; then
                return
            fi
            if [[ $info[top] != $git_info[top] ]]; then
                async_flush_jobs 'git_prompt'
                git_refresh
            fi

            git_info[branch]=$info[branch]
            git_info[top]=$info[top]
            git_info[action]=$info[action]
            do_render=1
            ;;
        git_stash_count)
            local stash_status
            local -i count=$output
            if (( count > 0 )); then
                stash_status="${git_symbols[stash]}$count"
            fi
            if [[ $git_info[stash] != $stash_status ]]; then
                git_info[stash]=$stash_status
                do_render=1
            fi
            ;;
        git_dirty_task)
            local prev_dirty=$git_info[dirty]
            if (( code == 0 )); then
                git_info[dirty]=
            else
                git_info[dirty]=$git_symbols[dirty]
            fi

            if [[ $prev_dirty != $git_info[dirty] ]]; then
                do_render=1
            fi
            if (( exec_time > 5 )); then
                if (( git_info[fast_check] == 1 )); then
                    git_info[last_dirty_check_timestamp]=$EPOCHSECONDS
                else
                    git_info[fast_check]=1
                fi
                git_info[cached]=1
            else
                git_info[cached]=
            fi
            ;;
        git_fetch_task|git_arrows_task)
            case $code in
                0)
                    local arrows_status=$(check_git_arrows ${(ps:\t:)output})
                    if [[ $git_info[arrow] != $arrows_status ]]; then
                        git_info[arrow]=$arrows_status
                        do_render=1
                    fi
                    ;;
                99)
                    ;;
                *)
                    if [[ -n $git_info[arrow] ]]; then
                        git_info[arrow]=
                        do_render=1
                    fi
                    ;;
            esac
            ;;
    esac

    if (( next_pending )); then
        if (( do_render )); then
            typeset -g render_requested=1
        fi
        return
    fi

    if (( ${render_requested:-$do_render} == 1 )); then
        prompt_render
    fi
    unset render_requested
}

prompt_setup() {
    autoload -Uz add-zsh-hook
    autoload -Uz vcs_info
    autoload -Uz async && async

    add-zsh-hook precmd prompt_precmd
    add-zsh-hook preexec prompt_preexec
}

typeset -gA git_colors
typeset -gA git_symbols
git_colors=(
    arrow        11
    branch       13
    cached       09
    action       10
    dirty        14
    stash        08
    upright      07
)

git_symbols=(
    arrow_up        ⇡
    arrow_down      ⇣
    dirty           
    stash           
)

# GIT_DIRTY_TIMEOUT=60
prompt_setup
