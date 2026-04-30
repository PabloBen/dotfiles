#!/usr/bin/env bash

set -euo pipefail

font_url="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/Mononoki.zip"
font_dir="$HOME/.local/share/fonts"

is_package_installed() {
  local package="$1"
  local status

  status="$(dpkg-query -W -f='${Status}' "$package" 2>/dev/null || true)"
  [ "$status" = "install ok installed" ]
}

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

missing_prerequisites=()

if ! command -v wget >/dev/null 2>&1 && ! command -v curl >/dev/null 2>&1; then
  missing_prerequisites+=(wget)
fi

for prerequisite in unzip fontconfig; do
  if ! is_package_installed "$prerequisite"; then
    missing_prerequisites+=("$prerequisite")
  fi
done

if [ "${#missing_prerequisites[@]}" -gt 0 ]; then
  echo "Installing prerequisites with apt: ${missing_prerequisites[*]}"
  install_apt_packages "${missing_prerequisites[@]}"
else
  echo "Prerequisites already installed: downloader, unzip, fontconfig"
fi

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT
archive="$tmp_dir/Mononoki.zip"

echo "Downloading Mononoki Nerd Font to a temporary directory."
if command -v wget >/dev/null 2>&1; then
  wget -O "$archive" "$font_url"
else
  curl -fL "$font_url" -o "$archive"
fi

mkdir -p "$font_dir"
echo "Installing/updating Mononoki font files in: $font_dir"
unzip -o "$archive" -d "$font_dir" '*.[ot]tf'

if command -v fc-cache >/dev/null 2>&1; then
  echo "Refreshing fontconfig cache."
  fc-cache -f "$font_dir"
else
  echo "fontconfig cache was not refreshed because fc-cache is not available." >&2
fi
