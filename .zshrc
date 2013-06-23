autoload -U compinit
compinit

autoload colors
colors

export LANG=ja_JP.UTF-8
export PATH=/usr/local/bin:/usr/local/sbin:$PATH

function rprompt-git-current-branch {
    local name st color

    if [[ "$PWD" =~ '/\.git(/.*)?$' ]]; then
        return
    fi
    name=$(git symbolic-ref --short HEAD 2> /dev/null)
    if [[ -z $name ]]; then
        return
    fi
    st=`git status 2> /dev/null`
    if [[ -n `echo "$st" | grep "^nothing to"` ]]; then
        color=${fg[green]}
    elif [[ -n `echo "$st" | grep "^nothing added"` ]]; then
        color=${fg[yellow]}
    elif [[ -n `echo "$st" | grep "^# Untracked"` ]]; then
        color=${fg_bold[red]}
    else
        color=${fg[red]}
    fi

    echo "%{$color%}$name%{$reset_color%}"
}

setopt prompt_subst
PROMPT="%{${fg[magenta]}%}%n@%m ${fg[yellow]}%}%(5~,%-2~/.../%2~,%~)%{${reset_color}%} [%D{%Y-%m-%d %T}]
%(!.#.$) "
PROMPT2='[%n]> '
RPROMPT='[`rprompt-git-current-branch`]'

case "${TERM}" in
    kterm*|xterm)
	precmd(){
	    echo -ne "\033]0;${USER}@${HOST%%.*}:${PWD}\007"
	}
	;;
    dumb | emacs)
	PROMPT="%m:%~> "
	unsetopt zle
	;;
esac

HISTFILE=${HOME}/.zsh_hisrory
HISTSIZE=10000000
SAVELIST=10000000
setopt extended_history
setopt share_history

bindkey -e

autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^P" history-beginning-search-backward-end
bindkey "^N" history-beginning-search-forward-end

setopt auto_cd
setopt auto_pushd
setopt list_packed
setopt nolistbeep
setopt noautoremoveslash

autoload predict-on
predict-on

export LSCOLORS=gxfxcxdxbxegedabagacad
export LS_COLORS='di=36:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'

[[ $TERM = "eterm-color" ]] && TERM=xterm-color


zstyle ':completion:*' list-colors ''
# zstyle ':completion:*' verbose yes
# zstyle ':completion:*:descriptions' format '%B%d%b'
# zstyle ':completion:*:messages' format '%d'
# zstyle ':completion:*:warnings' format 'No matches for: %d'
# zstyle ':completion:*' group-name ''

alias javac="javac -J-Dfile.encoding=UTF8"
# alias java="java -J-Dfile.encoding=UTF8"

export LESS='-R'

bindkey "" backward-delete-char

# reload .zshrc
alias sourcez='source ~/.zshrc'

# extend cd
alias cddown='cd ~/Downloads'
alias cdtmp='cd ~/tmp'
alias cddrop='cd ~/Dropbox'
alias cdarc='cd ~/Dropbox/Archives'

function cdtop() {
    if git rev-parse --is-inside-work-tree > /dev/null 2&>1; then
        cd `git rev-parse --show-toplevel`
    fi
}

### completion of ~/git ###
function cdgit {
    cd ~/git/$1
}

function _g {
    _files -W ~/git/ && return 0;
    return 1;
}

compdef _g cdgit
### ###

# extend existed command
alias curl='noglob curl'
alias gp='grep -n --color=auto'
alias gcc='gcc -Werror -Wall'

function frep {
    find . -type f -name $1 | xargs grep $2
}

REPORTTIME=3

export PATH=$PATH:$HOME/local
export PATH=~/.cabal/bin:$PATH
export PATH=~/.rbenv/versions/2.0.0-p0/bin:~/.rbenv/bin:$PATH
eval "$(rbenv init -)"

compdef -d rake
compdef -d npm
compdef -d scp

### depend on OS ###
case ${OSTYPE} in
    darwin*)
        export LESSOPEN='| /usr/local/bin/src-hilite-lesspipe.sh %s'

        if [ $SHLVL = 1 ]; then
            tmux attach || tmux
        fi

        alias ls="ls -G -w"
        alias emacs='/usr/local/bin/emacs'

        export PATH=/usr/local/share/npm/bin:$PATH
        export PATH=/opt/gnu/:$PATH
        ;;

    linux*)
        export LESSOPEN='| /usr/bin/source-highlight-esc.sh %s'

        if [ $SHLVL = 3 ]; then
            tmux attach || tmux
        fi

        alias ls='ls --color=auto'
        alias open="xdg-open"
        alias eclipse='MALLOC_CHECK_=0 /usr/local/eclipse/eclipse'
        alias duald='xrandr --output LVDS1 --auto --output VGA1 --auto --right-of LVDS1'
        alias singled='xrandr --output VGA1 --off'

        export PATH=/usr/local/appengine-java-sdk/bin:$PATH
        ;;
esac
