#!/bin/zsh

##
# path
home_bin="$HOME/bin"
hlocal_bin="$HOME/.local/bin"
colorgcc="/usr/lib/colorgcc/bin"
opt_bin="/opt/bin"
brew_bin="/usr/local/opt/coreutils/libexec/gnubin:/usr/local/bin"

# homebrew and OS X fixes
if [[ `uname` == "Darwin" ]]; then
    export LANG=en_US.UTF-8
    export LC_ALL=en_US.UTF-8

    PATH=$brew_bin":"$PATH
    fpath=($(brew --prefix)/share/zsh-completions $fpath)
fi

[ -d ~/.zsh/completion ] && fpath=(~/.zsh/completion $fpath)

##
# autoload
autoload -Uz vcs_info
autoload -U colors
colors
autoload -U compinit
compinit -i
autoload edit-command-line
zle -N edit-command-line
autoload zmv
autoload -U select-word-style
select-word-style normal

##
# word delimiters
export WORDCHARS='*?_[]~=&;!#$%^(){}<>'

##
# setopt
setopt autocd              # dirs
setopt autopushd
setopt chasedots           # glob
setopt globdots
setopt extendedglob
setopt appendhistory       # history
setopt extendedhistory
setopt sharehistory
setopt checkjobs           # jobs
setopt nobeep              # no beeping
setopt complete_in_word    # complete
setopt correct correctall  # correct
setopt zle emacs
setopt printexitvalue      # print exit code if non-zero
setopt short_loops         # enable short loops eg: for i in 1 2 3; echo $i

##
# export
if [[ "$HOST" == "GLaDOS" ]]; then
    export EDITOR="emacsclient-emacs-24 --alternate-editor='' -c -nw "
else
    export EDITOR="vim "
fi

##
# PATH
# my defaults
PATH=$colorgcc":"$PATH":"$opt_bin

# ruby
if which ruby 2>&1 >/dev/null; then
    ruby_bin="$(ruby -rrubygems -e 'puts Gem.user_dir')/bin"
    PATH=$ruby_bin":"$PATH
fi

# home bin
PATH=$hlocal_bin":"$PATH
PATH=$home_bin":"$PATH

export PATH

##
# colorful manpages in less
export LESS_TERMCAP_mb=$'\e[1;35m'
export LESS_TERMCAP_md=$'\e[1;34m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[1;30m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;4;38m'
export GROFF_NO_SGR=1

##
# load files
[ -f ~/.zsh_aliases ] && . ~/.zsh_aliases
[ -f ~/.zsh_functions ] && . ~/.zsh_functions

if [[ -f ~/.dircolors-256 ]] & [[ -f ~/.dircolors-8 ]]; then
    [ $(tput colors) = 256 ] &&\
       eval $( dircolors -b ~/.dircolors-256 )
    [ $(tput colors) != 256 ] &&\
       eval $( dircolors -b ~/.dircolors-8 )
fi

[ -f ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh ] && . ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

##
# term dependent options
case $TERM in
    xterm*)
	precmd () {
	    pprecmd
	    title="$(pwd)"
	    printf \\033]0\;\%s\\007 "${title}"
	}
	preexec () {
	    print -Pn "\e]0;$2\a"
	    echo -n ${reset_color}
	}
	;;
    screen*)
	export TERM=screen-256color
	precmd () {
	    pprecmd
	    title="$(pwd)"
	    printf \\033]0\;\%s\\007 "${title}"
	}
	preexec () {
	    print -Pn "\e]0;$2\a\e[0m"
	    echo -n ${reset_color}
	}
	;;
    **)
	precmd () {
	    pprecmd
	}
	preexec () {
	    echo -n ${reset_color}
	}
	;;
esac

##
# git info for prompt
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' unstagedstr " %F{3}✗"
zstyle ':vcs_info:*' stagedstr " %F{2}✔"
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' branchformat "%b:%r"

##
# prompt
pprecmd () {
    if [[ -z $(git ls-files --other --exclude-standard 2> /dev/null) ]] {
	    zstyle ':vcs_info:*' formats " %F{12}[%b%c%u%F{12}]"
    } else {
	    zstyle ':vcs_info:*' formats " %F{12}[%b%c%u %F{9}❤%F{12}]"
    }
    vcs_info

    # get terraform workspace name for prompt
    if [ -f "${PWD}/main.tf" ]; then
      terraform_ws="%F{3}γ `terraform workspace list | awk '/*/{gsub(/* /, "");print}'`"
    else
      terraform_ws=""
    fi

    RPROMPT="%{$fg[black]%}%m $terraform_ws$vcs_info_msg_0_ %(?,%{$fg_bold[green]%}:),%{$fg_bold[red]%};()%{$fg_bold[white]%}"
}

PROMPT="%{$bg[black]$fg_bold[white]%}%3~ %(!,%{$fg_bold[red]%}#,%{$fg_bold[green]%}\$)%{$reset_color%} "

##
# highlight
zle_highlight=(isearch:underline region:bg=blue special:fg=red suffix:underline)

##
# completion
zstyle ':completion:*' completer _expand _complete _list _oldlist _match _ignored _correct _approximate _prefix
zstyle ':completion:*' glob "yes"
zstyle ':completion:*' menu select=2
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' verbose "yes"
zstyle ':completion:*:-command-:*:' verbose "no"
zstyle ':completion:*:approximate:::' max-errors 3
zstyle ':completion:*:descriptions' format "%B-- %d --%b"
zstyle ':completion:*:messages' format\
                    "%B--${GREEN} %d ${WHITE}--%b"
zstyle ':completion:*:warnings' format\
                    "%B--${RED} no match for: %d ${WHITE}--%b"
zstyle ':completion:*:corrections' format\
                    "%B--${YELLOW} %d ${WHITE}-- (errors %e)%b"
zstyle ':completion:*' group-name ''
zstyle ':completion:*:manuals' separate-sections "yes"
zstyle ':completion:*:manuals.(^1*)' insert-sections "yes"
zstyle ':completion:*:options' descriptions "yes"
zstyle ':completion:*:options' auto-description "%d"
zstyle ':completion:*' expand prefix suffix
zstyle ':completion:*' add-space true
zstyle ':completion:*' file-sort name
zstyle ':completion:*:expand:*' tag-order all-expansions
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

##
# ssh-hosts completion
ssh_hosts=()
if [[ -r ~/.ssh/config ]]; then
  ssh_hosts=($h $(awk '/^Host/ && ! /\*/{print $2}' ~/.ssh/config))
fi
if [[ -r ~/.ssh/known_hosts ]]; then
  ssh_hosts=($h $(awk '{gsub(/(,.*|\[|]:.*)/, "");print $1}' ~/.ssh/known_hosts))
fi
if [[ $#h -gt 0 ]]; then
  zstyle ':completion:*:ssh:*' hosts $ssh_hosts
  zstyle ':completion:*:slogin:*' hosts $ssh_hosts
fi

##
# kill completion
zstyle ':completion:*:*:kill:*:processes' list-colors\
                    "=(#b) #([0-9]#)*=0=01;31"
zstyle ':completion:*:*:kill:*:processes' command\
                    "ps -u $USER --forest -o pid,user,cmd"
zstyle ':completion:*:processes-names' command "ps -u $USER axho command"

##
# bind
bindkey '^[[3~' delete-char
bindkey '^[[7~' beginning-of-line
bindkey '^[[8~' end-of-line
bindkey '^[[5~' up-line-or-search
bindkey '^[[6~' down-line-or-search
bindkey '^B'    emacs-backward-word
bindkey '^F'    emacs-forward-word
bindkey '^[b'   backward-char
bindkey '^[f'   forward-char
bindkey '^N'    edit-command-line
bindkey '^K'    kill-line
bindkey -e

##
# history
HISTSIZE=5000
HISTFILE="$HOME/.zsh_history"
SAVEHIST=$HISTSIZE

if [[ $( id -g ) != 0 && ${TERM} != "linux" ]]; then
#    welcome
fi
