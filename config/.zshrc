#!/bin/zsh

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
HIST_STAMPS="yyyy-mm-dd"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  git
  github
  docker
  docker-compose
  npm
  yarn
  golang
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# User configuration

# 日本語を使用
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
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"

# History settings
HISTFILE=~/.zsh_history
HISTSIZE=1000
SAVEHIST=1000
export HISTTIMEFORMAT='%Y-%m-%dT%T%z '
export HISTCONTROL=erasedups
export HISTIGNORE=?:??:exit:history:ls*:pwd:cd*

# コマンドミスを修正
setopt correct

# 補完の選択を楽にする
zstyle ':completion:*' menu select

# 補完候補をできるだけ詰めて表示する
setopt list_packed

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

# Zellij configuration
# if [[ -z "$ZELLIJ" ]]; then
#   if [[ "$ZELLIJ_AUTO_ATTACH" == "true" ]]; then
#     zellij attach -c
#   else
#     zellij
#   fi
# 
#   if [[ "$ZELLIJ_AUTO_EXIT" == "true" ]]; then
#     exit
#   fi
# fi

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
alias g='cd $(ghq root)/$(ghq list | peco)'
alias mysql="mysql --pager='less -S -n -i -F -X'"
alias ssm="aws ssm start-session --target"

# Functions
function hiscopy() {
    history | perl -anle 'print "@F[ 1..$#F ]"' | peco | perl -ne 's/\n$//g;print' | pbcopy
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

# zplug configuration
if [[ ! -d ~/.zplug ]]; then
  git clone https://github.com/zplug/zplug ~/.zplug
fi

source ~/.zplug/init.zsh

# プラグインList
zplug "zsh-users/zsh-completions"
zplug "zsh-users/zsh-autosuggestions"
zplug "zsh-users/zsh-syntax-highlighting", defer:2
zplug "b4b4r07/enhancd", use:init.sh

# インストールしていないプラグインをインストール
if ! zplug check --verbose; then
  printf "Install? [y/N]: "
  if read -q; then
    echo; zplug install
  fi
fi

# コマンドをリンクして、PATH に追加し、プラグインは読み込む
zplug load --verbose
