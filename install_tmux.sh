#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
DOTFILES_DIR="$SCRIPT_DIR/dotfiles"
TMUX_CONFIG_DIR="$HOME/.config/tmux"
TMUX_PLUGIN_DIR="$TMUX_CONFIG_DIR/plugins"
TPM_DIR="$TMUX_PLUGIN_DIR/tpm"

backup_path () {
  local dest="$1"
  local backup="${dest}.bak.$(date +%Y%m%d%H%M%S)"

  while [ -e "$backup" ] || [ -L "$backup" ]; do
    backup="${dest}.bak.$(date +%Y%m%d%H%M%S).$RANDOM"
  done

  printf '%s\n' "$backup"
}

link_file () {
  local src="$1"
  local dest="$2"
  local backup

  if [ ! -e "$src" ]; then
    echo "✘ Source does not exist: $src" >&2
    return 1
  fi

  if [ -L "$dest" ]; then
    if [ "$(readlink "$dest")" = "$src" ]; then
      echo "✔ Correct symlink already exists: $dest"
    else
      rm "$dest"
      ln -s "$src" "$dest"
      echo "✔ Symlink updated: $dest"
    fi
  elif [ -e "$dest" ]; then
    backup="$(backup_path "$dest")"
    echo "⚠ Backing up existing file: $dest -> $backup"
    mv "$dest" "$backup"
    ln -s "$src" "$dest"
    echo "✔ Symlink created: $dest"
  else
    ln -s "$src" "$dest"
    echo "✔ Symlink created: $dest"
  fi
}

mkdir -p "$TMUX_CONFIG_DIR" "$TMUX_PLUGIN_DIR"

# Install tmux if not already installed
if ! command -v tmux &> /dev/null; then
  sudo apt install -y tmux
else
  echo "tmux is already installed."
fi

# Install TPM (Tmux Plugin Manager) if not present
if [ -d "$TPM_DIR" ]; then
  echo "TPM is already installed."
else
  if [ -e "$TPM_DIR" ] || [ -L "$TPM_DIR" ]; then
    tpm_backup="$(backup_path "$TPM_DIR")"
    echo "⚠ Backing up existing TPM path: $TPM_DIR -> $tpm_backup"
    mv "$TPM_DIR" "$tpm_backup"
  fi
  git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi

# Symlink tmux config from dotfiles
link_file "$DOTFILES_DIR/tmux.conf" "$TMUX_CONFIG_DIR/tmux.conf"
link_file "$DOTFILES_DIR/tmux.conf.default" "$TMUX_CONFIG_DIR/tmux.conf.default"

echo "tmux and TPM are set up. Config symlinked to $TMUX_CONFIG_DIR/tmux.conf"
