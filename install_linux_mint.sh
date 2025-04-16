#! /usr/bin/env bash

# creating temp dir so it will only link
# once the install script has been called
# This will also allow for different install scripts
rm -rf .temp
mkdir .temp

DOTFILES=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)

echo 'linking nvim'
cp -r $DOTFILES/nvim $DOTFILES/.temp/nvim 
rm -rf $HOME/.config/nvim
ln -s $DOTFILES/.temp/nvim $HOME/.config/nvim

echo 'linking kitty'
cp -r $DOTFILES/kitty $DOTFILES/.temp/kitty 
rm -rf $HOME/.config/kitty
ln -s $DOTFILES/.temp/kitty $HOME/.config/kitty

echo 'linking tmux'
cp -r $DOTFILES/tmux $DOTFILES/.temp/tmux 
rm -rf $HOME/.config/tmux
ln -s $DOTFILES/.temp/tmux $HOME/.config/tmux

echo 'Done linking all files!'
