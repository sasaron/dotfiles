export HISTTIMEFORMAT='%Y-%m-%dT%T%z '
export HISTFILESIZE=1000
export HISTCONTROL=erasedups
export HISTIGNORE=?:??:exit:history:ls*:pwd:cd*

# get current branch in git repo
function parse_git_branch() {
BRANCH=`git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`
    if [ ! "${BRANCH}" == "" ]
    then
        STAT=`parse_git_dirty`
        echo "${BRANCH}${STAT}"
    else
        echo ""
    fi
}

# get current status of git repo
function parse_git_dirty {
    status=`git status 2>&1 | tee`
    dirty=`echo -n "${status}" 2> /dev/null | grep "modified:" &> /dev/null; echo "$?"`
    untracked=`echo -n "${status}" 2> /dev/null | grep "Untracked files" &> /dev/null; echo "$?"`
    ahead=`echo -n "${status}" 2> /dev/null | grep "Your branch is ahead of" &> /dev/null; echo "$?"`
    newfile=`echo -n "${status}" 2> /dev/null | grep "new file:" &> /dev/null; echo "$?"`
    renamed=`echo -n "${status}" 2> /dev/null | grep "renamed:" &> /dev/null; echo "$?"`
    deleted=`echo -n "${status}" 2> /dev/null | grep "deleted:" &> /dev/null; echo "$?"`
    bits=''
    if [ "${renamed}" == "0" ]; then
        bits=">${bits}"
    fi
    if [ "${ahead}" == "0" ]; then
        bits="*${bits}"
    fi
    if [ "${newfile}" == "0" ]; then
        bits="+${bits}"
    fi
    if [ "${untracked}" == "0" ]; then
        bits="?${bits}"
    fi
    if [ "${deleted}" == "0" ]; then
        bits="x${bits}"
    fi
    if [ "${dirty}" == "0" ]; then
        bits="!${bits}"
    fi
    if [ ! "${bits}" == "" ]; then
        echo " ${bits}"
    else
        echo ""
    fi
}

function git-root() {
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

git_branch() {
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

pcap() {
    local TARGET=$1
    TARGET=`echo "$TARGET" | grep -E '(stage|production)'`
    if [ -z "$TARGET" ]; then
        echo "Usage: pcap [stage or production]"
        return 1
    fi

    VERSION=""
    if [ "$TARGET" == "production" ]; then
        git pull --tags > /dev/null 2>&1
        TAG=`git for-each-ref --sort=-taggerdate --format='%(taggerdate:short) %(tag) %(taggername) %(subject)' refs/tags | head -n 10 | peco | perl -anle 'print $F[1]'`
        if [ -z "$TAG" ]; then
            return 1
        fi
        APP=`echo $TAG | grep -o -E '(admin|batch)'`
        VERSION="-Stag=$TAG"
    elif [ "$TARGET" == "stage" ]; then
        BRANCH=`git branch | peco | sed -e "s/\* //g"`
        APP="admin"
        VERSION="-Sbranch=$BRANCH"
    fi

    CATAPP=""
    if [ -n "$APP" ]; then
        CATAPP="CATAPP=$APP"
    fi

    echo "cap $VERSION $CATAPP TARGET=$TARGET deploy"
}

hiscopy() {
    history | perl -anle 'print "@F[ 1..$#F ]"' | peco | perl -ne 's/\n$//g;print' | pbcopy
}

export PS1="[\[\e[34m\]\u\[\e[m\]@\[\e[33m\]\H\[\e[m\]][\[\e[32m\]\w\[\e[m\]][\[\e[35m\]\`parse_git_branch\`\[\e[m\]]\n\$ "

alias ls="ls -G"
alias ll="ls -laG"
alias dirs="dirs -v"
alias rm="rm -i"
alias g='cd $(ghq root)/$(ghq list | peco)'
alias mysql="mysql --pager='less -S -n -i -F -X'"
#alias dockerrmALL="docker rm $(docker ps -aq)
export EDITOR=vim
