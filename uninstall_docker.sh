#!/usr/bin/env bash

set -euo pipefail

# This script will completely uninstall Docker and remove all related data.
# WARNING: This will delete all Docker images, containers, and volumes!

read -p "Are you sure you want to completely uninstall Docker and remove all data? [y/N]: " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
  echo "Aborted."
  exit 1
fi

# Stop Docker service if running
systemctl stop docker || true
systemctl stop containerd || true

# Remove Docker packages
apt-get purge -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras || true
apt-get autoremove -y --purge

# Remove Docker directories and data
rm -rf /var/lib/docker
rm -rf /var/lib/containerd
rm -rf /etc/docker
rm -rf /etc/apt/keyrings/docker.asc
rm -rf /etc/apt/sources.list.d/docker.list

# Remove Docker group if exists
if getent group docker > /dev/null 2>&1; then
  groupdel docker
fi

# Remove leftover binaries if any
rm -f /usr/bin/docker /usr/bin/docker-compose /usr/bin/docker-containerd /usr/bin/docker-runc

# Clean up Docker-related iptables chains
if command -v iptables &> /dev/null; then
  echo "Cleaning up Docker-related iptables chains..."
  DOCKER_CHAINS=(DOCKER DOCKER-USER DOCKER-ISOLATION-STAGE-1 DOCKER-ISOLATION-STAGE-2 DOCKER-BRIDGE DOCKER-CT DOCKER-FORWARD)
  MAIN_CHAINS=(FORWARD INPUT OUTPUT PREROUTING POSTROUTING)
  for table in filter nat; do
    # Remove rules in main chains that jump to Docker chains
    for main_chain in "${MAIN_CHAINS[@]}"; do
      for docker_chain in "${DOCKER_CHAINS[@]}"; do
        while iptables -t $table -C $main_chain -j $docker_chain 2>/dev/null; do
          iptables -t $table -D $main_chain -j $docker_chain || true
        done
      done
    done
    # Now flush and delete Docker chains
    for chain in "${DOCKER_CHAINS[@]}"; do
      if iptables -t $table -L $chain -n &> /dev/null; then
        iptables -t $table -F $chain || true
        iptables -t $table -X $chain || true
      fi
    done
  done
fi

# Print completion message
echo "Docker has been completely uninstalled, and Docker-related iptables chains have been cleaned up." 