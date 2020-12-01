# Kevin's dotfiles

This is my personal ArchLinux dotfiles.

## Install all configuration

1. `git clone https://github.com/kevinhwang91/dotfiles.git && cd dotfiles`
2. `./install_all.sh`

## Install configuration respectively

1. `cd xxx`(e.g.,nvim, zsh and tmux)
2. `./install.sh`

## Make your personal configuration

1. `mkdir xxx`(new config directory)
2. `cp template.sh xxx/install.sh`
3. make the content of your personal configuration
4. `./install.sh`
