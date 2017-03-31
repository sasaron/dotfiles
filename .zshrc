typeset -ga precmd_functions
typeset -ga preexec_functions
if [[ $ZSH_VERSION == (<5->|4.<4->|4.3.<10->)* ]]; then
  source ~/.zsh/term.zshrc
fi
