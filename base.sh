#!/usr/bin/env bash

init() {
    DEFAULT_CONFIG=${XDG_CONFIG_HOME:-$HOME/.config}
    while getopts ':c:d:s:' opt; do
        case $opt in
        c)
            cmd=$OPTARG
            ;;
        d)
            dst_conf=$OPTARG
            ;;
        s)
            src_conf=$OPTARG
            ;;
        \?)
            fail "Invalid option -$OPTARG." >&2
            ;;
        esac
    done
    src_conf=${src_conf:-$(cd -P "$(dirname "$0")" && pwd -P)}
    dst_conf=${dst_conf:-$DEFAULT_CONFIG/${src_conf##*/}}
    cmd=${cmd:-${src_conf##*/}}
}

user() {
    printf '[ \033[0;35m??\033[0m ] %b\n' "$1"
}

warn() {
    printf '[ \033[0;33m!!\033[0m ] %b\n' "$1"
}

info() {
    printf '[ \033[0;34m**\033[0m ] %b\n' "$1"
}

success() {
    printf '[ \033[0;32mOK\033[0m ] %b\n' "$1"
}

fail() {
    printf '[ \033[0;31mXX\033[0m ] %b\n' "$1"
}

link_file() {
    local src=$1 dst=$2
    local overwrite=false backup=false skip=false
    local action=
    local current_src

    if [[ -f $dst || -d $dst || -L $dst ]]; then

        current_src=$(readlink "$dst")

        if [[ $current_src == "$src" ]]; then
            skip=true
        else
            user "File already exists: $dst (src=$(basename "$src")), what do you want to do?\n\
        [s]kip, [o]verwrite, [b]ackup?"
            read -r -n 1 action

            case $action in
            o)
                overwrite=true
                ;;
            b)
                backup=true
                ;;
            s)
                skip=true
                ;;
            *) ;;

            esac

        fi

        if [[ $overwrite == true ]]; then
            \rm -rf "$dst"
            success "Removed $dst"
        fi

        if [[ $backup == true ]]; then
            mv "$dst" "${dst}.backup"
            success "Moved $dst to ${dst}.backup"
        fi

        if [[ $skip == true ]]; then
            info "Skipped to link $src to $dst"
        fi
    fi

    if [[ $skip != true ]]; then # "false" or empty
        if ln -s "$src" "$dst"; then
            success "Linked $src to $dst"
        else
            fail "Fail to link $src to $dst"
        fi

    fi
}

check() {
    if [[ -z $(command -v $cmd) ]]; then
        warn "command not found: $cmd."
        return 1
    fi
}

do_install() {
    mkdir -p "$dst_conf" 2>/dev/null
    for file in $(ls $src_conf -I install.sh); do
        link_file "$src_conf/$file" "$dst_conf/$file"
    done
}

install() {
    init "$@"

    if [[ -z $src_conf ]]; then
        fail 'Without initialization, fail to install.'
        return 1
    fi

    if ! check; then
        return 0
    fi
    success "Installing $cmd config."
    do_install
    success "Installed $cmd config successfully."
}

if [[ $(basename "$0") == base.sh ]]; then
    fail 'Can not run a base shell.'
    exit 1
fi
