#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# 01-packages.sh
# ------------------------------------------------------------------------------
# Description:
#   - Installs Debian packages list.
#   - Ex to be a space-separated list of packages.
# ==============================================================================

echo "[01-packages.sh] Starting package installation..."

# Parse packages list into an array
IFS=' ' read -r -a packages <<< "${PACKAGES:-}"

if [[ "${#packages[@]}" -eq 0 ]]; then
  echo "[01-packages.sh] No packages specified. Skipping installation."
  exit 0
fi

echo "[01-packages.sh] Packages to install: ${packages[*]}"

# Update package index and install packages
apt-get update
apt-get install -y --no-install-recommends "${packages[@]}"

# Clean up to reduce image size
apt-get clean
rm -rf /var/lib/apt/lists/*

echo "[01-packages.sh] Package installation completed successfully."