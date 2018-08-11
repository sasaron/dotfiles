export HISTTIMEFORMAT='%Y-%m-%dT%T%z '
export HISTFILESIZE=1000
export HISTCONTROL=erasedups
export HISTIGNORE=?:??:exit:history:ls*:pwd:cd*
if [ -d "$HOME/bin" ]; then
    PATH=$PATH:$HOME/bin
fi

function groot() {
  if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    cd `pwd`/`git rev-parse --show-cdup`
  fi
}

function vif() {
    if [ ! -e "$1" ]; then
        return 1
    fi
    local file=`find $1 -type f | perl -nle 'print if -f && -T' | peco`
    if [ -n "$file" ]; then
        echo "vim $file" >> ~/.bash_history
        vim $file
    fi
}

function gbranch() {
    # 変更を退避
    local unstaged_commit=`git status | grep 'Changes not staged for commit'`
    if [ -n "$unstaged_commit" ];then
        echo "saved unstaged commit"
        git stash save
    fi

    git checkout `git branch | peco | sed -e "s/\* //g" | awk "{print \$1}"`

    # 変更を戻す
    local branch=`git rev-parse --abbrev-ref HEAD`
    local saved_stash=`git stash list | grep $branch`
    if [ -n "$saved_stash" ];then
        echo "restore stash"
        git stash pop
    fi
}

function hiscopy() {
    history | perl -anle 'print "@F[ 1..$#F ]"' | peco | perl -ne 's/\n$//g;print' | pbcopy
}

export PS1="[\[\e[34m\]\u\[\e[m\]@\[\e[33m\]\H\[\e[m\]][\[\e[32m\]\w\[\e[m\]][\[\e[35m\]\`parse_git_branch\`\[\e[m\]]\n\$ "

alias ll="ls -laG"
alias dirs="dirs -v"
alias g='cd $(ghq root)/$(ghq list | peco)'
alias mysql="mysql --pager='less -S -n -i -F -X'"
#alias dockerrmALL="docker rm $(docker ps -aq)
export EDITOR=vim
