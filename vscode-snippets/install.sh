#!/usr/bin/env bash

source "$(cd -P "$(dirname "$0")" && pwd -P)/../base.sh"

do_install() {
    vscode_snippets="$HOME/.config/Code/User/snippets"
    mkdir -p "vscode_snippets" 2>/dev/null
    link_file "$src_conf/snippets" "$vscode_snippets"
}

install -c true
