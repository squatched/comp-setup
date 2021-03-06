#!/bin/bash

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'

    alias ls='ls --color=auto'
    alias ll='ls --color=auto -AlFh'
    alias la='ls --color=auto -A'
    alias l='ls --color=auto -CF'
else
    alias ll='ls -alF'
    alias la='ls -A'
    alias l='ls -CF'
fi

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Enable emacsclient while sudoing.
alias sudoemacsclient="SUDO_EDITOR=\"emacsclient --tty\" sudo -e"
alias sudodoom-emacsclient="SUDO_EDITOR=\"emacsclient --tty --socket-name=doom \" sudo -e"
alias sudoemacs="SUDO_EDITOR=\"emacs --no-window-system\" sudo -e"
alias sudodoom-emacs="SUDO_EDITOR=\"emacs --with-profile=doom --no-window-system\" sudo -e"

# Add the UUID to lsblk's default output.
alias lsblk="lsblk --output=+UUID"
alias ps-grep='ps aux | grep -v grep | grep'
