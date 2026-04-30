#!/usr/bin/env bash

set -euo pipefail

if [ "${EUID:-$(id -u)}" -eq 0 ]; then
  SUDO=()
else
  if ! command -v sudo >/dev/null 2>&1; then
    echo "Error: sudo is required when this installer is not run as root." >&2
    exit 1
  fi

  echo "Checking sudo access for package, repository, group, and service changes."
  sudo -v
  SUDO=(sudo)
fi

if ! command -v apt-get >/dev/null 2>&1; then
  echo "Error: apt-get is required. This installer supports Ubuntu systems with apt only." >&2
  exit 1
fi

if [ ! -r /etc/os-release ]; then
  echo "Error: /etc/os-release is required to verify Ubuntu support." >&2
  exit 1
fi

# shellcheck disable=SC1091
. /etc/os-release
if [ "${ID:-}" != "ubuntu" ]; then
  echo "Error: this installer is Ubuntu-only because it configures Docker's official Ubuntu apt repository." >&2
  echo "Detected OS: ${PRETTY_NAME:-unknown}" >&2
  exit 1
fi

ubuntu_codename="${UBUNTU_CODENAME:-${VERSION_CODENAME:-}}"
if [ -z "$ubuntu_codename" ]; then
  echo "Error: could not determine the Ubuntu codename for Docker's apt repository." >&2
  exit 1
fi

if [ "${EUID:-$(id -u)}" -eq 0 ]; then
  if [ -n "${SUDO_USER:-}" ] && [ "${SUDO_USER:-}" != "root" ]; then
    target_user="$SUDO_USER"
    echo "Docker group membership will be granted to sudo-invoking user: $target_user"
  else
    target_user="$(id -un)"
    echo "Warning: running as root without a non-root SUDO_USER; Docker group membership will be granted to: $target_user" >&2
  fi
else
  target_user="$(id -un)"
  echo "Docker group membership will be granted to current user: $target_user"
fi

if ! id "$target_user" >/dev/null 2>&1; then
  echo "Error: target user '$target_user' does not exist." >&2
  exit 1
fi

# Update package index and install prerequisites.
"${SUDO[@]}" apt-get update
"${SUDO[@]}" apt-get install -y ca-certificates curl

# Add Docker's official GPG key.
"${SUDO[@]}" install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | "${SUDO[@]}" tee /etc/apt/keyrings/docker.asc >/dev/null
"${SUDO[@]}" chmod a+r /etc/apt/keyrings/docker.asc

# Add Docker's official Ubuntu repository to apt sources.
docker_repo="deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu ${ubuntu_codename} stable"
printf '%s\n' "$docker_repo" | "${SUDO[@]}" tee /etc/apt/sources.list.d/docker.list >/dev/null
"${SUDO[@]}" apt-get update

# Install Docker Engine and related packages.
"${SUDO[@]}" apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Create docker group if it doesn't exist.
if ! getent group docker >/dev/null 2>&1; then
  "${SUDO[@]}" groupadd docker
fi

# Add the target user to the docker group.
"${SUDO[@]}" usermod -aG docker "$target_user"

if command -v systemctl >/dev/null 2>&1; then
  "${SUDO[@]}" systemctl enable --now docker
else
  echo "systemctl is not available; skipping Docker service enable/start."
fi

cat <<EOF
Docker installation complete!

Docker group membership was updated for: $target_user
Log out and log back in, restart your shell/session, or run 'newgrp docker' for group changes to take effect.
Test Docker with: docker run hello-world
EOF
