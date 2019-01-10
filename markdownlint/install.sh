#!/usr/bin/env bash

source "$(cd -P "$(dirname "$0")" && pwd -P)/../base.sh"

do_install() {
    link_file "$src_conf/markdownlintrc" "$HOME/.markdownlintrc"
}

install
