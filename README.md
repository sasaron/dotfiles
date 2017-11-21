# install xcode 
xcode-select --install
# install brew
ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"
# git
brew install git
# git clone dotfile
git clone https://github.com/sasaki-ryu/dotfiles.git ~/
# install.sh
./dotfile/install.sh
