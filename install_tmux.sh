#!/usr/bin/env bash

# Install tmux if not already installed
if ! command -v tmux &> /dev/null; then
  sudo apt install -y tmux
else
  echo "tmux is already installed."
fi

# Install TPM (Tmux Plugin Manager) if not present
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  git clone https://github.com/tmux-plugins/tpm "$HOME/.config/tmux/plugins/tpm"
else
  echo "TPM is already installed."
fi

# Symlink tmux config from dotfiles
ln -sf ~/dev/dotfiles/dotfiles/tmux.conf ~/.config/tmux/tmux.conf

echo "tmux and TPM are set up. Config symlinked to ~/.config/tmux/tmux.conf"