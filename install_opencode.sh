#!/usr/bin/env bash

set -euo pipefail

DEFAULT_INSTALL_URL="https://opencode.ai/install"
INSTALL_URL="${OPENCODE_INSTALL_URL:-$DEFAULT_INSTALL_URL}"

echo "OpenCode CLI installer"
echo "This script installs only the OpenCode CLI."
echo "It does not configure providers, API keys, aliases, plugins, Docker, or project files."

if command -v opencode >/dev/null 2>&1; then
  echo "OpenCode CLI is already installed: $(command -v opencode)"
  if version_output="$(opencode --version 2>/dev/null)"; then
    echo "OpenCode CLI version: $version_output"
  else
    echo "OpenCode CLI version could not be determined."
  fi
  exit 0
fi

if [ "$INSTALL_URL" != "$DEFAULT_INSTALL_URL" ]; then
  echo "Warning: OPENCODE_INSTALL_URL is set; using non-default installer URL: $INSTALL_URL" >&2
fi

if ! command -v apt-get >/dev/null 2>&1; then
  echo "Error: apt-get is required. This installer supports Ubuntu/Debian-family systems only." >&2
  exit 1
fi

missing_prerequisites=()
for prerequisite in curl ca-certificates; do
  if ! dpkg-query -W -f='${Status}' "$prerequisite" 2>/dev/null | grep -q "install ok installed"; then
    missing_prerequisites+=("$prerequisite")
  fi
done

if [ "${#missing_prerequisites[@]}" -gt 0 ]; then
  echo "Installing prerequisites with apt: ${missing_prerequisites[*]}"
  if [ "${EUID:-$(id -u)}" -eq 0 ]; then
    apt-get update
    apt-get install -y "${missing_prerequisites[@]}"
  else
    if ! command -v sudo >/dev/null 2>&1; then
      echo "Error: missing prerequisites require apt, but sudo is not available. Re-run as root or install sudo." >&2
      exit 1
    fi

    echo "Checking sudo access before installing prerequisites."
    sudo -v
    sudo apt-get update
    sudo apt-get install -y "${missing_prerequisites[@]}"
  fi
else
  echo "Prerequisites already installed: curl ca-certificates"
fi

installer_file="$(mktemp)"
trap 'rm -f "$installer_file"' EXIT

echo "Downloading the official OpenCode installer from: $INSTALL_URL"
curl -fsSL "$INSTALL_URL" -o "$installer_file"

echo "Running the downloaded OpenCode installer with bash."
echo "Installer saved temporarily at: $installer_file"
bash "$installer_file"

echo "OpenCode CLI installation finished."

if command -v opencode >/dev/null 2>&1; then
  echo "OpenCode CLI path: $(command -v opencode)"
  if version_output="$(opencode --version 2>/dev/null)"; then
    echo "OpenCode CLI version: $version_output"
  else
    echo "OpenCode CLI version could not be determined."
  fi
else
  echo "OpenCode CLI was installed, but 'opencode' is not currently available on PATH."
  echo "Reload your shell or add the installer target directory to PATH, then run: opencode --version"
fi
