#!/usr/bin/env bash
# Update PaperMC 1.20.4 to the latest build (same MC version) using Paper API.
#
# Safe workflow:
# - stop service
# - optionally backup current paper.jar
# - download new jar to paper.jar
# - start service
#
# Usage:
#   sudo bash update_paper_1.20.4.sh
#
set -euo pipefail

SERVICE_NAME="minecraft-paper"
SERVER_DIR="/opt/minecraft/paper-1.20.4"
VERSION="1.20.4"
MC_USER="minecraft"

need() { command -v "$1" >/dev/null 2>&1 || { echo "Missing dependency: $1" >&2; exit 1; }; }
need curl
need jq
need systemctl

if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
  echo "Please run as root (sudo)." >&2
  exit 1
fi

if [[ ! -d "${SERVER_DIR}" ]]; then
  echo "Server dir not found: ${SERVER_DIR}" >&2
  exit 1
fi

echo "About to update Paper ${VERSION} in ${SERVER_DIR} (service: ${SERVICE_NAME})"
read -r -p "Continue? [y/N] " ans
case "${ans}" in y|Y|yes|YES) ;; *) echo "Aborted."; exit 0;; esac

systemctl stop "${SERVICE_NAME}.service" || true

if [[ -f "${SERVER_DIR}/paper.jar" ]]; then
  TS=$(date +%F-%H%M)
  echo "Backing up current jar to paper.jar.${TS}"
  sudo -u "${MC_USER}" bash -lc "cd '${SERVER_DIR}' && cp -a paper.jar paper.jar.${TS}"
fi

BUILD=$(curl -fsSL "https://api.papermc.io/v2/projects/paper/versions/${VERSION}" | jq -r '.builds[-1]')
DOWNLOAD_URL="https://api.papermc.io/v2/projects/paper/versions/${VERSION}/builds/${BUILD}/downloads/paper-${VERSION}-${BUILD}.jar"

echo "Downloading: ${DOWNLOAD_URL}"
sudo -u "${MC_USER}" bash -lc "cd '${SERVER_DIR}' && curl -fL -o paper.jar '${DOWNLOAD_URL}'"

systemctl start "${SERVICE_NAME}.service"
systemctl status "${SERVICE_NAME}.service" --no-pager || true
