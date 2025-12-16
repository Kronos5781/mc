#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

SERVER_DIR="server"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if server directory exists
if [ ! -d "$SERVER_DIR" ]; then
    echo -e "${RED}Error: Server directory not found.${NC}"
    echo "Please run ./install.sh first to install the server."
    exit 1
fi

cd "$SCRIPT_DIR/$SERVER_DIR"

# Check if EULA is accepted
if [ ! -f "eula.txt" ] || ! grep -q "eula=true" eula.txt; then
    echo -e "${YELLOW}EULA not accepted. Accepting EULA...${NC}"
    echo "eula=true" > eula.txt
fi

# Java memory settings (32GB RAM)
MIN_MEM="8G"
MAX_MEM="32G"
JAVA_OPTS="-Xms${MIN_MEM} -Xmx${MAX_MEM} -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1"

# Additional JVM arguments for better performance
JAVA_OPTS="$JAVA_OPTS -Dusing.aikars.flags=https://mcflags.emc.gs"

echo -e "${GREEN}=== Starting FTB 3.1.0 Server ===${NC}"
echo -e "${GREEN}Memory: ${MIN_MEM} - ${MAX_MEM}${NC}"
echo -e "${GREEN}Working directory: $(pwd)${NC}"
echo ""

# Check for ServerStart.sh (FTB launcher script)
if [ -f "ServerStart.sh" ]; then
    echo -e "${GREEN}Using FTB ServerStart.sh${NC}"
    # Backup original if not already backed up
    if [ ! -f "ServerStart.sh.original" ]; then
        cp ServerStart.sh ServerStart.sh.original
    fi
    # Modify ServerStart.sh to use our memory settings
    # Replace common memory setting patterns
    sed -i "s/MAX_RAM=.*/MAX_RAM=\"${MAX_MEM}\"/" ServerStart.sh 2>/dev/null || true
    sed -i "s/-Xmx[0-9]*[MG]/-Xmx${MAX_MEM}/g" ServerStart.sh 2>/dev/null || true
    sed -i "s/-Xms[0-9]*[MG]/-Xms${MIN_MEM}/g" ServerStart.sh 2>/dev/null || true
    # Add our JVM options if not present
    if ! grep -q "XX:+UseG1GC" ServerStart.sh; then
        # Try to add JAVA_OPTS or modify java command
        sed -i "/java.*jar/a\\    JAVA_OPTS=\"\$JAVA_OPTS ${JAVA_OPTS}\"" ServerStart.sh 2>/dev/null || true
    fi
    export MAX_RAM="${MAX_MEM}"
    export JAVA_OPTS="$JAVA_OPTS"
    bash ServerStart.sh
elif [ -f "startserver.sh" ]; then
    echo -e "${GREEN}Using startserver.sh${NC}"
    bash startserver.sh
elif ls forge-*.jar 1> /dev/null 2>&1; then
    FORGE_JAR=$(ls forge-*.jar | head -n 1)
    echo -e "${GREEN}Starting Forge server directly: $FORGE_JAR${NC}"
    java $JAVA_OPTS -jar "$FORGE_JAR" nogui
else
    echo -e "${RED}Error: Could not find server startup script or Forge JAR.${NC}"
    echo "Please ensure the server is properly installed."
    exit 1
fi

