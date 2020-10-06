#!/usr/bin/env bash

source "$(cd -P "$(dirname "$0")" && pwd -P)/../base.sh"

do_install() {
    link_file "$src_conf/zshrc" "${ZDOTDIR:-$HOME}/.zshrc"
    mkdir -p "$DEFAULT_CONFIG/zsh" 2>/dev/null
    link_file "$src_conf/lplug" "$DEFAULT_CONFIG/zsh/lplug"

    if [[ ! $SHELL =~ zsh ]]; then
        user "zsh is not your default shell, do you make it default?\n [y]es, [n]o?"
        read -r -n 1 action
        if [[ $action == y ]]; then
            chsh -s "$(command -v zsh)"
        fi
    fi
}

install
