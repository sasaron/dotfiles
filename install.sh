#!/bin/sh
# symbolic link dotfiles
BASH_FILE="$HOME/.bashrc"
VIMRC_FILE="$HOME/.vimrc"
SCREEN_FILE="$HOME/.screenrc"
DOTFILE_DIR="$HOME/dotfile"
DOTBASH_FILE="$DOTFILE_DIR/.bashrc"
DOTVIMRC_FILE="$DOTFILE_DIR/.vimrc"
DOTSCREEN_FILE="$DOTFILE_DIR/.screenrc"

if [ -e "$BASH_FILE" ]; then
    echo "$BASH_FILE already exitsts! postscript $DOTBASH_FILE Contents"
    cat "$DOTBASH_FILE" >> "$BASH_FILE"
else
    ls -s $DOTBASH_FILE $BASH_FILE
fi

if [ -e "$VIMRC_FILE" ]; then
    echo "$VIMRC_FILE already exitsts! Back up $VIMRC_FILE"
    ln -sb $DOTVIMRC_FILE $VIMRC_FILE
else
    ln -s $DOTVIMRC_FILE $VIMRC_FILE
fi

if [ -e "$SCREEN_FILE" ]; then
    echo "$SCREEN_FILE already exitsts! Back up $SCREEN_FILE"
    ln -sb $DOTSCREEN_FILE $SCREEN_FILE
else
    ln -s $DOTSCREEN_FILE $SCREEN_FILE
fi

# setting vim
VIM_DIR="$HOME/.vim"
BUNDLE_DIR="$VIM_DIR/bundle"
NVIM_INSTALL_DIR="$BUNDLE_DIR/neobundle.vim"
if type brew; then
  : # You have git command. No Problem.
else
  echo 'Please install brew or update your path to include the brew executable!'
  exit 1
fi

if type git; then
  : # You have git command. No Problem.
else
  echo 'Please install git or update your path to include the git executable!'
  exit 1
fi

echo "$VIM_DIR"
if [ -e "$VIM_DIR" ]; then
    echo "$VIM_DIR already exists!"
    if [ -e "$BUNDLE_DIR" ]; then
        echo "$BUNDLE_DIR already exists!"
    else
        mkdir $BUNDLE_DIR
    fi
    if [ -e "NVIM_INSTALL_DIR" ]; then
        echo "already setup neobundle.vim !!!"
    else
        git clone https://github.com/Shougo/neobundle.vim "$NVIM_INSTALL_DIR"
    fi
else
    mkdir $VIM_DIR
    mkdir $BUNDLE_DIR
    git clone https://github.com/Shougo/neobundle.vim "$NVIM_INSTALL_DIR"
fi

# setting Brew bundle
BREW_FILE="$HOME/dotfile/Brewfile"
if [ -e $BREW_FILE ]; then
    cd "$DOTFILE_DIR"
    brew tap Homebrew/bundle
    cd "$HOME"
fi

# setting git repository file
ANYENV_FILE="$HOME/.anyenv"
if ![ -e "$ANYENV_FILE" ]
    git clone https://github.com/riywo/anyenv ~/.anyenv
    anyenv install plenv
    anyenv install pyenv
    anyenv install rbenv
    anyenv install phpenv
    anyenv install ndenv
    anyenv install goenv
fi
