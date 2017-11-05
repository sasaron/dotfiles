export HOMEBREW_CASK_OPTS="--appdir=/Applications"
#PS1="[[\e[36m\]\H@\[\e[33m\]\u::\[\e[31m]\w]$"
#PS1='[\u@\h \W]\$'

git_branch() {
  echo $(git branch --no-color 2>/dev/null | sed -ne "s/^\* \(.*\)$/\1/p")
}

if [ "$color_prompt" = yes ]; then
    PS1='\[\033[32m\]\h\[\033[00m\]:\[\033[01;34m\]$(git_branch)\[\033[00m\]:\w\$ '
else
    PS1='\h:$(git_branch):\w\$ '
fi
