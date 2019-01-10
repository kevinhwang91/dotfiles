#!/usr/bin/env bash

source "$(cd -P "$(dirname "$0")" && pwd -P)/../base.sh"

do_install() {
    mpv_script_dot=$src_conf/scripts
    mpv_script_home=$dst_conf/scripts

    mkdir -p $dst_conf 2>/dev/null
    link_file "$src_conf/input.conf" "$dst_conf/input.conf"
    link_file "$src_conf/mpv.conf" "$dst_conf/mpv.conf"

    mkdir -p "$mpv_script_home" 2>/dev/null
    find "$mpv_script_dot" -type f | {
        while read -r file; do
            link_file "$file" "$mpv_script_home/$(basename "$file")" </dev/tty
        done
    }
}

install
