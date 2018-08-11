#!/bin/sh
DOTFILEDIR="$HOME/src/github.com/sasaki-ryu/dotfiles.git"

if [ "$(uname)" != 'Darwin' ]; then
    exit 1;
fi

mkdir -p $DOOTFILEDIR
xcode-select --install
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew install git
git clone https://github.com/sasaki-ryu/dotfiles.git $DOTFILEDIR

if [ -d $DOTFILEDIR/mac -a -f $DOTFILEDIR/mac/Brewfile ]; then
    brew bundle --file=$DOTFILEDIR/mac/Brewfile
else
    echo "not found $DOTFILEDIR/mac/Brewfile"
fi

if [ -f $DOTFILEDIR/vimrc ]; then
    ln -s $DOTFILEDIR/vimrc $HOME/.vimrc
fi
if [ -d $DOTFILEDIR/bin ]; then
    ln -s $DOTFILEDIR/bin $HOME/bin
fi
if [ -f $DOTFILEDIR/bashrc ]; then
    ln -s $DOTFILEDIR/bashrc $HOME/.bashrc
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
