#!/usr/bin/env bash

source "$(cd -P "$(dirname "$0")" && pwd -P)/../base.sh"

do_install() {
    dst=${XDG_CONFIG_HOME:+$XDG_CONFIG_HOME/git/config}
    if [[ -f ${dst:=$HOME/.gitconfig} ]]; then
        user "File already exists: $dst, what do you want to do?\n\
        [s]kip, [o]verwrite, [b]ackup?"
            read -r -n 1 action

        if [[ $action == b ]]; then
            mv "$dst" "$HOME/gitconfig.bak"
        fi
    fi

    if [[ -z $action || $action =~ ^[ob] ]]; then
        user 'What is your git user email?'
        read -r -e git_email
        user 'What is you git user name'
        read -r -e git_name

        mkdir "$(dirname $dst)" 2>/dev/null
        sed -e "s/USER_NAME/$git_name/" -e "s/USER_EMAIL/$git_email/" "$src_conf/gitconfig" > $dst
        if [[ -z $(command -v delta) ]]; then
            info 'comment delta in .gitconfig.'
            sed -E -e 's/ (pager)/;\1/' -E 's/ (diffFilter)/;\1/' -i $dst
        fi

    else
        info 'skip to set up git config.'
    fi
}

install
