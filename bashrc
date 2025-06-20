# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

shopt -s cdspell

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
  if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    # We have color support; assume it's compliant with Ecma-48
    # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
    # a case would tend to support setf rather than setaf.)
    color_prompt=yes
  else
    color_prompt=
  fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

PS1='[\u@\h \w$(__git_ps1 " (%s)")]\$ '

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# used to reattach ssh forwarding to "stale" tmux sessions
# http://justinchouinard.com/blog/2010/04/10/fix-stale-ssh-environment-variables-in-gnu-screen-and-tmux/
function refresh_ssh() {
  if [[ -n $TMUX ]]; then
    NEW_SSH_AUTH_SOCK=$(tmux showenv | grep ^SSH_AUTH_SOCK | cut -d = -f 2)
    if [[ -n $NEW_SSH_AUTH_SOCK ]] && [[ -S $NEW_SSH_AUTH_SOCK ]]; then
      SSH_AUTH_SOCK=$NEW_SSH_AUTH_SOCK
    fi
  fi
}
function ssh_refresh() {
  if [[ -n $TMUX ]]; then
    NEW_SSH_AUTH_SOCK=$(tmux showenv | grep ^SSH_AUTH_SOCK | cut -d = -f 2)
    if [[ -n $NEW_SSH_AUTH_SOCK ]] && [[ -S $NEW_SSH_AUTH_SOCK ]]; then
      SSH_AUTH_SOCK=$NEW_SSH_AUTH_SOCK
    fi
  fi
}

function ge(){
  # "grep and edit"
  # usage: ge <string>
  echo "grep --exclude-dir=*\.git -rl "$@" | xargs -o vi"
  grep --exclude-dir=*\.git -rl "$@" | xargs -o vi
}

#
# Find in report and preview/edit
#
function frs(){
  avrt --grep $1                                                | \
    fzf --preview-window='50%'                                    \
        --layout=reverse                                          \
        --preview='avrt --sql_cat $(echo {} | cut -d ':' -f 1)' | \
    cut -d ':' -f 1                                             | \
    xargs  -o avrt --sql
}

function frh(){
  avrt --grep $1                                                 | \
    fzf --preview-window='50%'                                     \
        --layout=reverse                                           \
        --preview='avrt --html_cat $(echo {} | cut -d ':' -f 1)' | \
    cut -d ':' -f 1                                              | \
    xargs  -o avrt --html
}

#
# Functions from Wolf
#
function f() { # f <pattern> : list all the files in or below . whose names match the given pattern
  fd --follow --no-ignore --hidden --glob "$@" 2>/dev/null
}

function fcat() { # fcat <pattern> : find all the files in or below . whose names match the given pattern and cat them
  fd --follow --no-ignore --hidden --glob --type f "$@" --exec-batch bat
}

function fcd() { # fcd <pattern> : find the first directory in or below . whose name matches the given pattern and cd into it
  # example: fcd js
  # example: fcd '*venv'
  # example: fcd --regex 'venv$'
  local FIRST_MATCHING_DIRECTORY

  FIRST_MATCHING_DIRECTORY="$(fd --follow --no-ignore --hidden --glob --type d --max-results 1 "$@" 2>/dev/null)"
  if [ -d "${FIRST_MATCHING_DIRECTORY}" ]; then
    cd "${FIRST_MATCHING_DIRECTORY}" || return
  fi
}

function fcd_of { # fcd_of <pattern> : find the first file-system object in or below . whose name matches the given pattern, and cd into the directory that contains it
  local FIRST_MATCH
  local PARENT_OF_FIRST_MATCH

  FIRST_MATCH="$(fd --follow --no-ignore --hidden --glob --max-results 1 "$@" 2>/dev/null)"
  PARENT_OF_FIRST_MATCH="$(dirname "${FIRST_MATCH}")"

  if [ -d "${PARENT_OF_FIRST_MATCH}" ]; then
    cd "${PARENT_OF_FIRST_MATCH}" || return
  fi
}

function fe() { # fe <pattern> : find all the files in or below . whose names match the given pattern and open them in $EDITOR
  # shellcheck disable=SC2086
  fd --follow --no-ignore --hidden --glob --type f "$@" --exec-batch ${EDITOR}
}

function fll() { # fll <pattern> : find all the files in or below . whose names match the given pattern, and list them as would ls -l
  fd --follow --no-ignore --hidden --glob "$@" --exec-batch exa -Fal
}

function fsource() { # fsource <pattern> : find all the files in or below . whose names match the given pattern and source them
  local FILES_TO_SOURCE
  declare -a FILES_TO_SOURCE

  readarray -d '' FILES_TO_SOURCE < <(fd --follow --no-ignore --hidden --glob --type f --print0 "$@")

  # shellcheck disable=SC1090,SC2086
  source "${FILES_TO_SOURCE[@]}"
}

alias grep='/bin/grep --color=auto --exclude-dir=*\.git --binary-files=without-match'
alias fd='fdfind'

alias cba='cd /usr/local/Avairis'
alias lc='ls -C --color=yes'
alias ls='ls --color=never'
alias htidy='tidy --indent yes                 \
                  --indent-spaces 2            \
                  --indent-attributes yes      \
                  --uppercase-tags yes         \
                  --output-html yes            \
                  --uppercase-attributes yes   \
                  --priority-attributes TYPE   \
                  --sort-attributes alpha      \
                  --drop-empty-elements no     \
                  --merge-divs no              \
                  --merge-spans no             \
                  --drop-empty-elements no     \
                  --drop-empty-paras no        \
                  --coerce-endtags no          \
                  --fix-style-tags no          \
                  --join-styles no             \
                  --merge-emphasis no          \
                  --break-before-br yes        \
                  --wrap 0                     \
                  -quiet                       \
                  --mute-id yes                \
                  --mute PROPRIETARY_ATTRIBUTE \
                  --mute MISSING_DOCTYPE       \
                  --mute INSERTING_TAG         \
                  --mute INVALID_UTF8          \
                  --mute MISSING_TITLE_ELEMENT \
                  --output-file /tmp/x.html'

alias stsb='git status -sb'

#
# dps = docker ps with a bunch of formatting
# Look at the following links:
#   https://docs.docker.com/engine/cli/formatting/
#   https://pkg.go.dev/text/template#pkg-overview
#
alias dps="docker ps --format 'table {{.ID}}\t{{.Image}}\t{{.Status}}\t{{join ( slice ( split ( join ( slice ( split .Ports \", \" ) 0 1  ) \"\" ) \":\" ) 1 ) \"\"}}\t{{.Names}}'"

HISTSIZE=-1
HISTFILESIZE=-1
HISTTIMEFORMAT='%F %T '

EDITOR=vim
FCEDIT=vim
VISUAL=vim

if [ -f ~/dot_files/git-prompt.sh ]; then
  . ~/dot_files/git-prompt.sh
  export GIT_PS1_SHOWDIRTYSTATE=1
  export GIT_PS1_SHOWUNTRACKEDFILES=1
  export GIT_PS1_UPSTREAM="auto"
  export GIT_PS1_SHOWCOLORHINTS=1
fi

umask 002
