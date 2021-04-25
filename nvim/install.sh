#!/usr/bin/env bash

source "$(cd -P "$(dirname "$0")" && pwd -P)/../base.sh"

do_install() {
    mkdir -p "$dst_conf" 2>/dev/null

    link_file "$src_conf/colors" "$dst_conf/colors"
    link_file "$src_conf/ftplugin" "$dst_conf/ftplugin"
    link_file "$src_conf/ftdetect" "$dst_conf/ftdetect"
    link_file "$src_conf/after" "$dst_conf/after"
    link_file "$src_conf/lua" "$dst_conf/lua"
    link_file "$src_conf/init.lua" "$dst_conf/init.lua"

    if [[ -x $(command -v yarn) ]]; then
        user "Do you want to install Neovim language-server coc.nvim?\n [y]es, [n]o?"
        read -r -n 1 action
        if [[ $action == y ]]; then
            link_file "$src_conf/coc-settings.json" "$dst_conf/coc-settings.json"
        fi
    fi
    nvim --headless +PackerInstall +qa
}

install
