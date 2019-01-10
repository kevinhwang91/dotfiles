# grc wrapper
if (( $+commands[grc] )); then
    cmds=(
        ping
        traceroute
        cc gcc g++ c++
        make gmake bear
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
        nmap
        uptime
        trash-list
    )

    for cmd in $cmds; do
        if (( $+commands[$cmd] )) ; then
            eval "function $cmd() {grc --colour=auto $cmd \$@}"
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
export COLORTERM=truecolor

autoload -U colors && colors

if [[ -z $LS_COLORS ]]; then
    eval "$(dircolors -b)"
fi
zstyle ':completion:*' list-colors ${(s/:/)LS_COLORS}
unset LS_COLORS
