#!/bin/zsh

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

export EDITOR="emacsclient --alternate-editor='' -c -nw "

##
# prompt
setopt promptsubst
autoload -U colors
colors

for color in RED GREEN YELLOW WHITE BLACK CYAN; do
    eval $color='%{$fg[${(L)color}]%}'
    eval B$color='%{$fg_bold[${(L)color}]%}'
done
NO_COLOR="%{${reset_color}%}"

pprecmd () {
    if [[ -z $(git ls-files --other --exclude-standard 2> /dev/null) ]] {
	    zstyle ':vcs_info:*' formats ' %F{12}[%b%c%u%F{12}]'
    } else {
	    zstyle ':vcs_info:*' formats ' %F{12}[%b%c%u $RED❤%F{12}]'
    }
    vcs_info

    PROMPT="%{$bg[black]%}$BWHITE%3~ $BGREEN\$$NO_COLOR "
    RPROMPT="$vcs_info_msg_0_ %(?,$BGREEN:),$BRED;()$BWHITE"
}




autoload -Uz vcs_info

zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' unstagedstr ' $YELLOW✗'
zstyle ':vcs_info:*' stagedstr ' $BGREEN✔'
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' branchformat '%b:%r'



##
# completion
autoload -U compinit
compinit
zstyle ':completion:*' completer _list _oldlist _match _prefix\
       _expand _complete _ignored _correct _approximate 
zstyle ':completion:*' glob 'yes'
zstyle ':completion:*' menu select=1
zstyle ':completion:*' list-colors $(dircolors)
zstyle ':completion:*' verbose 'yes'
zstyle ':completion:*:descriptions' format "%B-- %d --%b"
zstyle ':completion:*:messages' format "%B--${GREEN} %d ${WHITE}--%b"
zstyle ':completion:*:warnings' format "%B--${RED} no match for: %d ${WHITE}--%b"
zstyle ':completion:*:corrections' format "%B--${YELLOW} %d ${WHITE}-- (errors %e)%b"
zstyle ':completion:*' group-name ''
zstyle ':completion:*:manuals' separate-section 'yes'
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:options' auto-description '%d'
zstyle ':completion:*' expand prefix suffix
zstyle ':completion:*' add-space true
zstyle ':completion:*' file-sort name
zstyle ':comlpetion:*:expand:*' tag-order all-expansions

##
# kill completion
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:*:kill:*:processes' command 'ps --forest -A -o pid,user,cmd'
zstyle ':completion:*:processes-names' coomand 'ps axho command'

setopt complete_in_word


##
# setopt setopt autocd extendedglob complete_in_word
setopt correct correctall
setopt chasedots
setopt zle emacs
setopt checkjobs
setopt autocd 

##
# bind
bindkey '^[[3~' delete-char
bindkey '^[[7~' beginning-of-line
bindkey '^[[8~' end-of-line
bindkey '^[[5~' up-line-or-search
bindkey '^[[6~' down-line-or-search
bindkey -e

##
# extract
ext () {
    if [ -f $1 ]; then
	case $1 in
	    *.tar.bz2)  tar -jxvf $1        ;;
            *.tar.gz)   tar -zxvf $1        ;;
            *.bz2)      bzip2 -d $1         ;;
            *.gz)       gunzip -d $1        ;;
            *.tar)      tar -xvf $1         ;;
            *.tgz)      tar -zxvf $1        ;;
	    *.tbz2)     tar -xvzf $1        ;;
            *.zip)      unzip $1            ;;
            *.Z)        uncompress $1       ;;
	    *.7z)       7z x $1             ;;
            *.rar)      unrar x $1          ;;
	    *.xz)       xz -d $1            ;;
            *)          echo "'$1' Error. Please go away" ;;
	esac
    else
	echo "'$1' is not valid!"
    fi
}

compdef '_files -g "*.{tar.bz2,tar.gz,bz2,gz,tar,tgz,tbz2,zip,Z,7z,rar,xz}"' ext

cd() {
    builtin cd $*
    ls --color="auto"
}

pflv() {
    pid=$(pgrep -f flashplayer | tail -l)
    file=$(lsof -p ${pid} | awk '/\/tmp\/Flash/ {sub(/[rwu]$/, "", $4); print "/proc/" $2 "/fd/" $4}')
    
    mplayer2 ${file}
}

##
# alias
alias b="cd .."
alias e=$EDITOR
alias l="ls --color=auto"
alias s="su"
alias x="exit"


##
# default options
alias ebuild="FEATURES=-mini-manifest ebuild"
alias grep="grep --color=auto"
alias ls="ls --color=auto"
alias tmux="tmux -2"

## 
# global alias
alias -g G='| grep'
alias -g H='| head'
alias -g L='| less'
alias -g T='| tail'

##
# dirs
hash -d t="/home/mario/tmp"
hash -d D="/media/Dane"
hash -d cdrom="/media/cdrom"

# history
setopt appendhistory extendedhistory
HISTSIZE=1000
HISTFILE="$HOME/.zsh_history"
SAVEHIST=$HISTSIZE

##
# welcome

B="`date +'%B'`" 

case "$B" in
    "styczeń") export mc='stycznia' ;;
    "luty") export mc='lutego' ;;
    "marzec") export mc='marca' ;;
    "kwiecień") export mc='kwietnia' ;;
    "maj") export mc='maja' ;;
    "czerwiec") export mc='czerwca' ;;
    "lipiec") export mc='lipca' ;;
    "sierpień") export mc='sierpnia' ;;
    "wrzesień") export mc='września' ;;
    "październik") export mc='października' ;;
    "listopad") export mc='listopada' ;;
    "grudzień") export mc='grudnia' ;;
    *) mc="`date +'%B'`"
esac


echo "Witaj mariom. Jest $(date +'%H:%M'), $(date +'%A %d') $mc, $(date +'%j dzień roku %Y')."
