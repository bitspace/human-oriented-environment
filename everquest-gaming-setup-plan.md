# EverQuest Gaming Setup Plan for System76 Kudu

## Overview
This plan provides a structured approach for setting up multiple EverQuest clients (Project Lazarus, Live EQ, Heroes Journey, and other emulators) on the System76 Kudu with optimal performance and organization. Priority is on Project Lazarus with MQ2 automation support, followed by Live EQ with 3-box capability and Heroes Journey.

## Directory Structure

```
~/Games/EverQuest/
├── lazarus/                    # Project Lazarus (following their docs)
│   ├── [Standard Lazarus client structure per their docs]
│   └── automation/             # Automation layer
│       ├── mq2/               # MacroQuest2 installation
│       ├── scripts/           # Launch and management scripts
│       └── configs/           # Per-character configurations
├── live/                       # Live EverQuest
│   ├── client/                # Single installation
│   └── instances/             # Instance-specific configs
│       ├── box1/
│       ├── box2/
│       └── box3/
├── heroes-journey/            # Heroes Journey EMU
│   ├── client/                # HJ client files
│   ├── automation/            # Any HJ-specific tools
│   └── configs/               # Character configs
├── emulators/                 # Other servers
│   ├── p1999/
│   ├── quarm/
│   └── [others as needed]
├── wine-prefixes/             # Separate Wine environments
│   ├── lazarus/
│   ├── live/
│   ├── heroes-journey/
│   └── emulators/
├── shared/                    # Shared resources
│   ├── maps/
│   ├── ui/
│   └── utilities/
└── launchers/                 # Master launch scripts
```

## Phase 1: Project Lazarus Setup

### 1.1 Base Installation
```bash
# Create Wine prefix for Lazarus
export WINEPREFIX=~/Games/EverQuest/wine-prefixes/lazarus
winecfg  # Set to Windows XP compatibility

# Install Lazarus client per their documentation
cd ~/Games/EverQuest/lazarus
# [Follow Project Lazarus installation guide]
```

### 1.2 Wine Configuration for Lazarus
- Windows XP compatibility mode
- Core fonts installation: `winetricks corefonts`
- D3D9 optimizations: `winetricks d3dx9`
- Disable Wine debugging for performance
- Configure for NVIDIA GPU usage with prime-run

### 1.3 MQ2 Integration
```bash
# MQ2 setup in automation layer
cd ~/Games/EverQuest/lazarus/automation/mq2
# Install MQ2 per Lazarus-approved version
# Configure MQ2 INI files for multiboxing
```

### 1.4 Launch Script Template
```bash
#!/bin/bash
# ~/Games/EverQuest/launchers/lazarus-multibox.sh

export WINEPREFIX=~/Games/EverQuest/wine-prefixes/lazarus
export WINEDEBUG=-all  # Disable debug output
cd ~/Games/EverQuest/lazarus

# Function to launch with GPU acceleration
launch_instance() {
    local char_name=$1
    local config_path=$2
    echo "Launching $char_name..."
    prime-run wine eqgame.exe patchme /config:$config_path &
    sleep 10
}

# Launch MQ2 first if using
if [ -f "automation/mq2/MQ2Loader.exe" ]; then
    echo "Starting MacroQuest2..."
    prime-run wine automation/mq2/MQ2Loader.exe &
    sleep 5
fi

# Launch instances
launch_instance "Main" "configs/main.ini"
launch_instance "Box1" "configs/box1.ini"
launch_instance "Box2" "configs/box2.ini"

echo "All instances launched. Check logs at ~/Games/EverQuest/lazarus/Logs/"
```

## Phase 2: Live EverQuest Setup

### 2.1 Installation Structure
```bash
# Create Wine prefix for Live
export WINEPREFIX=~/Games/EverQuest/wine-prefixes/live
winecfg  # Windows 10 compatibility for Live

# Install Live EQ client
cd ~/Games/EverQuest/live
# Use Daybreak's launcher or direct download
```

### 2.2 Three-Box Configuration
- Single client installation
- Separate eqclient.ini for each instance
- Custom UI layouts per box role (tank/healer/DPS)
- Shared maps and resources

### 2.3 Launch Script for Live
```bash
#!/bin/bash
# ~/Games/EverQuest/launchers/live-3box.sh

export WINEPREFIX=~/Games/EverQuest/wine-prefixes/live
export WINEDEBUG=-all
cd ~/Games/EverQuest/live/client

# Launch three instances with different configs
for i in {1..3}; do
    cp ../instances/box${i}/eqclient.ini ./
    prime-run wine eqgame.exe patchme &
    sleep 15  # Longer delay for Live client
done
```

## Phase 3: Heroes Journey Setup

### 3.1 Installation Structure
```bash
# Create Wine prefix for Heroes Journey
export WINEPREFIX=~/Games/EverQuest/wine-prefixes/heroes-journey
winecfg  # Check their recommended Windows version

# Install HJ client per their documentation
cd ~/Games/EverQuest/heroes-journey
# Follow Heroes Journey installation guide
```

### 3.2 Heroes Journey Specific Configuration
- Check for any specific DirectX requirements
- Custom client modifications they provide
- Server-specific launcher requirements
- Legal disclaimer acknowledgment (due to ongoing lawsuit)

### 3.3 Launch Script for Heroes Journey
```bash
#!/bin/bash
# ~/Games/EverQuest/launchers/heroes-journey.sh

export WINEPREFIX=~/Games/EverQuest/wine-prefixes/heroes-journey
export WINEDEBUG=-all
cd ~/Games/EverQuest/heroes-journey/client

echo "Launching Heroes Journey..."
echo "Note: Server operating under temporary legal permission"
prime-run wine [HJ-specific-executable] &

# Monitor for any specific HJ requirements
tail -f Logs/eqgame.log
```

## Phase 4: Performance Optimization

### 4.1 System-Level Optimizations
```bash
# GameMode integration (auto-enables when EQ launches)
# Add to launch scripts:
gamemoderun prime-run wine eqgame.exe

# CPU Governor for gaming
# Create gaming profile script
#!/bin/bash
# ~/Games/EverQuest/launchers/gaming-mode.sh
sudo cpupower frequency-set -g performance
echo "Performance mode activated"
```

### 4.2 Wine-Specific Tweaks
- Disable vsync in Wine
- Force single-threaded rendering for EQ
- Custom WINE_CPU_TOPOLOGY for multiboxing
- Esync/Fsync enablement

### 4.3 NVIDIA Optimizations
```bash
# Force high performance mode
nvidia-settings -a "[gpu:0]/GPUPowerMizerMode=1"

# Disable compositor during gaming
# Add to Hyprland config for gaming workspace
```

## Phase 5: Management Tools

### 5.1 Master Control Script
```bash
#!/bin/bash
# ~/Games/EverQuest/launchers/eq-manager.sh

case "$1" in
    lazarus)
        ./lazarus-multibox.sh
        ;;
    live)
        ./live-3box.sh
        ;;
    heroes|hj)
        ./heroes-journey.sh
        ;;
    stop-all)
        pkill -f eqgame.exe
        pkill -f MQ2
        ;;
    status)
        ps aux | grep -E "eqgame|MQ2" | grep -v grep
        ;;
    *)
        echo "Usage: $0 {lazarus|live|heroes|stop-all|status}"
        ;;
esac
```

### 5.2 Log Management
- Centralized log rotation
- Performance monitoring with MangoHud
- Automated log parsing for deaths/events

## Phase 6: Quality of Life

### 6.1 Desktop Integration
- .desktop files for each server
- Waybar integration for quick launch
- Keybindings in Hyprland for window management

### 6.2 Backup Strategy
```bash
# Backup script for characters and configs
#!/bin/bash
# ~/Games/EverQuest/backup.sh
tar -czf ~/Backups/eq-$(date +%Y%m%d).tar.gz \
    --exclude='*.exe' \
    --exclude='*.dll' \
    ~/Games/EverQuest/*/configs \
    ~/Games/EverQuest/*/automation/mq2/*.ini
```

## Implementation Order

1. **Week 1**: Set up directory structure and Wine prefixes
2. **Week 2**: Install and configure Project Lazarus with MQ2
3. **Week 3**: Install Heroes Journey and test performance
4. **Week 4**: Add Live EQ setup
5. **Week 5**: Test multiboxing performance and optimize across all three
6. **Ongoing**: Refine automation scripts based on usage

## Testing Checklist

- [ ] Wine prefix isolation verified
- [ ] GPU acceleration working (nvidia-smi shows load)
- [ ] Multibox instances launch without conflicts
- [ ] MQ2 loads properly with Lazarus
- [ ] Audio works across all instances
- [ ] Network performance acceptable for multiboxing
- [ ] CPU/RAM usage sustainable for extended sessions
- [ ] Logs being generated and rotated properly

## Known Considerations

1. **Network**: Lazarus allows multiboxing from same IP
2. **Performance**: RTX 3060 can handle 6+ EQ instances easily
3. **RAM**: 64GB is more than sufficient for heavy multiboxing
4. **Cooling**: Monitor temps during extended sessions
5. **Updates**: Separate update strategy for each server
6. **Heroes Journey Legal**: Monitor status of Darkpaw lawsuit, backup regularly

## Future Enhancements

- Integration with Discord for notifications
- Stream Deck or macro pad integration
- OBS setup for streaming (if desired)
- Ansible playbooks for reproducible setup
- Container isolation with Bottles or similar

## Resources

- [Project Lazarus Documentation](https://www.lazaruseq.com/)
- [Heroes Journey EMU](https://heroesjourneyemu.com/)
- [MQ2 Documentation](https://docs.macroquest.org/)
- Wine AppDB entries for EverQuest
- EQEmulator forums for server-specific tips
- Heroes Journey Discord for setup support