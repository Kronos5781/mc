#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

SERVER_DIR="server"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${RED}=== WARNING: Server Reset ===${NC}"
echo -e "${YELLOW}This will DELETE all world data, player data, and server configuration!${NC}"
echo ""
echo "The following will be deleted:"
echo "  - World files (world/, world_nether/, world_the_end/)"
echo "  - Player data"
echo "  - Server logs"
echo "  - Crash reports"
echo ""
read -p "Are you absolutely sure you want to reset the server? Type 'RESET' to confirm: " -r
echo

if [ "$REPLY" != "RESET" ]; then
    echo -e "${GREEN}Reset cancelled.${NC}"
    exit 0
fi

# Check if server directory exists
if [ ! -d "$SERVER_DIR" ]; then
    echo -e "${RED}Error: Server directory not found.${NC}"
    exit 1
fi

cd "$SCRIPT_DIR/$SERVER_DIR"

# Stop the server if it's running (check for systemd service)
if systemctl is-active --quiet ftb-server.service 2>/dev/null; then
    echo -e "${YELLOW}Stopping FTB server service...${NC}"
    sudo systemctl stop ftb-server.service
    sleep 3
fi

# Check if server is running via process
if pgrep -f "forge.*jar" > /dev/null; then
    echo -e "${YELLOW}Server process detected. Attempting to stop...${NC}"
    pkill -f "forge.*jar" || true
    sleep 3
fi

echo -e "${GREEN}Removing world data...${NC}"
rm -rf world world_nether world_the_end DIM* 2>/dev/null || true

echo -e "${GREEN}Removing player data...${NC}"
rm -rf usercache.json banned-players.json banned-ips.json ops.json whitelist.json 2>/dev/null || true

echo -e "${GREEN}Removing logs and crash reports...${NC}"
rm -rf logs/* crash-reports/* 2>/dev/null || true

# Reset EULA to false (user needs to accept again)
if [ -f "eula.txt" ]; then
    sed -i 's/eula=true/eula=false/' eula.txt
fi

echo ""
echo -e "${GREEN}=== Server Reset Complete ===${NC}"
echo -e "${YELLOW}Note: You will need to accept the EULA again before starting the server.${NC}"
echo ""

