#! /usr/bin/env bash

# creating.generated-install dir so it will only link
# once the install script has been called
# This will also allow for different install scripts
rm -rf .generated-install
mkdir .generated-install

DOTFILES=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)

echo 'linking nvim'
cp -r $DOTFILES/nvim $DOTFILES/.generated-install/nvim 
rm -rf $HOME/.config/nvim
ln -s $DOTFILES/.generated-install/nvim $HOME/.config/nvim

echo 'linking kitty'
cp -r $DOTFILES/kitty $DOTFILES/.generated-install/kitty 
rm -rf $HOME/.config/kitty
ln -s $DOTFILES/.generated-install/kitty $HOME/.config/kitty

echo 'linking tmux'
cp -r $DOTFILES/tmux $DOTFILES/.generated-install/tmux 
rm -rf $HOME/.config/tmux
ln -s $DOTFILES/.generated-install/tmux $HOME/.config/tmux

echo 'linking bash files'
cp -r $DOTFILES/bash $DOTFILES/.generated-install/bash 
rm -rf $HOME/.config/bash
rm -rf $HOME/.bashrc
ln -s $DOTFILES/.generated-install/bash $HOME/.config/bash
ln -s $DOTFILES/.generated-install/bash/.bashrc $HOME/.bashrc

echo 'Done linking all files!'
