#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
DOTFILES_DIR="$SCRIPT_DIR/dotfiles"

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

echo "Installing bash dotfiles..."

link_file "$DOTFILES_DIR/bash_aliases"   "$HOME/.bash_aliases"
#link_file "$DOTFILES_DIR/bash_functions" "$HOME/.bash_functions"
#link_file "$DOTFILES_DIR/bash_exports"   "$HOME/.bash_exports"

echo "Done."
