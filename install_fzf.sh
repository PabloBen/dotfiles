#!/usr/bin/env bash

set -euo pipefail

install_apt_packages() {
  if ! command -v apt-get >/dev/null 2>&1; then
    echo "Error: apt-get is required. This installer supports Ubuntu/Debian-family systems only." >&2
    exit 1
  fi

  if [ "${EUID:-$(id -u)}" -eq 0 ]; then
    apt-get update
    apt-get install -y "$@"
  else
    if ! command -v sudo >/dev/null 2>&1; then
      echo "Error: missing prerequisites require apt, but sudo is not available. Re-run as root or install sudo." >&2
      exit 1
    fi

    echo "Checking sudo access before installing prerequisites."
    sudo -v
    sudo apt-get update
    sudo apt-get install -y "$@"
  fi
}

if ! command -v git >/dev/null 2>&1; then
  echo "Installing prerequisite with apt: git"
  install_apt_packages git
else
  echo "Prerequisite already installed: git"
fi

fzf_dir="$HOME/.fzf"

if [ -d "$fzf_dir/.git" ]; then
  echo "fzf repository already exists at $fzf_dir; updating it."
  git -C "$fzf_dir" pull --ff-only
elif [ -e "$fzf_dir" ]; then
  echo "Error: $fzf_dir already exists but is not a git repository. Move it aside before installing fzf." >&2
  exit 1
else
  git clone --depth 1 https://github.com/junegunn/fzf.git "$fzf_dir"
fi

echo "Running the upstream fzf installer. It may prompt and may modify shell configuration files."
bash "$fzf_dir/install"
