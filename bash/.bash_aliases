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

# Enable emacsclient while sudoing.
alias sudoemacsclient="SUDO_EDITOR=\"emacsclient -nw\" sudo -e"