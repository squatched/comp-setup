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

__source_if_file ${HOME}/.bash_proprietary_pre_all
__display_path_diff "After ~/.bash_proprietary_pre_all"

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Source global definitions
__source_if_file /etc/bashrc
__display_path_diff "After /etc/bashrc"

# Source pre-proprietary stuff
__source_if_file ${HOME}/.bash_proprietary_pre
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
if [[ -z $distributor_id ]] && [[ -f /etc/os-release ]]; then
    distributor_id=$(sed '/^NAME=/ !d; s/NAME="\([^"]\+\)"/\1/' /etc/os-release)
fi

case $distributor_id in
    Arch*|Manjaro*|BlackArch*)
        # Arch based distros
        __source_if_file /usr/share/git/completion/git-prompt.sh
        __source_if_file /usr/share/git/completion/git-completion.bash
        ;;
    Ubuntu|Parrot)
        # Debian distros
        __source_if_file /usr/lib/git-core/git-sh-prompt
        __source_if_file /usr/share/bash-completion/completions/git
        ;;
    MacOS)
        if [[ -e "$(brew --prefix git)/etc/bash_completion.d" ]]; then
            source $(brew --prefix git)/etc/bash_completion.d/git-prompt.sh
            source $(brew --prefix git)/etc/bash_completion.d/git-completion.bash
        fi
        ;;
    "Amazon Linux")
	# Git Completion is handled through /etc/bashrc but git-prompt is not...
	# Go figure.
	__source_if_file /usr/share/git-core/contrib/completion/git-prompt.sh
esac
__display_path_diff "After git prompt & completion"

# Source fzf auto completion
__source_if_file /usr/share/fzf/key-bindings.bash
__source_if_file ${HOME}/.fzf.bash
__display_path_diff "After fzf setup"

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    linux|xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=true

if ${force_color_prompt:-false}; then
    if [[ -x /usr/bin/tput ]] && tput setaf 1 >&/dev/null; then
        # We have color support; assume it's compliant with Ecma-48
        # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
        # a case would tend to support setf rather than setaf.)
        color_prompt=yes
    else
        color_prompt=
    fi
fi

xtc_default=
xtc_yellow=
xtc_green=
xtc_purple=
xtc_red=
xtc_white=
xtc_lblue=
xtc_lgreen=
if [[ ${color_prompt} = yes ]]; then
    # Set a bunch of xTerm colors.
    xtc_default='\[\e[00;00m\]'
    xtc_yellow='\[\e[01;33m\]'
    xtc_green='\[\e[01;32m\]'
    xtc_purple='\[\e[01;34m\]'
    xtc_red='\[\e[00;31m\]'
    xtc_white='\[\e[00;37m\]'
    xtc_lblue='\[\e[01;96m\]'
    xtc_lgreen='\[\e[00;39m\]'
fi

# Prompt customization. Broken up this way to facilitate
# PROMPT_COMMAND='__git_ps1 ...'
# Red with an optional (white) [✗] if the last command failed.
PROMPT_PRE_GIT=$xtc_red'┌─$([[ $? != 0 ]] && echo "['$xtc_white'✗'$xtc_red']─")'
# [user with normal user being green and root being red.
PROMPT_PRE_GIT=$PROMPT_PRE_GIT'['$(if [[ ${EUID} == 0 ]]; then echo $xtc_red'root'; else echo $xtc_lgreen'\u'; fi)
# yellow '@' and light blue hostname with red ']─'.
PROMPT_PRE_GIT=$PROMPT_PRE_GIT$xtc_yellow'@'$xtc_lblue'${HOSTNAME_PROMPT_LABEL:-\h}'$xtc_red']─'
# [pwd] (green)
PROMPT_PRE_GIT=$PROMPT_PRE_GIT'['$xtc_green'\w'$xtc_red']'$xtc_default
# Second line └──╼ $
PROMPT_POST_GIT='\n'$xtc_red'└──╼ '$xtc_yellow'$'$xtc_default

if type __git_ps1 >/dev/null 2>&1; then
    # Git customization, show in yellow.
    PROMPT_GIT=$xtc_red'─['$xtc_yellow'%s'$xtc_red']'$xtc_default

    PROMPT_COMMAND='__git_ps1 "$PROMPT_PRE_GIT" "$PROMPT_POST_GIT" "$PROMPT_GIT"'
else
    PS1=$PROMPT_PRE_GIT$PROMPT_POST_GIT

    unset PROMPT_PRE_GIT PROMPT_POST_GIT
fi

# Set 'man' colors
if [ "$color_prompt" = yes ]; then
    man() {
    env \
        LESS_TERMCAP_mb=$'\e[01;31m' \
        LESS_TERMCAP_md=$'\e[01;31m' \
        LESS_TERMCAP_me=$'\e[0m' \
        LESS_TERMCAP_se=$'\e[0m' \
        LESS_TERMCAP_so=$'\e[01;44;33m' \
        LESS_TERMCAP_ue=$'\e[0m' \
        LESS_TERMCAP_us=$'\e[01;32m' \
        man "$@"
    }
fi

unset color_prompt force_color_prompt

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

# Source script environment setup.
__source_if_file ${HOME}/.bash_script_env
__display_path_diff "After .bash_script_env"

# Alias definitions from a separate file.
__source_if_file $HOME/.bash_aliases
__display_path_diff "After .bash_aliases"

__source_if_file $HOME/.bash_functions
__display_path_diff "After .bash_functions"

# Environment exports from a separate file.
__source_if_file $HOME/.bash_environment
__display_path_diff "After .bash_environment"

# Source completions. The nullglob shenanigans are just in case
# the directory doesn't exist.
ORIGINAL_NULLGLOB=$(shopt -p nullglob)
shopt -s nullglob
for completion_file in $HOME/.bash_completion.d/*; do
  source "$completion_file"
done
$ORIGINAL_NULLGLOB
__display_path_diff "After .bash_completion.d/"

# Proprietary scripts.
__source_if_file $HOME/.bash_proprietary_post
__display_path_diff "After .bash_proprietary_post"

# Always include the systemd expected local bin. This is where I put
# my scripts so to keep things sane, I'll include it even in non
# systemd managed systems.
echo "${PATH}" | grep "/.local/bin" >/dev/null || PATH="${HOME}/.local/bin:${PATH}"
__display_path_diff "After ~/.local/bin setup"

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
__display_path_diff "After FZF setup"
