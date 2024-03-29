export COLORTERM=truecolor

if [[ ! $- =~ i ]]; then
    return
fi
# grc wrapper
if (( $+commands[grc] )); then
    cmds=(
        ping
        traceroute
        stat
        ss
        mount
        findmnt
        ps
        df
        du
        ip
        env
        systemctl
        iptables
        lspci
        lsblk
        lsof
        blkid
        id
        iostat sar
        fdisk
        docker docker-compose
        sysctl
        lsmod
        lsattr
        vmstat
        free
        nmap
        uptime
        trash-list
    )

    for cmd in $cmds; do
        if (( $+commands[$cmd] )) ; then
            eval "function $cmd() {stdbuf -oL grc --colour=auto $cmd \$@}"
        fi
    done
    unset cmds cmd
fi

# remove color
# with option -i to remove color in the file
rmc() {
    sed -E 's/\x1B\[[0-9;]*[Km]//g' $@
}

# color

autoload -U colors && colors

if [[ -z $LS_COLORS ]] && (( $+commands[dircolors] )); then
    eval "$(dircolors -b)"
fi
zstyle ':completion:*' list-colors ${(s/:/)LS_COLORS}
