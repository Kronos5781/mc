#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVER_DIR="$SCRIPT_DIR/server"
SERVICE_NAME="ftb-server"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"
USER=$(whoami)

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${YELLOW}This script needs sudo privileges to install the systemd service.${NC}"
    echo "Please run: sudo ./install-service.sh"
    exit 1
fi

# Check if server directory exists
if [ ! -d "$SERVER_DIR" ]; then
    echo -e "${RED}Error: Server directory not found at $SERVER_DIR${NC}"
    echo "Please run ./install.sh first to install the server."
    exit 1
fi

# Check if start.sh exists
if [ ! -f "$SCRIPT_DIR/start.sh" ]; then
    echo -e "${RED}Error: start.sh not found.${NC}"
    exit 1
fi

echo -e "${GREEN}=== Installing FTB Server as Systemd Service ===${NC}"
echo ""

# Create systemd service file
cat > "$SERVICE_FILE" << EOF
[Unit]
Description=Feed The Beast 3.1.0 Minecraft Server
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$SERVER_DIR
ExecStart=$SCRIPT_DIR/start.sh
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

# Resource limits
LimitNOFILE=65536

# Security settings
NoNewPrivileges=true
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF

echo -e "${GREEN}Service file created: $SERVICE_FILE${NC}"

# Reload systemd
systemctl daemon-reload

# Enable service
systemctl enable "$SERVICE_NAME"

echo ""
echo -e "${GREEN}=== Service Installed Successfully ===${NC}"
echo ""
echo -e "${YELLOW}Service commands:${NC}"
echo "  Start:   sudo systemctl start $SERVICE_NAME"
echo "  Stop:    sudo systemctl stop $SERVICE_NAME"
echo "  Status:  sudo systemctl status $SERVICE_NAME"
echo "  Restart: sudo systemctl restart $SERVICE_NAME"
echo "  Logs:    ./logs.sh (or journalctl -u $SERVICE_NAME -f)"
echo ""
echo -e "${GREEN}The service is enabled and will start on boot.${NC}"
echo -e "${YELLOW}To start it now, run: sudo systemctl start $SERVICE_NAME${NC}"
echo ""

