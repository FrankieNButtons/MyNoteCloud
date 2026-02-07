#!/usr/bin/env bash
# Install PaperMC 1.20.4 server (vanilla-like) on systemd Linux.
#
# What it does:
# - Installs server into /opt/minecraft/paper-1.20.4
# - Creates system user minecraft (if missing)
# - Downloads latest Paper build for 1.20.4 via Paper API
# - Generates start.sh and systemd unit file
# - Starts service (optional)
#
# What it does NOT do automatically:
# - It will not enable firewall rules (prints commands)
# - It will not change gameplay configs beyond defaults
#
# Usage:
#   sudo bash install_paper_1.20.4.sh
#
set -euo pipefail

MC_USER="minecraft"
BASE_DIR="/opt/minecraft"
SERVER_DIR="${BASE_DIR}/paper-1.20.4"
SERVICE_NAME="minecraft-paper"
VERSION="1.20.4"
JAR_NAME="paper.jar"

need() { command -v "$1" >/dev/null 2>&1 || { echo "Missing dependency: $1" >&2; exit 1; }; }
need curl
need jq
need systemctl

if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
  echo "Please run as root (sudo)." >&2
  exit 1
fi

echo "This will set up Paper ${VERSION} at: ${SERVER_DIR}"
echo "It may create user: ${MC_USER} and write /etc/systemd/system/${SERVICE_NAME}.service"
read -r -p "Continue? [y/N] " ans
case "${ans}" in
  y|Y|yes|YES) ;;
  *) echo "Aborted."; exit 0;;
esac

# Create user if missing
if id -u "${MC_USER}" >/dev/null 2>&1; then
  echo "User ${MC_USER} exists."
else
  echo "Creating system user ${MC_USER}..."
  useradd --system --home "${BASE_DIR}" --create-home --shell /usr/sbin/nologin "${MC_USER}"
fi

mkdir -p "${SERVER_DIR}"
chown -R "${MC_USER}:${MC_USER}" "${SERVER_DIR}"

# Download latest build
echo "Fetching latest build for Paper ${VERSION}..."
BUILD=$(curl -fsSL "https://api.papermc.io/v2/projects/paper/versions/${VERSION}" | jq -r '.builds[-1]')
if [[ -z "${BUILD}" || "${BUILD}" == "null" ]]; then
  echo "Could not determine latest build." >&2
  exit 1
fi

DOWNLOAD_URL="https://api.papermc.io/v2/projects/paper/versions/${VERSION}/builds/${BUILD}/downloads/paper-${VERSION}-${BUILD}.jar"
echo "Downloading: ${DOWNLOAD_URL}"
sudo -u "${MC_USER}" bash -lc "cd '${SERVER_DIR}' && curl -fL -o '${JAR_NAME}' '${DOWNLOAD_URL}'"

# Write start.sh
cat > "${SERVER_DIR}/start.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
cd /opt/minecraft/paper-1.20.4

# Adjust memory for your machine
XMS=2G
XMX=4G

JAVA=java
FLAGS=(
  -Xms${XMS}
  -Xmx${XMX}
  -XX:+UseG1GC
  -XX:+ParallelRefProcEnabled
  -XX:MaxGCPauseMillis=200
  -XX:+UnlockExperimentalVMOptions
  -XX:+DisableExplicitGC
  -XX:+AlwaysPreTouch
  -XX:G1NewSizePercent=30
  -XX:G1MaxNewSizePercent=40
  -XX:G1HeapRegionSize=8M
  -XX:G1ReservePercent=20
  -XX:G1HeapWastePercent=5
  -XX:G1MixedGCCountTarget=4
  -XX:InitiatingHeapOccupancyPercent=15
  -XX:G1MixedGCLiveThresholdPercent=90
  -XX:G1RSetUpdatingPauseTimePercent=5
  -XX:SurvivorRatio=32
  -XX:+PerfDisableSharedMem
  -XX:MaxTenuringThreshold=1
)

exec ${JAVA} "${FLAGS[@]}" -jar paper.jar nogui
EOF
chown "${MC_USER}:${MC_USER}" "${SERVER_DIR}/start.sh"
chmod +x "${SERVER_DIR}/start.sh"

# systemd unit
cat > "/etc/systemd/system/${SERVICE_NAME}.service" <<EOF
[Unit]
Description=Minecraft Paper ${VERSION} Server
After=network.target

[Service]
Type=simple
User=${MC_USER}
Group=${MC_USER}
WorkingDirectory=${SERVER_DIR}
ExecStart=${SERVER_DIR}/start.sh
Restart=on-failure
RestartSec=10

# Be a good citizen on the host (avoid starving other services like OpenClaw)
Nice=5
CPUWeight=80
IOWeight=80
# MemoryMax=6G

NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=${SERVER_DIR}
LimitNOFILE=100000

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload

echo
echo "Next steps:"
echo "1) First run to generate eula.txt (then set eula=true):"
echo "   sudo -u ${MC_USER} bash -lc 'cd ${SERVER_DIR} && java -Xms1G -Xmx2G -jar ${JAR_NAME} nogui'"
echo "   sudo -u ${MC_USER} bash -lc \"cd ${SERVER_DIR} && sed -i 's/eula=false/eula=true/' eula.txt\""
echo
echo "2) Start service:"
echo "   systemctl enable --now ${SERVICE_NAME}.service"
echo
echo "Firewall (if needed):"
echo "  UFW:       ufw allow 25566/tcp"
echo "  firewalld: firewall-cmd --permanent --add-port=25566/tcp && firewall-cmd --reload"

read -r -p "Enable and start systemd service now? [y/N] " ans2
case "${ans2}" in
  y|Y|yes|YES)
    systemctl enable --now "${SERVICE_NAME}.service"
    systemctl status "${SERVICE_NAME}.service" --no-pager || true
    ;;
  *)
    echo "Skipped starting service."
    ;;
esac
