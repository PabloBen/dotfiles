#!/usr/bin/env bash

set -euo pipefail

if command -v batcat >/dev/null 2>&1; then
  echo "batcat is already installed: $(command -v batcat)"
  exit 0
fi

if command -v bat >/dev/null 2>&1; then
  echo "bat is already installed: $(command -v bat)"
  exit 0
fi

if ! command -v apt-get >/dev/null 2>&1; then
  echo "Error: apt-get is required. This installer supports Ubuntu/Debian-family systems only." >&2
  exit 1
fi

echo "Installing Ubuntu package with apt: bat"
if [ "${EUID:-$(id -u)}" -eq 0 ]; then
  apt-get update
  apt-get install -y bat
else
  if ! command -v sudo >/dev/null 2>&1; then
    echo "Error: installing bat requires apt, but sudo is not available. Re-run as root or install sudo." >&2
    exit 1
  fi

  echo "Checking sudo access before installing bat."
  sudo -v
  sudo apt-get update
  sudo apt-get install -y bat
fi
