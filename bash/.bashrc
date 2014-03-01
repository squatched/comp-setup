#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

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
source /usr/share/git/completion/git-prompt.sh
source /usr/share/git/completion/git-completion.bash

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

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# Environment exports.
# You may want to put all your environment variables into a
# separate file like ~/.bash_env instead of adding them here
# directly.
if [ -f ~/.bash_environment ]; then
    . ~/.bash_environment
fi

# Proprietary scripts.
if [ -f ~/.bash_proprietary ]; then
    e ~/.bash_proprietary
fi

# make rvm scripts available
#source $HOME/.rvm/scripts/rvm

# That below was the default values of this file.
#alias ls='ls --color=auto'
#PS1='[\u@\h \W]\$ '
