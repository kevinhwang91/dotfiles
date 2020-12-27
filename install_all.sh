#!/usr/bin/env bash

DOTFILES_ROOT=$(cd -P "$(dirname "$0")" && pwd -P)

bash "$DOTFILES_ROOT/script/install.sh"
find "$DOTFILES_ROOT" -path '*/script' -prune -o -name '*install.sh' -executable -type f -exec {} \;
