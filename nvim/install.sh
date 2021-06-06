#!/usr/bin/env bash

source "$(cd -P "$(dirname "$0")" && pwd -P)/../base.sh"

do_install() {
    mkdir -p "$dst_conf" 2>/dev/null

    link_file "$src_conf/ftplugin" "$dst_conf/ftplugin"
    link_file "$src_conf/syntax" "$dst_conf/syntax"
    link_file "$src_conf/after" "$dst_conf/after"
    link_file "$src_conf/lua" "$dst_conf/lua"
    link_file "$src_conf/init.lua" "$dst_conf/init.lua"
    link_file "$src_conf/coc-settings.json" "$dst_conf/coc-settings.json"

    info "Installing nvim's plugins......"
    nvim --headless -u NORC --noplugin +"au User PackerComplete qa" +"sil lua require('plugs.packer').install()" >/dev/null
}

install
