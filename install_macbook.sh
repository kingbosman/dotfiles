#!/usr/bin/env zsh

# Creating .generated-install dir so it will only link
# once the install script has been called
# This will also allow for different install scripts
rm -rf .generated-install
mkdir .generated-install

# Get absolute path to the directory this script is in
DOTFILES="$(cd "$(dirname "$0")" && pwd)"

echo 'linking nvim'
cp -r "$DOTFILES/nvim" "$DOTFILES/.generated-install/nvim"
rm -rf "$HOME/.config/nvim"
ln -s "$DOTFILES/.generated-install/nvim" "$HOME/.config/nvim"

echo 'linking kitty'
cp -r "$DOTFILES/kitty" "$DOTFILES/.generated-install/kitty"
# Overwrite config for macbook settings
cp -fr "$DOTFILES/kitty/kitty_macbook.conf" "$DOTFILES/.generated-install/kitty/kitty.conf"
rm -rf "$HOME/.config/kitty"
ln -s "$DOTFILES/.generated-install/kitty" "$HOME/.config/kitty"

echo 'linking tmux'
cp -r "$DOTFILES/tmux" "$DOTFILES/.generated-install/tmux"
rm -rf "$HOME/.config/tmux"
ln -s "$DOTFILES/.generated-install/tmux" "$HOME/.config/tmux"

echo 'linking zshrc files'
cp -r "$DOTFILES/bash" "$DOTFILES/.generated-install/bash"
rm -rf "$HOME/.config/bash"
rm -rf "$HOME/.zshrc"
ln -s "$DOTFILES/.generated-install/bash" "$HOME/.config/bash"
ln -s "$DOTFILES/.generated-install/bash/.zshrc" "$HOME/.zshrc"

echo 'Done linking all files!'
