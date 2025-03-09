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
create_symlink "$DOTFILEDIR/.zshrc" "$HOME/.zshrc"
create_symlink "$DOTFILEDIR/vimrc" "$HOME/.vimrc"

# Create symlink for bin directory
if [ -d "$DOTFILEDIR/bin" ]; then
    create_symlink "$DOTFILEDIR/bin" "$HOME/bin"
fi

# Create ~/.config directory if it doesn't exist
mkdir -p "$HOME/.config"

# Create symlinks for configuration directories in ~/.config
for config_dir in alacritty starship; do
    if [ -d "$DOTFILEDIR/home/$config_dir" ]; then
        create_symlink "$DOTFILEDIR/home/$config_dir" "$HOME/.config/$config_dir"
    fi
done

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

# Install VSCode extensions
if command -v code &> /dev/null; then
    echo "Installing VSCode extensions..."
    "$DOTFILEDIR/bin/install-vscode-extensions.sh"
fi

# Set up screenshot directory
echo "Setting up screenshot directory..."
mkdir -p "$HOME/Desktop/capturefile"
defaults write com.apple.screencapture location "$HOME/Desktop/capturefile"
killall SystemUIServer

echo ""
echo "Installation complete!"
echo "You may need to restart your terminal for all changes to take effect."
