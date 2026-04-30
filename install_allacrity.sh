#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Warning: install_allacrity.sh is misspelled and kept for compatibility." >&2
echo "Please use install_alacritty.sh instead." >&2

exec bash "$script_dir/install_alacritty.sh" "$@"
