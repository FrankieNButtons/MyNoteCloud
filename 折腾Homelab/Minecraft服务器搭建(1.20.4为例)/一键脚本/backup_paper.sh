#!/usr/bin/env bash
# Backup a Paper server directory (recommended: stop service first).
#
# Default backs up /opt/minecraft/paper-1.20.4 into /opt/minecraft/backups
#
# Usage:
#   sudo bash backup_paper.sh
#   sudo bash backup_paper.sh /opt/minecraft/paper-1.20.4 /opt/minecraft/backups
#
set -euo pipefail

SERVER_DIR="${1:-/opt/minecraft/paper-1.20.4}"
BACKUP_DIR="${2:-/opt/minecraft/backups}"

if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
  echo "Please run as root (sudo) so it can read everything." >&2
  exit 1
fi

if [[ ! -d "${SERVER_DIR}" ]]; then
  echo "Server dir not found: ${SERVER_DIR}" >&2
  exit 1
fi

mkdir -p "${BACKUP_DIR}"

NAME=$(basename "${SERVER_DIR}")
TS=$(date +%F-%H%M)
OUT="${BACKUP_DIR}/${NAME}-${TS}.tar.gz"

echo "Creating backup: ${OUT}"
# Exclude logs/cache-like dirs if you want smaller backups (optional). Keep by default.
tar -C "$(dirname "${SERVER_DIR}")" -czf "${OUT}" "${NAME}"

ls -lh "${OUT}"
