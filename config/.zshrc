#!/bin/zsh

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load
ZSH_THEME="robbyrussell"

# Uncomment the following line to disable auto-setting terminal title.
# Would you like to use another custom folder than $ZSH/custom?
export LANG=ja_JP.UTF-8

# 色を使用
autoload -Uz colors
colors

# Path settings
if [ -d "$HOME/bin" ]; then
    PATH=$PATH:$HOME/bin
fi

export PATH="$HOME/bin:$PATH"
export PATH="/usr/local/sbin:$PATH"
export PATH="/usr/local/opt/python@3.8/bin:$PATH"
export PATH="/usr/local/bin:$PATH"
export PATH="/opt/homebrew/bin:$PATH"
export PATH="/opt/homebrew/opt/gnu-getopt/bin:$PATH"

# History settings
HISTFILE=~/.zsh_history
HISTSIZE=5000
SAVEHIST=5000
export HISTTIMEFORMAT='%Y-%m-%dT%T%z '
export HISTCONTROL=erasedups
export HISTIGNORE=?:??:exit:history:ls*:pwd:cd*
setopt HIST_IGNORE_ALL_DUPS

# コマンドミスを修正
setopt correct

# 補完機能を有効化
autoload -Uz compinit
compinit

# 補完の選択を楽にする
zstyle ':completion:*' menu select

# 補完候補をできるだけ詰めて表示する
setopt list_packed

# Tab連打で補完候補を順に表示
setopt auto_menu

# TAB で順に補完候補を切り替える
setopt auto_param_keys

# 補完候補一覧でファイルの種別をマーク表示
setopt list_types

# Git settings from config/.zshrc
autoload -Uz vcs_info
setopt prompt_subst
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' unstagedstr "%F{red}+"
zstyle ':vcs_info:git:*' stagedstr "%F{yellow}!"
zstyle ':vcs_info:git*+set-message:*' hooks git-untracked
zstyle ':vcs_info:*' formats "[%F{magenta}%b%c%u%f]"
zstyle ':vcs_info:*' actionformats '[%b|%a]'

+vi-git-untracked(){
    if [[ $(git rev-parse --is-inside-work-tree 2> /dev/null) == 'true' ]] && \
        git status --porcelain | grep '??' &> /dev/null ; then
        hook_com[staged]+='%F{red}+'
    fi
}

# 色の設定
export LSCOLORS=Exfxcxdxbxegedabagacad

# 補完時の色設定
export LS_COLORS='di=01;34:ln=01;35:so=01;32:ex=01;31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'

# キャッシュの利用による補完の高速化
zstyle ':completion::complete:*' use-cache true

# 補完候補に色つける
autoload -U colors ; colors ; zstyle ':completion:*' list-colors "${LS_COLORS}"

# 大文字・小文字を区別しない(大文字を入力した場合は区別する)
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# manの補完をセクション番号別に表示させる
zstyle ':completion:*:manuals' separate-sections true

# Preferred editor for local and remote sessions
export EDITOR='vim'

# Golang settings
export GOPATH="$HOME"
export GOBIN="$GOPATH/bin"
export PATH="$GOPATH/bin:$PATH"

# Initialize starship prompt
eval "$(starship init zsh)"

# Modern command replacements
if command -v eza &> /dev/null; then
  alias ls="eza"
  alias ll="eza -la"
  alias lt="eza -T"
  alias la="eza -a"
else
  alias ll="ls -laG"
fi

if command -v bat &> /dev/null; then
  alias cat="bat"
fi

if command -v btm &> /dev/null; then
  alias top="btm"
fi

if command -v dust &> /dev/null; then
  alias du="dust"
fi

if command -v duf &> /dev/null; then
  alias df="duf"
fi

# Other aliases
alias dirs="dirs -v"
alias g='local repo=$(ghq list | fzf --preview "tree -C $(ghq root)/{} | head -100") && cd "$(ghq root)/$repo"'
# fzf-based interactive history search
alias h='BUFFER=$(history -n 1 | sort -r | uniq | fzf); CURSOR=$#BUFFER; zle reset-prompt'
zle -N h
bindkey '^H' h
alias mysql="mysql --pager='less -S -n -i -F -X'"
alias ssm="aws ssm start-session --target"

# Functions
function hiscopy() {
    history | perl -anle 'print "@F[ 1..$#F ]"' | fzf | perl -ne 's/\n$//g;print' | pbcopy
}

# Taskwarrior aliases
alias t="task"
alias ta="task add"
alias tl="task list"
alias tc="task completed"
alias tp="task projects"
alias ts="task sync"
alias td="task done"
alias tm="task modify"
alias tstart="task start"
alias tstop="task stop"

alias claude="/opt/homebrew/bin/claude"

# zplug configuration
if [[ ! -d ~/.zplug ]]; then
  git clone https://github.com/zplug/zplug ~/.zplug
fi

source ~/.zplug/init.zsh

# Disable zplug's automatic compinit to manually control its execution
zstyle ':zplug:config:compinit' run no

# Add Homebrew's site-functions to fpath for completions like AWS CLI
if command -v brew &> /dev/null; then
  HOMEBREW_PREFIX=$(brew --prefix)
  if [ -d "$HOMEBREW_PREFIX/share/zsh/site-functions" ]; then
    fpath=($HOMEBREW_PREFIX/share/zsh/site-functions $fpath)
  fi
fi

# プラグインList
zplug "zsh-users/zsh-completions" 
zplug "zsh-users/zsh-autosuggestions"
zplug "zsh-users/zsh-syntax-highlighting", defer:2
zplug "b4b4r07/enhancd", use:init.sh
zplug "zsh-users/zsh-history-substring-search"
zplug "zsh-users/zsh-history-substring-search", use:history-substring-search.zsh

# インストールしていないプラグインをインストール
if ! zplug check --verbose; then
  printf "Install? [y/N]: "
  if read -q; then
    echo; zplug install
  fi
fi

# コマンドをリンクして、PATH に追加し、プラグインは読み込む
zplug load --verbose

# Manually initialize the completion system after all plugins are loaded
autoload -Uz compinit && compinit

# Added by Windsurf
export PATH="/Users/sasakiry/.codeium/windsurf/bin:$PATH"
