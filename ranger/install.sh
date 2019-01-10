#!/usr/bin/env bash

source "$(cd -P "$(dirname "$0")" && pwd -P)/../base.sh"

do_install() {
    ranger_plugin_dot=$src_conf/plugins
    ranger_plugin_home=$dst_conf/plugins

    mkdir -p $dst_conf 2>/dev/null
    link_file "$src_conf/rc.conf" "$dst_conf/rc.conf"
    link_file "$src_conf/rifle.conf" "$dst_conf/rifle.conf"
    link_file "$src_conf/scope.sh" "$dst_conf/scope.sh"

    mkdir -p "$ranger_plugin_home" 2>/dev/null
    find "$ranger_plugin_dot" -iname '*.py' -type f | {
        while read -r file; do
            link_file "$file" "$ranger_plugin_home/$(basename "$file")" </dev/tty
        done
    }
}

install
