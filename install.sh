#!/bin/bash

# Dotfiles Installation Script
#
# This script performs the following:
# 1. Creates symbolic links for configuration files
# 2. Installs Homebrew and essential packages
# 3. Sets up development environment tools
# 4. Configures shell plugins and themes
#
# Usage: ./install.sh
#
# Note: This script is idempotent and can be run multiple times safely

set -e # Exit on any error

DOTFILES_DIR="$HOME/.dotfiles"

# Function to create symbolic link with backup
create_symlink() {
  local source="$1"
  local target="$2"

  if [ -f "$target" ] && [ ! -L "$target" ]; then
    echo "Backing up existing $target to ${target}.backup"
    mv "$target" "${target}.backup"
  fi

  ln -sf "$source" "$target"
  echo "Created symlink: $target -> $source"
}

# Create symbolic links
create_symlink "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
create_symlink "$DOTFILES_DIR/zsh/.p10k.zsh" "$HOME/.p10k.zsh"
create_symlink "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"
create_symlink "$DOTFILES_DIR/git/.gitignore" "$HOME/.gitignore"

# Install Homebrew if not installed
if ! command -v brew &>/dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Ensure Homebrew is in the PATH
if [[ -d "/opt/homebrew" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Install Homebrew packages from Brewfile
if [ -f "$DOTFILES_DIR/Brewfile" ]; then
  echo "Installing Homebrew packages from Brewfile..."
  brew bundle --file="$DOTFILES_DIR/Brewfile" || {
    echo "⚠️  Some Homebrew packages failed to install. Please check the output above."
    echo "You can try running 'brew bundle --file=\"$DOTFILES_DIR/Brewfile\"' manually."\ echo "Common issues:"
    echo "- Mac App Store apps require being signed into the App Store"
    echo "- Some casks may require accepting a license agreement"
  }
else
  echo "⚠️  No Brewfile found at $DOTFILES_DIR/Brewfile"
  exit 1
fi

# Install fzf key bindings and completion
"$(brew --prefix)/opt/fzf/install" --all --no-bash --no-fish

# Handle private configurations
setup_private_file() {
  local target="$1"
  local template="$2"
  local description="$3"

  if [ ! -f "$target" ]; then
    echo "No $description found. Creating from template..."
    cp "$template" "$target"
    echo "Please edit $target with your private configurations"
  else
    echo "$description already exists, preserving it."
  fi
}

setup_private_file "$HOME/.private_env.zsh" "$DOTFILES_DIR/templates/private_env.template" "private aliases file"
setup_private_file "$HOME/.gitconfig.private" "$DOTFILES_DIR/templates/gitconfig.private.template" "private git config"

# Install zinit if not already installed
if [ ! -d "${HOME}/.local/share/zinit" ]; then
  echo "Installing zinit..."
  bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"
fi

# Suppress 'Last login' message
[ ! -f "$HOME/.hushlogin" ] && touch "$HOME/.hushlogin"

# Create necessary directories
mkdir -p ~/bin ~/.config

# Setup starship configuration
if [ ! -f ~/.config/starship.toml ]; then
  cp "$DOTFILES_DIR/starship.toml" "$HOME/.config/starship.toml"
fi

# Configure git to use custom hooks directory
git config core.hooksPath .hooks
# Make all hooks executable
chmod +x .hooks/*
echo "Git hooks configured! 🎉"

echo "🎉 macOS development environment setup complete!"
echo "Please restart your terminal for all changes to take effect."
