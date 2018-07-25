#!/bin/sh
DOTFILEDIR="/src/github.com/sasaki-ryu/dotfiles.git"

if [ "$(uname)" != 'Darwin' ]; then
    exit 1;
fi

mkdir -p $HOME/$DOOTFILEDIR
xcode-select --install
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew install git
git clone https://github.com/sasaki-ryu/dotfiles.git $HOME/$DOTFILEDIR

if [ -d $HOME/$DOTFILEDIR/mac -a -f $HOME/$DOTFILEDIR/mac/Brewfile ]; then
    brew bundle --file=$HOME/$DOTFILEDIR/mac/Brewfile
else
    echo "not found $HOME/$DOTFILEDIR/mac/Brewfile"
fi

if [ -f $HOME/$DOTFILEDIR/vimrc ]; then
    ln -s $HOME/$DOTFILEDIR/vimrc $HOME/.vimrc
fi
if [ -f $HOME/$DOTFILEDIR/bashrc ]; then
    ln -s $HOME/$DOTFILEDIR/bashrc $HOME/.bashrc
fi

if [ type "ghq" > /dev/null 2>&1 ]; then
    git config --global ghq.root $HOME/src
    ghq get https://github.com/Shougo/dein.vim.git
fi

if [ ! -d $HOME/.vim ]; then
    mkdir $HOME/.vim
fi

if [ -d HOME/github.com/Shougo/dein.vim ]; then
    ln -s $HOME/github.com/Shougo/dein.vim $HOME/.vim/dein.vim
fi

mkdir $HOME/Desktop/capturefile
defaults write com.apple.screencapture location $HOME/Desktop/capturefile
killall SystemUIServer
