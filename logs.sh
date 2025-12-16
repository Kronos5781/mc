#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVER_DIR="$SCRIPT_DIR/server"
SERVICE_NAME="ftb-server"
LOG_FILE="$SERVER_DIR/logs/latest.log"

echo -e "${GREEN}=== FTB Server Logs ===${NC}"
echo ""

# Check if service is installed and running
if systemctl is-active --quiet "$SERVICE_NAME" 2>/dev/null; then
    echo -e "${GREEN}Following systemd service logs (Ctrl+C to exit)...${NC}"
    echo ""
    journalctl -u "$SERVICE_NAME" -f
elif [ -f "$LOG_FILE" ]; then
    echo -e "${GREEN}Following server log file (Ctrl+C to exit)...${NC}"
    echo -e "${YELLOW}Log file: $LOG_FILE${NC}"
    echo ""
    tail -f "$LOG_FILE"
else
    echo -e "${YELLOW}No active service found and log file doesn't exist.${NC}"
    echo "Checking for server process..."
    
    if pgrep -f "forge.*jar" > /dev/null; then
        echo -e "${GREEN}Server process found.${NC}"
        echo "If logs are being written elsewhere, check the server directory."
    else
        echo -e "${YELLOW}Server doesn't appear to be running.${NC}"
    fi
    
    # List available log files
    if [ -d "$SERVER_DIR/logs" ]; then
        echo ""
        echo "Available log files:"
        ls -lh "$SERVER_DIR/logs/" 2>/dev/null | tail -n +2
    fi
fi

