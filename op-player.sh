#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVER_DIR="$SCRIPT_DIR/server"
OPS_FILE="$SERVER_DIR/ops.json"
SERVICE_NAME="ftb-server"

if [ $# -eq 0 ]; then
    echo -e "${GREEN}Usage: $0 <playername> [level]${NC}"
    echo ""
    echo "Examples:"
    echo "  $0 PlayerName        # Add player as OP level 4 (full OP)"
    echo "  $0 PlayerName 2       # Add player as OP level 2"
    echo ""
    echo "OP Levels:"
    echo "  1 - Basic commands (help, list, say, etc.)"
    echo "  2 - Can use /clear, /difficulty, /effect, /gamemode, /give, /tp"
    echo "  3 - Can use /ban, /deop, /kick, /op"
    echo "  4 - Full OP (all commands including /stop, /save-all)"
    exit 1
fi

PLAYER_NAME="$1"
OP_LEVEL="${2:-4}"  # Default to level 4 if not specified

# Check if server directory exists
if [ ! -d "$SERVER_DIR" ]; then
    echo -e "${RED}Error: Server directory not found.${NC}"
    echo "Please run ./install.sh first to install the server."
    exit 1
fi

# Method 1: If server is running, use console command
if systemctl is-active --quiet "$SERVICE_NAME" 2>/dev/null || pgrep -f "forge.*jar" > /dev/null; then
    echo -e "${GREEN}Server is running. Attempting to add OP via console...${NC}"
    echo -e "${YELLOW}Note: You need to manually run 'op $PLAYER_NAME' in the server console.${NC}"
    echo ""
    echo "To access the console:"
    echo "  ./console.sh"
    echo ""
    echo "Or if using RCON:"
    echo "  mcrcon -H localhost -P 25575 -p <password> 'op $PLAYER_NAME'"
    exit 0
fi

# Method 2: Edit ops.json directly (server must be stopped)
echo -e "${GREEN}Server is not running. Adding to ops.json...${NC}"

# Check if ops.json exists, create if not
if [ ! -f "$OPS_FILE" ]; then
    echo "[]" > "$OPS_FILE"
fi

# Check if player is already in ops.json
if grep -q "\"name\":\"$PLAYER_NAME\"" "$OPS_FILE" 2>/dev/null; then
    echo -e "${YELLOW}Player $PLAYER_NAME is already in ops.json${NC}"
    read -p "Update their OP level? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Remove existing entry
        python3 -c "
import json
import sys

try:
    with open('$OPS_FILE', 'r') as f:
        ops = json.load(f)
    
    # Remove existing entry
    ops = [op for op in ops if op.get('name', '').lower() != '$PLAYER_NAME'.lower()]
    
    # Add new entry
    ops.append({
        'uuid': '',
        'name': '$PLAYER_NAME',
        'level': $OP_LEVEL,
        'bypassesPlayerLimit': False
    })
    
    with open('$OPS_FILE', 'w') as f:
        json.dump(ops, f, indent=2)
    
    print('Updated OP level for $PLAYER_NAME to $OP_LEVEL')
except Exception as e:
    print(f'Error: {e}', file=sys.stderr)
    sys.exit(1)
" || {
            echo -e "${RED}Error: Failed to update ops.json. Make sure Python 3 is installed.${NC}"
            exit 1
        }
    else
        echo "No changes made."
        exit 0
    fi
else
    # Add new player
    python3 -c "
import json
import sys

try:
    with open('$OPS_FILE', 'r') as f:
        ops = json.load(f)
    
    ops.append({
        'uuid': '',
        'name': '$PLAYER_NAME',
        'level': $OP_LEVEL,
        'bypassesPlayerLimit': False
    })
    
    with open('$OPS_FILE', 'w') as f:
        json.dump(ops, f, indent=2)
    
    print('Added $PLAYER_NAME as OP level $OP_LEVEL')
except Exception as e:
    print(f'Error: {e}', file=sys.stderr)
    sys.exit(1)
" || {
        echo -e "${RED}Error: Failed to update ops.json. Make sure Python 3 is installed.${NC}"
        echo ""
        echo -e "${YELLOW}Manual method:${NC}"
        echo "Edit $OPS_FILE and add:"
        echo "  {"
        echo "    \"uuid\": \"\","
        echo "    \"name\": \"$PLAYER_NAME\","
        echo "    \"level\": $OP_LEVEL,"
        echo "    \"bypassesPlayerLimit\": false"
        echo "  }"
        exit 1
    }
fi

echo -e "${GREEN}✓ Added $PLAYER_NAME as OP level $OP_LEVEL${NC}"
echo -e "${YELLOW}Note: The server must be restarted for changes to take effect.${NC}"

