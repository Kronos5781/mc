# FTB 3.1.0 Server Management

This repository contains scripts and utilities to manage a Feed The Beast (FTB) Infinity Evolved 3.1.0 Minecraft server.

## Prerequisites

- **Java 8 or higher** (Java 8 recommended for Minecraft 1.12.2)
- **Linux** (scripts are designed for Linux systems)
- **wget or curl** (for downloading server files)
- **unzip** (for extracting server files)
- **sudo** access (for service installation)

## Quick Start

### 1. Install the Server

```bash
./install.sh
```

This script will:
- Check for Java installation
- Download the FTB 3.1.0 server files
- Extract and set up the server
- Accept the Minecraft EULA

### 2. Start the Server

```bash
./start.sh
```

The server will start with **32GB of RAM** allocated. The script automatically configures optimal JVM settings for Minecraft server performance.

### 3. Install as a Systemd Service (Optional)

To run the server as a background service that starts on boot:

```bash
sudo ./install-service.sh
sudo systemctl start ftb-server
```

## Scripts Overview

### Core Scripts

- **`install.sh`** - Downloads and installs the FTB 3.1.0 server
- **`start.sh`** - Starts the server with 32GB RAM allocation
- **`reset.sh`** - Resets the server (deletes worlds, player data, logs)

### Service Management

- **`install-service.sh`** - Installs the server as a systemd service
- **`disable-service.sh`** - Disables and optionally removes the systemd service
- **`logs.sh`** - Follows server logs in real-time

## Usage Examples

### Starting the Server Manually

```bash
./start.sh
```

### Installing and Managing the Service

```bash
# Install the service
sudo ./install-service.sh

# Start the service
sudo systemctl start ftb-server

# Stop the service
sudo systemctl stop ftb-server

# Check service status
sudo systemctl status ftb-server

# View logs
./logs.sh
# Or use journalctl directly:
sudo journalctl -u ftb-server -f
```

### Resetting the Server

**⚠️ WARNING: This will delete all world data!**

```bash
./reset.sh
# Type 'RESET' when prompted to confirm
```

### Following Logs

```bash
# Follow logs (works with both service and manual start)
./logs.sh
```

## Server Configuration

After installation, you can configure the server by editing files in the `server/` directory:

- **`server.properties`** - Main server configuration (port, difficulty, etc.)
- **`eula.txt`** - EULA acceptance (automatically set by install script)

## Memory Configuration

The server is configured to use **32GB of RAM** with the following settings:
- Minimum: 8GB
- Maximum: 32GB
- Optimized JVM flags for Minecraft server performance

To modify memory settings, edit `start.sh` and change the `MIN_MEM` and `MAX_MEM` variables.

## Directory Structure

```
.
├── README.md              # This file
├── .gitignore            # Git ignore rules for server files
├── install.sh            # Server installation script
├── start.sh              # Server start script
├── reset.sh              # Server reset script
├── install-service.sh    # Systemd service installation
├── disable-service.sh    # Systemd service removal
├── logs.sh               # Log following script
└── server/               # Server files (gitignored)
    ├── world/            # World data (gitignored)
    ├── logs/             # Server logs (gitignored)
    └── ...
```

## Troubleshooting

### Server Won't Start

1. Check Java installation: `java -version`
2. Verify server files are installed: `ls -la server/`
3. Check EULA is accepted: `grep eula server/eula.txt`
4. Review logs: `./logs.sh` or check `server/logs/latest.log`

### Service Issues

1. Check service status: `sudo systemctl status ftb-server`
2. View service logs: `sudo journalctl -u ftb-server -n 50`
3. Verify service file: `cat /etc/systemd/system/ftb-server.service`

### Port Already in Use

If port 25565 is already in use, edit `server/server.properties` and change the `server-port` value.

## Notes

- All server files, worlds, and logs are gitignored
- The server requires accepting the Minecraft EULA (handled automatically)
- The service runs as the user who installed it
- Server restarts automatically if it crashes (when running as service)

## License

This repository contains utility scripts for managing an FTB server. The FTB modpack and Minecraft server software are subject to their respective licenses.

