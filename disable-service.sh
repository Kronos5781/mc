#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

SERVICE_NAME="ftb-server"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${YELLOW}This script needs sudo privileges to disable the systemd service.${NC}"
    echo "Please run: sudo ./disable-service.sh"
    exit 1
fi

echo -e "${YELLOW}=== Disabling FTB Server Systemd Service ===${NC}"
echo ""

# Check if service exists
if [ ! -f "$SERVICE_FILE" ]; then
    echo -e "${RED}Error: Service file not found. The service may not be installed.${NC}"
    exit 1
fi

# Stop the service if running
if systemctl is-active --quiet "$SERVICE_NAME" 2>/dev/null; then
    echo -e "${YELLOW}Stopping service...${NC}"
    systemctl stop "$SERVICE_NAME"
fi

# Disable the service
if systemctl is-enabled --quiet "$SERVICE_NAME" 2>/dev/null; then
    echo -e "${YELLOW}Disabling service...${NC}"
    systemctl disable "$SERVICE_NAME"
else
    echo -e "${YELLOW}Service was already disabled.${NC}"
fi

# Optionally remove the service file
read -p "Do you want to remove the service file? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -f "$SERVICE_FILE"
    systemctl daemon-reload
    echo -e "${GREEN}Service file removed.${NC}"
fi

echo ""
echo -e "${GREEN}=== Service Disabled ===${NC}"
echo ""

