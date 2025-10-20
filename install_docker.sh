#!/usr/bin/env bash

set -euo pipefail

# Update package index and install prerequisites
apt update
apt install -y ca-certificates curl

# Add Docker's official GPG key
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add the Docker repository to Apt sources
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update

# Install Docker Engine and related packages
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Create docker group if it doesn't exist
if ! getent group docker > /dev/null 2>&1; then
  groupadd docker
fi

# Add the current user to the docker group
usermod -aG docker "$USER"

# Print post-install message
cat <<EOF
Docker installation complete!

You must log out and log back in (or run 'newgrp docker') for group changes to take effect.
Test Docker with: docker run hello-world
EOF