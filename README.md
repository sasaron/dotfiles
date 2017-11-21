step1 install xcode 
xcode-select --install
step2 install brew
ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"
step3 git
brew install git
step4 git clone dotfile
git clone https://github.com/sasaki-ryu/dotfiles.git ~/
step5 install.sh
./dotfile/install.sh
