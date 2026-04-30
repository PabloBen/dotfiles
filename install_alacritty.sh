#!/usr/bin/env bash

set -euo pipefail

ALACRITTY_REPO_URL="https://github.com/alacritty/alacritty.git"
THEMES_REPO_URL="https://github.com/alacritty/alacritty-theme.git"

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$script_dir"
source_toml="$repo_root/dotfiles/alacritty.toml"
source_yaml="$repo_root/dotfiles/alacritty.yml"
temp_dir=""

sudo_cmd=()
if [ "${EUID:-$(id -u)}" -ne 0 ]; then
  if ! command -v sudo >/dev/null 2>&1; then
    echo "Error: sudo is required for system package and binary installation. Re-run as root or install sudo." >&2
    exit 1
  fi
  sudo_cmd=(sudo)
fi

confirm() {
  local prompt="$1"
  local reply

  read -r -p "$prompt [y/N] " reply
  case "$reply" in
    [yY]|[yY][eE][sS]) return 0 ;;
    *) return 1 ;;
  esac
}

require_ubuntu() {
  if ! command -v apt-get >/dev/null 2>&1; then
    echo "Error: apt-get is required. This installer supports Ubuntu only." >&2
    exit 1
  fi

  if [ -r /etc/os-release ]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    if [ "${ID:-}" != "ubuntu" ]; then
      echo "Error: this installer supports Ubuntu only; detected ID='${ID:-unknown}'." >&2
      exit 1
    fi
  else
    echo "Error: /etc/os-release is missing; cannot confirm this is Ubuntu." >&2
    exit 1
  fi
}

install_apt_dependencies() {
  local packages=(
    ca-certificates
    cmake
    curl
    desktop-file-utils
    g++
    git
    gzip
    libfontconfig1-dev
    libfreetype6-dev
    libxcb-xfixes0-dev
    libxkbcommon-dev
    pkg-config
    python3
    scdoc
  )

  echo "Installing Ubuntu build dependencies with apt: ${packages[*]}"
  "${sudo_cmd[@]}" apt-get update
  "${sudo_cmd[@]}" apt-get install -y "${packages[@]}"
}

refresh_sudo() {
  if [ "${#sudo_cmd[@]}" -gt 0 ]; then
    "${sudo_cmd[@]}" -v
  fi
}

ensure_rust() {
  if command -v cargo >/dev/null 2>&1; then
    echo "Rust/Cargo already available: $(command -v cargo)"
    return
  fi

  if [ -r "$HOME/.cargo/env" ]; then
    # shellcheck disable=SC1091
    . "$HOME/.cargo/env"
  fi

  if command -v cargo >/dev/null 2>&1; then
    echo "Rust/Cargo available after loading $HOME/.cargo/env: $(command -v cargo)"
    return
  fi

  if ! confirm "Rust/Cargo is missing. Install rustup for the current user from https://sh.rustup.rs?"; then
    echo "Error: Rust/Cargo is required to build Alacritty." >&2
    exit 1
  fi

  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  # shellcheck disable=SC1091
  . "$HOME/.cargo/env"
}

install_built_alacritty() {
  local build_dir="$1"

  echo "Installing Alacritty binary, desktop entry, icon, and man pages."
  "${sudo_cmd[@]}" install -Dm755 "$build_dir/target/release/alacritty" /usr/local/bin/alacritty
  "${sudo_cmd[@]}" install -Dm644 "$build_dir/extra/logo/alacritty-term.svg" /usr/share/pixmaps/Alacritty.svg
  "${sudo_cmd[@]}" desktop-file-install "$build_dir/extra/linux/Alacritty.desktop"
  "${sudo_cmd[@]}" update-desktop-database

  "${sudo_cmd[@]}" mkdir -p /usr/local/share/man/man1
  "${sudo_cmd[@]}" mkdir -p /usr/local/share/man/man5
  "${sudo_cmd[@]}" mkdir -p /usr/local/share/man/man7
  scdoc < "$build_dir/extra/man/alacritty.1.scd" | gzip -c | "${sudo_cmd[@]}" tee /usr/local/share/man/man1/alacritty.1.gz >/dev/null
  scdoc < "$build_dir/extra/man/alacritty-msg.1.scd" | gzip -c | "${sudo_cmd[@]}" tee /usr/local/share/man/man1/alacritty-msg.1.gz >/dev/null
  scdoc < "$build_dir/extra/man/alacritty.5.scd" | gzip -c | "${sudo_cmd[@]}" tee /usr/local/share/man/man5/alacritty.5.gz >/dev/null
  scdoc < "$build_dir/extra/man/alacritty-bindings.5.scd" | gzip -c | "${sudo_cmd[@]}" tee /usr/local/share/man/man5/alacritty-bindings.5.gz >/dev/null
  scdoc < "$build_dir/extra/man/alacritty-escapes.7.scd" | gzip -c | "${sudo_cmd[@]}" tee /usr/local/share/man/man7/alacritty-escapes.7.gz >/dev/null
}

install_shell_completion() {
  local build_dir="$1"
  local completion_dir="$HOME/.bash_completion"
  local completion_file="$completion_dir/alacritty"
  local source_line="source ~/.bash_completion/alacritty"

  mkdir -p "$completion_dir"
  cp "$build_dir/extra/completions/alacritty.bash" "$completion_file"

  touch "$HOME/.bashrc"
  if grep -Fxq "$source_line" "$HOME/.bashrc"; then
    echo "Bash completion source line already present in $HOME/.bashrc"
  else
    printf '\n%s\n' "$source_line" >> "$HOME/.bashrc"
    echo "Added Bash completion source line to $HOME/.bashrc"
  fi
}

install_themes() {
  local themes_dir="$HOME/.config/alacritty/themes"

  mkdir -p "$(dirname "$themes_dir")"
  if [ -d "$themes_dir/.git" ]; then
    echo "Updating existing Alacritty themes checkout at $themes_dir"
    if ! git -C "$themes_dir" pull --ff-only; then
      echo "Warning: could not fast-forward existing themes checkout; leaving it unchanged." >&2
    fi
  elif [ -e "$themes_dir" ]; then
    echo "Warning: $themes_dir already exists and is not a git checkout; skipping theme clone." >&2
  else
    git clone "$THEMES_REPO_URL" "$themes_dir"
  fi
}

install_repo_config() {
  local config_dir="$HOME/.config/alacritty"
  local target_toml="$config_dir/alacritty.toml"
  local backup_path

  if [ ! -f "$source_toml" ]; then
    echo "Error: expected TOML config not found: $source_toml" >&2
    exit 1
  fi

  if [ ! -f "$source_yaml" ]; then
    echo "Warning: expected YAML config not found: $source_yaml" >&2
  else
    echo "Keeping YAML config in repository: $source_yaml"
  fi

  mkdir -p "$config_dir"

  if [ -L "$target_toml" ] && [ "$(readlink "$target_toml")" = "$source_toml" ]; then
    echo "Alacritty TOML config already links to repository config: $target_toml"
    return
  fi

  if [ -e "$target_toml" ] || [ -L "$target_toml" ]; then
    backup_path="$target_toml.backup.$(date +%Y%m%d%H%M%S)"
    mv "$target_toml" "$backup_path"
    echo "Backed up existing Alacritty TOML config to: $backup_path"
  fi

  ln -s "$source_toml" "$target_toml"
  echo "Linked Alacritty TOML config: $target_toml -> $source_toml"
}

configure_terminal_alternative() {
  if ! confirm "Register and set /usr/local/bin/alacritty as x-terminal-emulator with update-alternatives?"; then
    echo "Skipping x-terminal-emulator update-alternatives configuration."
    return
  fi

  "${sudo_cmd[@]}" update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/local/bin/alacritty 1
  "${sudo_cmd[@]}" update-alternatives --set x-terminal-emulator /usr/local/bin/alacritty
}

main() {
  echo "Alacritty source installer for Ubuntu."
  echo "Repository root detected as: $repo_root"
  echo "This will install apt packages, build Alacritty from upstream source, install system files, and link repo config."

  require_ubuntu

  if ! confirm "Continue with Alacritty installation from source?"; then
    echo "Cancelled."
    exit 0
  fi

  refresh_sudo
  install_apt_dependencies
  ensure_rust

  temp_dir="$(mktemp -d)"
  trap 'rm -rf -- "$temp_dir"' EXIT

  echo "Cloning Alacritty source into temporary directory: $temp_dir"
  git clone --depth 1 "$ALACRITTY_REPO_URL" "$temp_dir/alacritty"

  echo "Building Alacritty release binary."
  cargo build --release --manifest-path "$temp_dir/alacritty/Cargo.toml"

  install_built_alacritty "$temp_dir/alacritty"
  install_shell_completion "$temp_dir/alacritty"
  install_themes
  install_repo_config
  configure_terminal_alternative

  echo "Alacritty installation finished."
}

main "$@"
