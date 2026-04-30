#!/usr/bin/env bash

set -e

DOTFILES_DIR="$HOME/dev/dotfiles/dotfiles"

link_file () {
    local src="$1"
    local dest="$2"

    if [ -L "$dest" ]; then
        echo "✔ Symlink already exists: $dest"
    elif [ -e "$dest" ]; then
        echo "⚠ Backing up existing file: $dest -> ${dest}.bak"
        mv "$dest" "${dest}.bak"
        ln -s "$src" "$dest"
        echo "✔ Symlink created: $dest"
    else
        ln -s "$src" "$dest"
        echo "✔ Symlink created: $dest"
    fi
}

echo "Installing bash dotfiles..."

link_file "$DOTFILES_DIR/bash_aliases"   "$HOME/.bash_aliases"
#link_file "$DOTFILES_DIR/bash_functions" "$HOME/.bash_functions"
#link_file "$DOTFILES_DIR/bash_exports"   "$HOME/.bash_exports"

echo "Done."
