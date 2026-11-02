#!/bin/zsh
##
# human shell: real terminal, not a tool/agent (Claude Code sets CLAUDECODE).
# Behaviour that prompts, prints or changes command semantics is limited to it.
typeset -gi human=0
[[ -t 1 && -z $CLAUDECODE ]] && human=1

##
# path
home_bin="$HOME/bin"
hlocal_bin="$HOME/.local/bin"

# homebrew and OS X fixes
if [[ `uname` == "Darwin" ]]; then
    export LANG=en_US.UTF-8
    export LC_ALL=en_US.UTF-8

    # hardcoded, `brew --prefix` costs a subprocess on every shell
    [[ -d /opt/homebrew ]] && brew_prefix=/opt/homebrew || brew_prefix=/usr/local

    PATH="$brew_prefix/opt/coreutils/libexec/gnubin:$brew_prefix/bin:$PATH"
    [ -d $brew_prefix/share/zsh-completions ] && fpath=($brew_prefix/share/zsh-completions $fpath)
fi

[ -d ~/.zsh/completion ] && fpath=(~/.zsh/completion $fpath)

# generated completions live outside dotfiles
zsh_comp_cache="$HOME/.cache/zsh/completions"
[ -d $zsh_comp_cache ] || mkdir -p $zsh_comp_cache
fpath=($zsh_comp_cache $fpath)

# home bin
PATH="$home_bin:$hlocal_bin:$PATH"

# no duplicates in nested shells
typeset -U path fpath
export PATH

##
# generated completions: (re)generate only when missing or the tool got updated
# usage: _cache_completion <command> <args...>
_cache_completion() {
    local name=$1 f="$zsh_comp_cache/_$1"
    (( $+commands[$name] )) || return
    [[ -s $f && $f -nt $commands[$name] ]] && return
    "$@" > $f 2>/dev/null && rm -f ~/.zcompdump*
}
_cache_completion kubectl completion zsh
_cache_completion autorestic completion zsh

##
# setopt (extendedglob first, compinit check below needs it)
setopt extendedglob
setopt autocd              # dirs
setopt autopushd
setopt pushd_ignore_dups   # dirs, one stack entry per directory
setopt chasedots           # dirs, resolve .. physically
setopt interactive_comments # allow `# comment` on the command line (pasted runbooks)
setopt extendedhistory     # history
setopt sharehistory
setopt hist_ignore_all_dups
setopt hist_reduce_blanks  # trim superfluous blanks so near-identical entries dedupe
setopt hist_ignore_space   # prefix a command with space to keep it out of history
setopt checkjobs           # jobs
setopt nobeep              # no beeping
setopt complete_in_word    # complete
setopt short_loops         # enable short loops eg: for i in 1 2 3; echo $i

if (( human )); then
    setopt globdots        # glob: match dotfiles (not for agents, `rm *` would hit .git)
    setopt correct correctall  # correct commands and arguments
    setopt printexitvalue  # print exit code if non-zero
    setopt zle emacs       # line editor, fails without a tty
    setopt no_flow_control # tty: free ^S/^Q (^S = forward search next to ^R)
    setopt hist_verify     # history: show !! / !$ expansion for editing instead of running it
fi

##
# autoload
autoload -Uz vcs_info
autoload -U colors
colors
autoload -U compinit
# rebuild the completion dump once a day, otherwise trust it
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
    compinit -i
else
    compinit -C -i
fi
autoload edit-command-line
zle -N edit-command-line
autoload zmv
autoload -U select-word-style
select-word-style normal

##
# word delimiters
export WORDCHARS='*?_[]~=&;!#$%^(){}<>'

##
# export
export EDITOR="vim"

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

# machine-local overrides, not in dotfiles (site-specific names etc.)
kube_prefix_strip=()           # prefixes dropped from the prompt's kube context
kube_prod_pattern='*prod*'     # contexts matching this get $kube_prod_style
kube_color='%F{109}'           # prompt color of the kube context name
kube_prod_style='%F{203}%U'    # name of a prod context: soft red, underlined
kube_qa_pattern='*qa*'         # qa contexts get $kube_qa_style (prod wins over qa)
kube_qa_style='%F{214}%U'      # name of a qa context: amber, underlined
[ -f ~/.zsh_local ] && . ~/.zsh_local

[ -f ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh ] && . ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

##
# term dependent options
# hooks (add-zsh-hook, so plugins can add theirs too; run in registration order)
autoload -Uz add-zsh-hook

_title_precmd() { printf '\033]0;%s\007' "$PWD" }
_title_preexec() { print -Pn "\e]0;${2//\%/%%}\a" }
_reset_color_preexec() { echo -n ${reset_color} }

add-zsh-hook precmd pprecmd
case $TERM in
    xterm*|screen*)
	[[ $TERM == screen* ]] && export TERM=screen-256color
	add-zsh-hook precmd _title_precmd
	add-zsh-hook preexec _title_preexec
	;;
esac
add-zsh-hook preexec _reset_color_preexec

##
# git info for prompt, shown as [branch ✗ ✔ ❤]
#   ✗ (yellow)  unstaged changes (modified/deleted, not yet `git add`ed)
#   ✔ (green)   staged changes (in the index, ready to commit)
#   ❤ (red)     untracked files (new files git does not know about yet)
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' unstagedstr " %F{3}✗"
zstyle ':vcs_info:*' stagedstr " %F{2}✔"
zstyle ':vcs_info:*' enable git

##
# prompt
# The git segment is the only slow part (vcs_info + untracked check), so it is
# computed in the background and filled into RPROMPT when ready; everything else
# is drawn instantly. Nothing runs outside a git work tree.

# prints the git segment, runs in a background subshell
_git_segment () {
    if [[ -z $(git ls-files --other --exclude-standard 2> /dev/null) ]] {
	    zstyle ':vcs_info:*' formats " %F{12}[%b%c%u%F{12}]"
    } else {
	    zstyle ':vcs_info:*' formats " %F{12}[%b%c%u %F{9}❤%F{12}]"
    }
    vcs_info
    print -rn -- "$vcs_info_msg_0_"
}

_in_git_tree () {
    local d=$PWD
    while [[ $d != / ]]; do
        [[ -e $d/.git ]] && return 0
        d=${d:h}
    done
    return 1
}

# (re)build RPROMPT from the parts computed by pprecmd and the async git segment
_build_rprompt () {
    RPROMPT="%{$fg[black]%}%m $_rp_kube$_rp_terraform$_rp_git ${_rp_face}%{$fg_bold[white]%}"
}

# kubectl context, read from the kubeconfig file (no kubectl fork), shown as
# "⎈ name". The glyph tells the privilege: red = admin, green = readonly,
# otherwise like the name. The name is $kube_color, or $kube_prod_style for prod.
_kube_segment () {
    _rp_kube=""
    # like kubectl: KUBECONFIG may list several files, the first one that sets a context wins
    local -a files=( ${(s.:.)KUBECONFIG} )
    (( $#files )) || files=( $HOME/.kube/config )
    local f ctx=""
    for f in $files; do
        [[ -r $f ]] || continue
        ctx=${(M)${(f)"$(<$f)"}:#current-context:*}
        ctx=${${ctx#current-context:}//[\"\' ]/}
        [[ -n $ctx ]] && break
    done
    [[ -n $ctx ]] || return

    ctx=${ctx##*/}                          # arn:aws:eks:...:cluster/name -> name
    ctx=${ctx//\%/%%}
    local p g=$kube_color c=$kube_color
    local -a tok
    for p in $kube_prefix_strip; do ctx=${ctx#$p}; done
    tok=( ${(s:-:)ctx} )
    (( ${tok[(Ie)admin]} ))    && g='%F{red}'      # glyph = privilege
    (( ${tok[(Ie)readonly]} )) && g='%F{green}'
    # name = environment
    if [[ $ctx == ${~kube_prod_pattern} ]]; then
        c=$kube_prod_style
    elif [[ $ctx == ${~kube_qa_pattern} ]]; then
        c=$kube_qa_style
    fi
    _rp_kube="${g}⎈ ${c}${ctx}%u%f%k%b "
}

# zle -F handler: the background job has produced (or closed) its output
_git_segment_done () {
    local fd=$1 seg=""
    zle -F $fd
    IFS= read -r -d '' -u $fd seg
    exec {fd}<&-
    [[ $fd == ${_rp_git_fd-} ]] || return    # stale result of an older prompt
    unset _rp_git_fd
    _rp_git=$seg
    _build_rprompt
    zle && zle reset-prompt
}

pprecmd () {
    # freeze the exit status now, %? is not reliable after an async redraw
    local last=$?
    if (( last == 0 )); then
        _rp_face="%{$fg_bold[green]%}:)"
    else
        _rp_face="%{$fg_bold[red]%};("
    fi

    # drop a still-running job of the previous prompt
    # (exec {var} makes it an integer, so test with ${+var} and unset, never "")
    if (( ${+_rp_git_fd} )); then
        zle -F $_rp_git_fd 2>/dev/null
        exec {_rp_git_fd}<&- 2>/dev/null
        unset _rp_git_fd
    fi
    _rp_git=""
    if _in_git_tree; then
        exec {_rp_git_fd}< <(_git_segment)
        zle -F $_rp_git_fd _git_segment_done
    fi

    # get terraform workspace name for prompt
    terraform_ws=""
    # get google cloud project id
    terraform_gcp=""
    if [ -f "${PWD}/main.tf" ]; then
      if [ -f "${PWD}/.terraform/environment" ]; then
        terraform_ws="%F{3}γ $(<"${PWD}/.terraform/environment")"
      elif [ -d "${PWD}/.terraform" ]; then
	terraform_ws="%F{3}γ %F{7}default"
      else
        terraform_ws="%F{3}γ %F{1}no init"
      fi

      if [[ -f $GOOGLE_APPLICATION_CREDENTIALS ]] \
       && [[ -n $(find "${PWD}/.terraform/providers" -name 'terraform-provider-google*' -print -quit 2>/dev/null) ]]; then
        local project=$(command jq -r .project_id "$GOOGLE_APPLICATION_CREDENTIALS" 2>/dev/null)
        [[ -z $project || $project == null ]] && project=${${GOOGLE_APPLICATION_CREDENTIALS:t}%.json}

        terraform_gcp=" %F{4}☁ %F{11}$project "
      fi
    fi

    _rp_terraform="$terraform_ws$terraform_gcp"
    _kube_segment
    _build_rprompt
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
                    "%B--%F{green} %d %F{white}--%f%b"
zstyle ':completion:*:warnings' format\
                    "%B--%F{red} no match for: %d %F{white}--%f%b"
zstyle ':completion:*:corrections' format\
                    "%B--%F{yellow} %d %F{white}-- (errors %e)%f%b"
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
# cache results of slow completion sources (hosts, packages, ...)
[ -d ~/.cache/zsh/compcache ] || mkdir -p ~/.cache/zsh/compcache
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path ~/.cache/zsh/compcache

##
# kill completion (BSD/macOS ps, no --forest)
zstyle ':completion:*:*:kill:*:processes' list-colors\
                    "=(#b) #([0-9]#)*=0=01;31"
zstyle ':completion:*:*:kill:*:processes' command\
                    "ps -u $USER -o pid,user,command"
zstyle ':completion:*:processes-names' command "ps -u $USER -o comm="

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
# up/down walk only this session's history; everything else (fzf ^R, new shells)
# still sees the shared history thanks to share_history
if (( human )); then
    up-line-or-local-history () {
        zle set-local-history 1
        zle up-line-or-history
        zle set-local-history 0
    }
    down-line-or-local-history () {
        zle set-local-history 1
        zle down-line-or-history
        zle set-local-history 0
    }
    zle -N up-line-or-local-history
    zle -N down-line-or-local-history
    bindkey '^[[A' up-line-or-local-history
    bindkey '^[OA' up-line-or-local-history
    bindkey '^P'   up-line-or-local-history
    bindkey '^[[B' down-line-or-local-history
    bindkey '^[OB' down-line-or-local-history
fi

##
# fzf: ^R fuzzy history, ^T file picker, Alt-C cd (after bindkey -e, human shells only)
# `fzf --zsh` output is cached, it costs a subprocess otherwise
if (( human && $+commands[fzf] )); then
    fzf_init="$HOME/.cache/zsh/fzf.zsh"
    [[ -s $fzf_init && $fzf_init -nt $commands[fzf] ]] || fzf --zsh > $fzf_init 2>/dev/null
    [[ -s $fzf_init ]] && . $fzf_init
fi

##
# history
HISTSIZE=50000
HISTFILE="$HOME/.zsh_history"
SAVEHIST=$HISTSIZE

##
# terraform custom options
export TF_PLUGIN_CACHE_DIR="$HOME/.terraform.d/plugin-cache"

##
# vscode custom settings
if [[ $TERM_PROGRAM == "vscode" ]]; then
    unsetopt correct correctall
fi
