#!/usr/bin/env bash

set -euo pipefail

confirm() {
  local prompt="$1"
  local answer
  read -r -p "$prompt [y/N]: " answer
  [[ "$answer" =~ ^[Yy]$ ]]
}

if [ "${EUID:-$(id -u)}" -eq 0 ]; then
  SUDO=()
else
  if ! command -v sudo >/dev/null 2>&1; then
    echo "Error: sudo is required when this uninstaller is not run as root." >&2
    exit 1
  fi

  echo "Checking sudo access for package, service, data, group, and firewall changes."
  sudo -v
  SUDO=(sudo)
fi

cat <<'EOF'
Docker uninstall warning

This script can remove Docker packages and repository configuration.
It will also delete Docker data directories if you continue:
  - /var/lib/docker (containers, images, volumes, networks)
  - /var/lib/containerd
  - /etc/docker

Docker group deletion and Docker-related iptables cleanup are high-impact actions
and will be asked about separately.
EOF

if ! confirm "Remove Docker packages, repository files, binaries, and Docker data directories?"; then
  echo "Aborted."
  exit 1
fi

if command -v systemctl >/dev/null 2>&1; then
  "${SUDO[@]}" systemctl stop docker 2>/dev/null || true
  "${SUDO[@]}" systemctl stop containerd 2>/dev/null || true
else
  echo "systemctl is not available; skipping service stop."
fi

if command -v apt-get >/dev/null 2>&1; then
  "${SUDO[@]}" apt-get purge -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras || true
  "${SUDO[@]}" apt-get autoremove -y --purge
else
  echo "apt-get is not available; skipping package purge and autoremove."
fi

"${SUDO[@]}" rm -rf /var/lib/docker /var/lib/containerd /etc/docker
"${SUDO[@]}" rm -f /etc/apt/keyrings/docker.asc /etc/apt/sources.list.d/docker.list
"${SUDO[@]}" rm -f /usr/bin/docker /usr/bin/docker-compose /usr/bin/docker-containerd /usr/bin/docker-runc

if getent group docker >/dev/null 2>&1; then
  cat <<'EOF'

Docker group warning

Deleting the docker group may affect users, permissions, and scripts that expect
the group to exist. This is optional and separate from package/data removal.
EOF
  if confirm "Delete the docker group?"; then
    "${SUDO[@]}" groupdel docker || true
  else
    echo "Keeping docker group."
  fi
else
  echo "Docker group does not exist; skipping group deletion."
fi

cat <<'EOF'

iptables cleanup warning

Removing Docker-related iptables chains changes firewall state and may disrupt
active networking. Only continue if you are sure Docker's firewall rules should
be removed now.
EOF

if confirm "Clean up Docker-related iptables chains?"; then
  if command -v iptables >/dev/null 2>&1; then
    echo "Cleaning up Docker-related iptables chains..."
    DOCKER_CHAINS=(DOCKER DOCKER-USER DOCKER-ISOLATION-STAGE-1 DOCKER-ISOLATION-STAGE-2 DOCKER-BRIDGE DOCKER-CT DOCKER-FORWARD)
    MAIN_CHAINS=(FORWARD INPUT OUTPUT PREROUTING POSTROUTING)
    for table in filter nat; do
      for main_chain in "${MAIN_CHAINS[@]}"; do
        for docker_chain in "${DOCKER_CHAINS[@]}"; do
          while "${SUDO[@]}" iptables -t "$table" -C "$main_chain" -j "$docker_chain" 2>/dev/null; do
            "${SUDO[@]}" iptables -t "$table" -D "$main_chain" -j "$docker_chain" || true
          done
        done
      done

      for chain in "${DOCKER_CHAINS[@]}"; do
        if "${SUDO[@]}" iptables -t "$table" -L "$chain" -n >/dev/null 2>&1; then
          "${SUDO[@]}" iptables -t "$table" -F "$chain" || true
          "${SUDO[@]}" iptables -t "$table" -X "$chain" || true
        fi
      done
    done
  else
    echo "iptables is not available; skipping firewall cleanup."
  fi
else
  echo "Skipping Docker-related iptables cleanup."
fi

echo "Docker uninstall steps completed. Review output above for any skipped actions."
