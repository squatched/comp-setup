#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Turn off history expansion through '!'.
set +o histexpand

# Disable C-d exiting the shell.
set -o ignoreeof
export IGNOREEOF=1000

# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
export HISTCONTROL=ignoredups:ignorespace

# append to the history file, don't overwrite it
shopt -s histappend

# save multi-line commands as one line
shopt -s cmdhist

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
export HISTSIZE=100000
export HISTFILESIZE=2000000

# ignore the exit command
export HISTIGNORE="&:[ ]*:exit"

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# source git prompt decoration and tab completion
# For arch.
[ -e /usr/share/git/completion/git-prompt.sh ] && source /usr/share/git/completion/git-prompt.sh
[ -e /usr/share/git/completion/git-completion.bash ] && source /usr/share/git/completion/git-completion.bash
# For Ubuntu
[ -e /etc/bash_completion.d/git ] && source /etc/bash_completion.d/git

# Source fzf auto completion
[ -e /etc/profile.d/fzf.bash ] && source /etc/profile.d/fzf.bash

# colorize the font if we're capable of doing so
if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    # We have color support; assume it's compliant with Ecma-48
    # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
    # a case would tend to support setf rather than setaf.)
    color_prompt=yes
else
    color_prompt=
fi

if [ "$color_prompt" = yes ]; then
    PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;94m\]\w\[\033[00m\]\$ '
else
    PS1='\u@\h:\w\$ '
fi
unset color_prompt

# add git decoration
PS1='$(__git_ps1 "\[\e[33;1m\][%s]\[\e[0m\]")'$PS1

# add access to ssh agent (see https://wiki.archlinux.org/index.php/SSH_keys#Start_ssh-agent_with_systemd_user for explanation)
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"

# Alias definitions from a separate file.
[[ -r "$HOME/.bash_aliases" ]] && source "$HOME/.bash_aliases"

# Environment exports from a separate file.
[[ -r "$HOME/.bash_environment" ]] && source "$HOME/.bash_environment"

# Proprietary scripts.
[[ -r "$HOME/.bash_proprietary" ]] && source "$HOME/.bash_environment"
