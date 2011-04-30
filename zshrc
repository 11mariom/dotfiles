#!/bin/zsh

##
# autoload
autoload -Uz vcs_info
autoload -U colors
colors
autoload -U compinit
compinit

##
# setopt
setopt complete_in_word 
setopt correct correctall
setopt chasedots
setopt zle emacs
setopt checkjobs
setopt autocd 
setopt appendhistory 
setopt extendedhistory

##
# export
export EDITOR="emacsclient --alternate-editor='' -c -nw "

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

if [[ -f /home/mario/.dircolors-256 ]] & [[ -f /home/mario/.dircolors-8 ]]; then
    [ $(tput colors) = 256 ] &&\
       eval $( dircolors -b /home/mario/.dircolors-256 )
    [ $(tput colors) != 256 ] &&\
       eval $( dircolors -b /home/mario/.dircolors-8 )
fi

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
zstyle ':vcs_info:*' unstagedstr " $YELLOW✗"
zstyle ':vcs_info:*' stagedstr " $BGREEN✔"
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' branchformat "%b:%r"

##
# prompt
NO_COLOR="%{${reset_color}%}"
for color in RED GREEN YELLOW WHITE BLACK CYAN; do
    eval $color='%{$fg[${(L)color}]%}'
    eval B$color='%{$fg_bold[${(L)color}]%}'
done

pprecmd () {
    if [[ -z $(git ls-files --other --exclude-standard 2> /dev/null) ]] {
	    zstyle ':vcs_info:*' formats " %F{12}[%b%c%u%F{12}]"
    } else {
	    zstyle ':vcs_info:*' formats " %F{12}[%b%c%u %F{9}❤%F{12}]"
    }
    vcs_info

    RPROMPT="$vcs_info_msg_0_ %(?,$BGREEN:),$BRED;()$BWHITE"
}

PROMPT="%{$bg[black]%}$BWHITE%3~ %(!,$BRED#,$BGREEN\$)$NO_COLOR "

##
# completion
zstyle ':completion:*' completer _list _oldlist _match _prefix\
       _expand _complete _ignored _correct _approximate 
zstyle ':completion:*' glob "yes"
zstyle ':completion:*' menu select=1
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' verbose 'yes'
zstyle ':completion:*:descriptions' format "%B-- %d --%b"
zstyle ':completion:*:messages' format\
                    "%B--${GREEN} %d ${WHITE}--%b"
zstyle ':completion:*:warnings' format\
                    "%B--${RED} no match for: %d ${WHITE}--%b"
zstyle ':completion:*:corrections' format\
                    "%B--${YELLOW} %d ${WHITE}-- (errors %e)%b"
zstyle ':completion:*' group-name ''
zstyle ':completion:*:manuals' separate-section "yes"
zstyle ':completion:*:options' description "yes"
zstyle ':completion:*:options' auto-description "%d"
zstyle ':completion:*' expand prefix suffix
zstyle ':completion:*' add-space true
zstyle ':completion:*' file-sort name
zstyle ':comlpetion:*:expand:*' tag-order all-expansions

##
# kill completion
zstyle ':completion:*:*:kill:*:processes' list-colors\
                    "=(#b) #([0-9]#)*=0=01;31"
zstyle ':completion:*:*:kill:*:processes' command\
                    "ps --forest -A -o pid,user,cmd"
zstyle ':completion:*:processes-names' coomand "ps axho command"

##
# bind
bindkey '^[[3~' delete-char
bindkey '^[[7~' beginning-of-line
bindkey '^[[8~' end-of-line
bindkey '^[[5~' up-line-or-search
bindkey '^[[6~' down-line-or-search
bindkey -e

##
# history
HISTSIZE=1000
HISTFILE="$HOME/.zsh_history"
SAVEHIST=$HISTSIZE

if [[ $( id -g ) != 0 ]]; then
    welcome
fi
