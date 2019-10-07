#
# ~/.bashrc
#

__source_if_file () {
    [[ -f "$1" ]] && source "$1"
}

#DEBUG_PATH=true
PATH_CACHE=

__format_path () {
    echo "${PATH//:/$'\n'}"
}

__update_path_cache () {
   [[ $DEBUG_PATH != true ]] && return 0

    PATH_CACHE=$(__format_path)
}

__display_path () {
   [[ $DEBUG_PATH != true ]] && return 0

   echo "$1 PATH:"
   __format_path
   echo $'\n'
}

__display_path_diff () {
   [[ $DEBUG_PATH != true ]] && return 0

    DISP_PATH=$(__format_path)
    echo "$1 PATH Differences:"
    diff --normal <(echo "$PATH_CACHE") <(echo "$DISP_PATH")
    echo ""
    PATH_CACHE=$DISP_PATH
}

__update_path_cache
__display_path "Initial path"

__source_if_file ~/.bash_proprietary_pre_all
__display_path_diff "After ~/.bash_proprietary_pre_all"

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Source global definitions
__source_if_file /etc/bashrc
__display_path_diff "After /etc/bashrc"

# Source pre-proprietary stuff
__source_if_file ~/.bash_proprietary_pre
__display_path_diff "After ~/.bash_proprietary_pre"

# Turn off history expansion through '!'.
#set +o histexpand

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

# ignore the exit command and duplicates
export HISTIGNORE="&:[ ]*:exit:ignoredups"

# Tell ncurses to always use UTF-8 line drawing characters
export NCURSES_NO_UTF8_ACS=1

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[[ -x /usr/bin/lesspipe ]] && eval "$(SHELL=/bin/sh lesspipe)"

# source git prompt decoration and tab completion
distributor_id=''
hash brew 2>/dev/null && distributor_id="MacOS"
if hash lsb_release 2>/dev/null; then
    distributor_id=$(lsb_release -a 2>/dev/null | sed --expression '/^Distributor ID:/!d' --regexp-extended --expression 's/^[^:]+:\s*//')
fi

# For arch.
if [[ ${distributor_id} == Arch ]]; then
    __source_if_file /usr/share/git/completion/git-prompt.sh
    __source_if_file /usr/share/git/completion/git-completion.bash
fi

# For Ubuntu
if [[ ${distributor_id} == Ubuntu ]]; then
    __source_if_file /etc/bash_completion.d/git
    __source_if_file /etc/bash_completion.d/git-prompt
    __source_if_file /usr/share/bash-completion/completions/git
fi

# For MacOS
if [[ ${distributor_id} == MacOS ]] && [[ -e "$(brew --prefix git)/etc/bash_completion.d" ]]; then
    source $(brew --prefix git)/etc/bash_completion.d/git-prompt.sh
    source $(brew --prefix git)/etc/bash_completion.d/git-completion.bash
fi
__display_path_diff "After git prompt & completion"

# Source fzf auto completion
__source_if_file /usr/share/fzf/key-bindings.bash
__source_if_file ~/.fzf.bash
__display_path_diff "After fzf setup"

# Source pyenv/rbenv auto completion
__source_if_file ~/.rbenv/completions/rbenv.bash
__source_if_file ~/.pyenv/completions/pyenv.bash

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [[ -n ${force_color_prompt} ]]; then
    if [[ -x /usr/bin/tput ]] && tput setaf 1 >&/dev/null; then
        # We have color support; assume it's compliant with Ecma-48
        # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
        # a case would tend to support setf rather than setaf.)
        color_prompt=yes
    else
        color_prompt=
    fi
fi

if [[ ${color_prompt} = yes ]]; then
    PS1='\[\033[01;32m\]\u@${HOSTNAME_PROMPT_LABEL:-\h}\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='\u@${HOSTNAME_PROMPT_LABEL:-\h}:\w\$ '
fi
unset color_prompt force_color_prompt

# add git decoration
PS1='$(__git_ps1 "\[\e[33;1m\][%s]\[\e[0m\]")'$PS1

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [[ -f /usr/share/bash-completion/bash_completion ]]; then
    . /usr/share/bash-completion/bash_completion
  elif [[ -f /etc/bash_completion ]]; then
    . /etc/bash_completion
  fi
fi

if [[ -e /usr/bin/aws_completer ]]; then
    complete -C '/usr/bin/aws_completer' aws
fi

# Configure Perforce
[[ -f $HOME/.p4config ]] && export P4CONFIG=$HOME/.p4config

# Alias definitions from a separate file.
__source_if_file $HOME/.bash_aliases
__display_path_diff "After .bash_aliases"

__source_if_file $HOME/.bash_functions
__display_path_diff "After .bash_functions"

# Environment exports from a separate file.
__source_if_file $HOME/.bash_environment
__display_path_diff "After .bash_environment"

# Proprietary scripts.
__source_if_file $HOME/.bash_proprietary_post
__display_path_diff "After .bash_proprietary_post"
