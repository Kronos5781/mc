#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
FTB_VERSION="3.1.0"
SERVER_DIR="server"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_BINARY="$SCRIPT_DIR/serverinstall_23_99"

echo -e "${GREEN}=== FTB 3.1.0 Server Installation ===${NC}"
echo ""

# Check if Java is installed
if ! command -v java &> /dev/null; then
    echo -e "${RED}Error: Java is not installed. Please install Java 8 or higher.${NC}"
    exit 1
fi

JAVA_VERSION=$(java -version 2>&1 | head -n 1 | cut -d'"' -f2 | sed '/^1\./s///' | cut -d'.' -f1)
if [ "$JAVA_VERSION" -lt 8 ]; then
    echo -e "${RED}Error: Java 8 or higher is required. Found Java $JAVA_VERSION${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Java found: $(java -version 2>&1 | head -n 1)${NC}"

# Create server directory
if [ -d "$SERVER_DIR" ]; then
    echo -e "${YELLOW}Warning: Server directory already exists.${NC}"
    read -p "Do you want to remove it and reinstall? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "$SERVER_DIR"
    else
        echo -e "${RED}Installation cancelled.${NC}"
        exit 1
    fi
fi

# Check if install binary exists
if [ ! -f "$INSTALL_BINARY" ]; then
    echo -e "${RED}Error: Server install binary not found at $INSTALL_BINARY${NC}"
    exit 1
fi

# Make binary executable
chmod +x "$INSTALL_BINARY"

mkdir -p "$SERVER_DIR"
cd "$SERVER_DIR"

echo -e "${GREEN}Installing FTB Infinity Evolved 3.1.0 Server...${NC}"
echo -e "${GREEN}Using install binary: $INSTALL_BINARY${NC}"
echo ""

# Run the install binary
"$INSTALL_BINARY" || {
    echo -e "${RED}Error: Server installation failed.${NC}"
    exit 1
}

# Make scripts executable
chmod +x *.sh 2>/dev/null || true
chmod +x ServerStart.sh 2>/dev/null || true

# Accept EULA
if [ -f "eula.txt" ]; then
    sed -i 's/eula=false/eula=true/' eula.txt
else
    echo "eula=true" > eula.txt
fi

echo ""
echo -e "${GREEN}=== Installation Complete ===${NC}"
echo -e "${GREEN}Server files are in: $(pwd)${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Review server.properties in the server directory"
echo "2. Run './start.sh' to start the server"
echo "3. Or install as a service with './install-service.sh'"
echo ""

