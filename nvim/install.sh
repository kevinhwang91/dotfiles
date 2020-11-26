#!/usr/bin/env bash

source "$(cd -P "$(dirname "$0")" && pwd -P)/../base.sh"

do_install() {
    mkdir -p "$dst_conf/autoload" 2>/dev/null
    mkdir -p "$dst_conf/lua" 2>/dev/null

    if [[ ! -f "$dst_conf/autoload/plug.vim" ]]; then
        curl -fLo "$dst_conf/autoload/plug.vim" --create-dirs \
            'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    fi

    find "$src_conf/lua" -iname '*.lua' -type f | {
        while read -r file; do
            link_file "$file" "$dst_conf/lua/$(basename $file)" </dev/tty
        done
    }

    find "$src_conf" -iname '*.vim' -type f | {
        while read -r file; do
            link_file "$file" "$dst_conf/$(basename $file)" </dev/tty
        done
    }
    if [[ -x $(command -v yarn) ]]; then
        user "Do you want to install Neovim language-server coc.nvim?\n [y]es, [n]o?"
        read -r -n 1 action
        if [[ $action == y ]]; then
            link_file "$src_conf/coc.vim" "$dst_conf/coc.vim"
            link_file "$src_conf/coc-settings.json" "$dst_conf/coc-settings.json"
        fi
    fi

    nvim +PlugInstall +qa
}

install
