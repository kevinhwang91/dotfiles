#!/usr/bin/env bash

source "$(cd -P "$(dirname "$0")" && pwd -P)/../base.sh"

install -c 'rime_dict_manager' -d "$HOME/.config/ibus/rime"
