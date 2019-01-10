autoload -U compinit && compinit

# complete menu
unsetopt menu_complete
zmodload -i zsh/complist
zstyle ':completion:*:*:*:*:*' menu select

# complete match case insensitive for lowercase
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
