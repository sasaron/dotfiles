#!/bin/bash
DOTFILEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ "$(uname)" != 'Darwin' ]; then
    echo "This script is only for macOS"
    exit 1
fi

# Install Xcode Command Line Tools
echo "Installing Xcode Command Line Tools..."
xcode-select --install || true

# Install Homebrew if not already installed
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for the current session
    if [[ $(uname -m) == "arm64" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        eval "$(/usr/local/bin/brew shellenv)"
    fi
else
    echo "Homebrew is already installed."
fi

# Install fzf
if ! command -v fzf &> /dev/null; then
    echo "Installing fzf..."
    brew install fzf
    "$(brew --prefix)/opt/fzf/install" --all --no-bash --no-fish
else
    echo "fzf is already installed."
fi

# Install packages from Brewfile
if [ -f "$DOTFILEDIR/mac/Brewfile" ]; then
    echo "Installing packages from Brewfile..."
    brew bundle --file="$DOTFILEDIR/mac/Brewfile"
else
    echo "Brewfile not found at $DOTFILEDIR/mac/Brewfile"
fi

# Function to create a symbolic link with backup
create_symlink() {
    local source="$1"
    local target="$2"
    
    # Check if the source file exists
    if [ ! -f "$source" ] && [ ! -d "$source" ]; then
        echo "Source does not exist: $source"
        return 1
    fi
    
    # Check if the target already exists
    if [ -e "$target" ]; then
        # If it's already a symlink to our file, do nothing
        if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
            echo "Symlink already exists: $target -> $source"
            return 0
        fi
        
        # Backup the existing file/directory
        local backup="${target}.backup.$(date +%Y%m%d%H%M%S)"
        echo "Backing up $target to $backup"
        mv "$target" "$backup"
    fi
    
    # Create the symlink
    echo "Creating symlink: $target -> $source"
    ln -s "$source" "$target"
}

# Create symlinks for dotfiles
echo "Creating symlinks for configuration files..."
create_symlink "$DOTFILEDIR/config/.zshrc" "$HOME/.zshrc"
create_symlink "$DOTFILEDIR/config/.vimrc" "$HOME/.vimrc"

# Create bin directory if it doesn't exist
mkdir -p "$HOME/bin"

# Create symlinks for scripts in bin directory, excluding Go tools
if [ -d "$DOTFILEDIR/bin" ]; then
    for script in "$DOTFILEDIR/bin"/*; do
        # Skip Go-related binaries
        if [[ "$(basename "$script")" =~ ^(arch-go|dlv|ginkgolinter|goimports|golangci-lint|gomodifytags|goplay|gopls|gotests|impl|revive|staticcheck|wire)$ ]]; then
            echo "Skipping Go tool: $(basename "$script")"
            continue
        fi
        
        if [ -f "$script" ] && [ -x "$script" ]; then
            create_symlink "$script" "$HOME/bin/$(basename "$script")"
        fi
    done
fi

# Create ~/.config directory if it doesn't exist
mkdir -p "$HOME/.config"

# Create symlinks for configuration directories in ~/.config
for config_dir in zellij commitlint; do
    if [ -d "$DOTFILEDIR/home/$config_dir" ]; then
        create_symlink "$DOTFILEDIR/home/$config_dir" "$HOME/.config/$config_dir"
    fi
done

# Starship is managed by chezmoi. Inspect the diff before applying on existing machines.
if command -v chezmoi >/dev/null 2>&1; then
    echo "Applying chezmoi-managed configuration..."
    chezmoi --source "$DOTFILEDIR" apply || { echo "chezmoi apply failed" >&2; exit 1; }
else
    echo "chezmoi is missing; install it and rerun setup." >&2
    exit 1
fi

# herdr は同じディレクトリに socket と session ファイルを作る。
# ディレクトリごと張るとリポジトリに入り込むので config.toml だけ張る
mkdir -p "$HOME/.config/herdr"
create_symlink "$DOTFILEDIR/home/herdr/config.toml" "$HOME/.config/herdr/config.toml"

# Create symlink for changelog.config.js
if [ -f "$DOTFILEDIR/home/changelog.config.js" ]; then
    create_symlink "$DOTFILEDIR/home/changelog.config.js" "$HOME/changelog.config.js"
fi

# Create .vscode directory if it doesn't exist
mkdir -p "$HOME/.vscode"

# Create symlinks for VSCode configuration files
if [ -d "$DOTFILEDIR/config/.vscode" ]; then
    # Create .vscode directory if it doesn't exist
    mkdir -p "$HOME/.vscode"
    
    # Symlink tasks.json
    if [ -f "$DOTFILEDIR/config/.vscode/tasks.json" ]; then
        create_symlink "$DOTFILEDIR/config/.vscode/tasks.json" "$HOME/.vscode/tasks.json"
    fi
    
    # Create VSCode User directory if it doesn't exist
    mkdir -p "$HOME/Library/Application Support/Code/User"
    
    # Symlink settings.json
    if [ -f "$DOTFILEDIR/config/.vscode/settings.json" ]; then
        create_symlink "$DOTFILEDIR/config/.vscode/settings.json" "$HOME/Library/Application Support/Code/User/settings.json"
    fi
    
    # Symlink keybindings.json
    if [ -f "$DOTFILEDIR/config/.vscode/keybindings.json" ]; then
        create_symlink "$DOTFILEDIR/config/.vscode/keybindings.json" "$HOME/Library/Application Support/Code/User/keybindings.json"
    fi
    
    # Symlink snippets directory
    if [ -d "$DOTFILEDIR/config/.vscode/snippets" ]; then
        create_symlink "$DOTFILEDIR/config/.vscode/snippets" "$HOME/Library/Application Support/Code/User/snippets"
    fi
fi

# Install oh-my-zsh if not already installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing oh-my-zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    
    # Install zsh-autosuggestions plugin
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    
    # Install zsh-syntax-highlighting plugin
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
fi

# Set up git configuration
if command -v ghq &> /dev/null; then
    echo "Setting up git configuration..."
    git config --global ghq.root "$HOME/src"
fi

# Set up vim
if [ ! -d "$HOME/.vim" ]; then
    echo "Setting up vim..."
    mkdir -p "$HOME/.vim"
fi

# Install vim-plug
if [ ! -f "$HOME/.vim/autoload/plug.vim" ]; then
    echo "Installing vim-plug..."
    curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
else
    echo "vim-plug is already installed."
fi

# Install VSCode extensions
if command -v code &> /dev/null; then
    echo "Installing VSCode extensions..."
    "$DOTFILEDIR/bin/install-vscode-extensions.sh"
fi

# Install global npm packages
if command -v npm &> /dev/null; then
    echo "Installing global npm packages..."
    "$DOTFILEDIR/bin/install-npm-packages.sh"
fi

# Set up screenshot directory
echo "Setting up screenshot directory..."
mkdir -p "$HOME/Desktop/capturefile"
defaults write com.apple.screencapture location "$HOME/Desktop/capturefile"
killall SystemUIServer

echo ""
echo "Installation complete!"
echo "You may need to restart your terminal for all changes to take effect."
