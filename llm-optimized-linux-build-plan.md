# LLM-Optimized Linux Build Plan for System76 Kudu

## Executive Summary

This build plan prioritizes **rapid AI agent deployment** to enable Claude Code or Gemini CLI orchestration within the first 30 minutes of installation. The system uses **Arch Linux with XFS** for maximum performance and **Hyprland** for superior gaming capabilities. By establishing AI agent control early, the remaining system configuration becomes a collaborative human-AI process, leveraging the agent's ability to parse documentation, execute commands, and maintain consistency.

**Key Decisions:**
- **Distribution**: Arch Linux (bleeding-edge, maximum control)
- **Filesystem**: XFS (performance over snapshots)
- **AUR Helper**: paru (powerful pacman wrapper with AUR support)
- **Window Manager**: Hyprland (gaming performance, LLM parseability)
- **AI Priority**: Claude Code/Gemini CLI operational by Phase 2

## Hardware-Specific Configuration

### System76 Kudu (kudu6) Optimizations

**CPU Configuration**
- AMD Ryzen 9 5900HX: Enable AMD P-State driver for dynamic frequency scaling
- Set CPU governor to `schedutil` by default, `performance` for gaming
- Enable AMD-specific compiler optimizations in makepkg.conf

**GPU Configuration**
- Primary: NVIDIA RTX 3060 Mobile (discrete)
  - Driver: nvidia-dkms (560+ for explicit sync)
  - Power management: nvidia-prime for on-demand switching
- Secondary: AMD Radeon RX Vega 8 (integrated)
  - Driver: mesa (built into kernel)
  - Use for desktop compositing when not gaming

**System76-Specific**
- Install system76-firmware for laptop-specific optimizations
- Configure system76-power for power profile management
- Enable S3 sleep state if not default

## Configuration Strategy

### Global Configuration Approach

**Directory Structure**
```
/etc/llm-laptop/            # System-wide configs (LLM-parseable)
├── system.yaml            # Master configuration
├── gaming.yaml            # Gaming-specific settings
├── automation.yaml        # AI agent settings
└── hooks/                 # REST-like API hooks

~/.config/                  # User configs
├── hypr/                  # Hyprland configuration
├── paru/                  # Paru settings
├── llm-tools/             # AI agent configurations
└── gaming/                # Game-specific configs
```

**Configuration Principles**
- All configs in YAML/TOML/INI format (no binary)
- Self-documenting with inline comments
- Git-managed for version control
- Parseable by major LLMs without preprocessing

## Installation Phases

### Phase 1: Minimal Base System (0-15 minutes)

**Objective**: Bootable system with network access

```bash
# Boot Arch ISO and establish network
iwctl  # For WiFi or use ethernet

# Partition disk (assuming /dev/nvme0n1)
gdisk /dev/nvme0n1
# Create:
# - 512MB EFI partition (ef00)
# - 100% remaining XFS root partition (8300)

# Format partitions
mkfs.fat -F32 /dev/nvme0n1p1
mkfs.xfs /dev/nvme0n1p2

# Mount and install base system
mount /dev/nvme0n1p2 /mnt
mkdir /mnt/boot
mount /dev/nvme0n1p1 /mnt/boot

# Install essential packages only
pacstrap /mnt base linux linux-firmware base-devel \
              networkmanager neovim git amd-ucode \
              xfsprogs openssh

# Generate fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Chroot and configure
arch-chroot /mnt

# Minimal configuration
ln -sf /usr/share/zoneinfo/YOUR_TIMEZONE /etc/localtime
hwclock --systohc
echo "kudu" > /etc/hostname
echo "LANG=en_US.UTF-8" > /etc/locale.conf
locale-gen

# Create user
useradd -m -G wheel -s /bin/bash chris
passwd chris
EDITOR=nvim visudo  # Uncomment wheel group

# Bootloader (systemd-boot)
bootctl install
echo "default arch.conf" > /boot/loader/loader.conf
echo "timeout 3" >> /boot/loader/loader.conf

cat > /boot/loader/entries/arch.conf << EOF
title   Arch Linux
linux   /vmlinuz-linux
initrd  /amd-ucode.img
initrd  /initramfs-linux.img
options root=/dev/nvme0n1p2 rw
EOF

# Enable networking
systemctl enable NetworkManager
systemctl enable sshd

# Exit and reboot
exit
umount -R /mnt
reboot
```

### Phase 2: AI Agent Deployment (15-30 minutes)

**Objective**: Get Claude Code or Gemini CLI operational

```bash
# After reboot, login and connect network
nmcli device wifi connect YOUR_SSID password YOUR_PASSWORD

# Install development essentials for AI agents
sudo pacman -S --noconfirm \
    python python-pip \
    curl wget httpie jq \
    tmux \
    man-db man-pages \
    rustup

# Install paru for AUR access
sudo pacman -S --needed base-devel git
git clone https://aur.archlinux.org/paru.git /tmp/paru
cd /tmp/paru && makepkg -si --noconfirm

# Configure GPG for reliable keyserver access
mkdir -p ~/.gnupg
cat > ~/.gnupg/gpg.conf << EOF
keyserver hkps://keys.openpgp.org
keyserver-options auto-key-retrieve
EOF

# Install uv first for Python package management
curl -LsSf https://astral.sh/uv/install.sh | sh
source ~/.bashrc  # Reload PATH for uv

# Install nvm for Node.js version management
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
source ~/.bashrc  # Reload to get nvm

# Install latest LTS Node.js via nvm
nvm install --lts
nvm use --lts
nvm alias default node  # Set as default

# Install Claude Code and other AI CLI tools locally via nvm-managed npm
npm install --global @anthropic-ai/claude-code
npm install --global @google/gemini-cli @openai/codex

# Optional: Install alternative package managers if needed
# npm install --global yarn pnpm

# Install Python-based LLM tools
uv tool install llm

# Install protonup for Proton management
uv tool install protonup

# Import 1Password GPG key manually to avoid keyserver issues
curl -s https://downloads.1password.com/linux/keys/1password.asc | gpg --import

# Create AI agent workspace
mkdir -p ~/projects/system-config
cd ~/projects/system-config
git init

# Create initial configuration for AI agent
cat > ~/.config/llm-tools/config.yaml << 'EOF'
system:
  role: "System configuration assistant"
  capabilities:
    - package_management: true
    - configuration_editing: true
    - service_management: true
    - git_operations: true
  
preferences:
  package_manager: "paru"
  editor: "neovim"
  shell: "bash"
  
paths:
  configs: "~/.config"
  projects: "~/projects"
  scripts: "~/.local/bin"
EOF

# Create initial CLAUDE.md for project context
cat > ~/projects/system-config/CLAUDE.md << 'EOF'
# System Configuration Project

You are helping configure an Arch Linux system on a System76 Kudu laptop.

## Current Status
- Base Arch Linux installed with XFS
- Network connectivity established
- paru AUR helper installed
- AI agents available for use

## Next Steps
1. Install and configure Hyprland
2. Set up NVIDIA drivers with Wayland support
3. Configure gaming stack (Steam, Proton management, GameMode)
4. Install development tools

## System Specifications
- CPU: AMD Ryzen 9 5900HX
- GPU: NVIDIA RTX 3060 Mobile + AMD Vega 8
- RAM: 64GB
- Storage: XFS filesystem

## Preferences
- Window Manager: Hyprland
- Gaming priority
- Bleeding-edge packages preferred
- Performance over stability
EOF

echo "AI Agent Ready! You can now use Claude Code or Gemini CLI to continue setup."
```

### Phase 3: Display Server & Window Manager (30-45 minutes)
*[AI Agent Assisted]*

```bash
# Install Wayland and Hyprland stack
paru -S --noconfirm \
    hyprland xorg-xwayland \
    waybar wofi \
    hyprpaper hyprlock hypridle \
    wl-clipboard \
    grim slurp \
    xdg-desktop-portal-hyprland \
    hyprcursor

# Install terminal
paru -S --noconfirm kitty

# Install fonts and themes
paru -S --noconfirm \
    noto-fonts noto-fonts-emoji \
    papirus-icon-theme \
    xcursor-vanilla-dmz

# Install LightDM with GTK greeter (lightweight display manager)
sudo pacman -S --noconfirm lightdm lightdm-gtk-greeter
sudo systemctl enable lightdm

# Create Hyprland session entry for LightDM
sudo mkdir -p /usr/share/wayland-sessions
sudo tee /usr/share/wayland-sessions/hyprland.desktop << EOF
[Desktop Entry]
Name=Hyprland
Comment=Dynamic tiling Wayland compositor
Exec=Hyprland
Type=Application
EOF

# Configure LightDM for Wayland sessions
sudo tee -a /etc/lightdm/lightdm.conf << EOF

# Hyprland/Wayland configuration
[Seat:*]
session-wrapper=/usr/share/lightdm/lightdm-session
greeter-session=lightdm-gtk-greeter
user-session=hyprland
EOF

# Create Hyprland configuration
mkdir -p ~/.config/hypr
cat > ~/.config/hypr/hyprland.conf << 'EOF'
# Hyprland Configuration
# Optimized for System76 Kudu with RTX 3060

# Monitor configuration
monitor=eDP-1,2560x1440@165,0x0,1
monitor=,preferred,auto,1

# Execute at launch
exec-once = waybar
exec-once = mako
exec-once = swayidle -w
exec-once = /usr/lib/polkit-kde-authentication-agent-1

# Environment variables
env = XCURSOR_SIZE,24
env = WLR_NO_HARDWARE_CURSORS,1
env = WLR_DRM_DEVICES,/dev/dri/card1:/dev/dri/card0

# Gaming optimizations
env = __GL_GSYNC_ALLOWED,1
env = __GL_VRR_ALLOWED,1
env = WLR_DRM_NO_ATOMIC,1

# Input configuration
input {
    kb_layout = us
    follow_mouse = 1
    touchpad {
        natural_scroll = yes
    }
    sensitivity = 0
}

# General settings
general {
    gaps_in = 5
    gaps_out = 10
    border_size = 2
    col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
    col.inactive_border = rgba(595959aa)
    layout = dwindle
}

# Decorations
decoration {
    rounding = 10
    blur {
        enabled = true
        size = 3
        passes = 1
    }
    drop_shadow = yes
    shadow_range = 4
    shadow_render_power = 3
}

# Animations (can be disabled for gaming)
animations {
    enabled = yes
    bezier = myBezier, 0.05, 0.9, 0.1, 1.05
    animation = windows, 1, 7, myBezier
    animation = windowsOut, 1, 7, default, popin 80%
    animation = fade, 1, 7, default
    animation = workspaces, 1, 6, default
}

# Layout
dwindle {
    pseudotile = yes
    preserve_split = yes
}

# Window rules for games
windowrule = fullscreen, ^(steam_app)
windowrule = immediate, ^(steam_app)
windowrule = noanim, ^(steam_app)
windowrule = noborder, ^(steam_app)

# Keybindings
$mainMod = SUPER

bind = $mainMod, RETURN, exec, kitty
bind = $mainMod, Q, killactive,
bind = $mainMod, M, exit,
bind = $mainMod, E, exec, thunar
bind = $mainMod, V, togglefloating,
bind = $mainMod, R, exec, wofi --show drun
bind = $mainMod, P, pseudo,
bind = $mainMod, J, togglesplit,
bind = $mainMod, F, fullscreen

# Gaming mode toggle (disables animations and blur)
bind = $mainMod SHIFT, G, exec, hyprctl keyword animations:enabled 0 && hyprctl keyword decoration:blur:enabled 0
bind = $mainMod SHIFT, N, exec, hyprctl keyword animations:enabled 1 && hyprctl keyword decoration:blur:enabled 1

# Move focus
bind = $mainMod, left, movefocus, l
bind = $mainMod, right, movefocus, r
bind = $mainMod, up, movefocus, u
bind = $mainMod, down, movefocus, d

# Switch workspaces
bind = $mainMod, 1, workspace, 1
bind = $mainMod, 2, workspace, 2
bind = $mainMod, 3, workspace, 3
bind = $mainMod, 4, workspace, 4
bind = $mainMod, 5, workspace, 5

# Move windows to workspace
bind = $mainMod SHIFT, 1, movetoworkspace, 1
bind = $mainMod SHIFT, 2, movetoworkspace, 2
bind = $mainMod SHIFT, 3, movetoworkspace, 3
bind = $mainMod SHIFT, 4, movetoworkspace, 4
bind = $mainMod SHIFT, 5, movetoworkspace, 5

# Mouse bindings
bindm = $mainMod, mouse:272, movewindow
bindm = $mainMod, mouse:273, resizewindow
EOF
```

### Phase 4: NVIDIA Drivers & Gaming Stack (45-60 minutes)
*[AI Agent Assisted]*

```bash
# Install NVIDIA drivers with Wayland support
paru -S --noconfirm \
    nvidia-dkms \
    nvidia-utils \
    lib32-nvidia-utils \
    nvidia-settings \
    nvidia-prime

# Configure NVIDIA for Wayland
sudo cat > /etc/modprobe.d/nvidia.conf << 'EOF'
options nvidia-drm modeset=1
options nvidia NVreg_UsePageAttributeTable=1
options nvidia NVreg_EnablePCIeGen3=1
EOF

# Add NVIDIA modules to initramfs
sudo sed -i 's/MODULES=()/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf
sudo mkinitcpio -P

# Install gaming essentials
paru -S --noconfirm \
    steam \
    mangohud lib32-mangohud \
    gamemode lib32-gamemode \
    gamescope \
    lutris bottles goverlay \
    wine-staging winetricks \
    protonup-qt-bin \
    lib32-vulkan-icd-loader \
    lib32-nvidia-utils \
    vulkan-tools

# Configure GameMode
sudo usermod -a -G gamemode $USER

cat > ~/.config/gamemode.ini << 'EOF'
[general]
renice = 10
inhibit_screensaver = 1

[gpu]
apply_gpu_optimisations = accept-responsibility
gpu_device = 0
amd_performance_level = high
nv_powermizer_mode = 1
nv_core_clock_mhz_offset = 100
nv_mem_clock_mhz_offset = 200

[cpu]
park_cores = no
pin_cores = yes
EOF

# Steam launch options for optimization
mkdir -p ~/.local/share/Steam
cat > ~/.local/share/Steam/steam_launch_options.txt << 'EOF'
# Add to Steam game properties:
# gamemoderun mangohud %command%
# For Proton games:
# PROTON_ENABLE_NVAPI=1 PROTON_HIDE_NVIDIA_GPU=0 VKD3D_CONFIG=dxr gamemoderun mangohud %command%
EOF

# MangoHud configuration
mkdir -p ~/.config/MangoHud
cat > ~/.config/MangoHud/MangoHud.conf << 'EOF'
fps_limit=0
vsync=0
gl_vsync=0

cpu_stats
cpu_temp
gpu_stats
gpu_temp
ram
vram
fps
frametime
frame_timing

position=top-left
font_size=24
background_alpha=0.5
EOF
```

### Phase 5: Development Environment (60-75 minutes)
*[AI Agent Driven]*

```bash
# Core development tools
paru -S --noconfirm \
    neovim \
    visual-studio-code-insiders-bin \
    docker docker-compose \
    podman podman-compose buildah \
    kubectl helm \
    terraform \
    ansible \
    distrobox  # For isolated development environments

# Programming languages and tools
paru -S --noconfirm \
    go \
    python-pipx pyenv \
    jdk-openjdk maven gradle \
    bash shellcheck shfmt

# Note: rustup and python-pip already installed in Phase 2

# Note: Node.js managed via nvm, not system packages

# JetBrains suite
paru -S --noconfirm jetbrains-toolbox

# AI/ML frameworks (CUDA versions for NVIDIA RTX 3060)
paru -S --noconfirm \
    python-pytorch-cuda \
    python-tensorflow-cuda \
    python-scikit-learn \
    python-pandas \
    python-numpy \
    python-matplotlib \
    python-transformers \
    python-datasets \
    python-huggingface-hub \
    jupyter-notebook jupyterlab \
    cuda cudnn

# Local LLM serving
paru -S --noconfirm ollama  # CUDA version for RTX 3060

# Cloud development
paru -S --noconfirm \
    aws-cli-v2-bin \
    aws-sam-cli-bin \
    google-cloud-cli \
    azure-cli

# Database tools
paru -S --noconfirm \
    postgresql \
    mariadb \
    redis \
    mongodb-bin \
    dbeaver

# Configure Docker
sudo systemctl enable docker
sudo usermod -a -G docker $USER

# Setup development directory structure
mkdir -p ~/projects/{personal,work,learning,ai}
mkdir -p ~/.local/bin
mkdir -p ~/.config/nvim
```

### Phase 6: Audio & Creative Tools (75-90 minutes)
*[AI Agent Driven]*

```bash
# Audio system
paru -S --noconfirm \
    pipewire \
    pipewire-alsa \
    pipewire-jack \
    pipewire-pulse \
    wireplumber \
    helvum \
    pavucontrol \
    easyeffects

# Music production
paru -S --noconfirm \
    audacity \
    reaper  # AUR package
    ardour \
    lmms

# MIDI support
paru -S --noconfirm \
    jack2 qjackctl \
    a2jmidid  # ALSA to JACK MIDI bridge

# Writing and documentation
paru -S --noconfirm \
    obsidian \
    pandoc

# Security and password management
paru -S --noconfirm \
    gnupg \
    1password 1password-cli
```

## Package Categories

### Development Environment
[Suggested by: All models]
- **Editors**: Neovim, VS Code Insiders, JetBrains Toolbox
- **Languages**: Rust, Go, Python (with pyenv/pipx), Node.js (via nvm), Java
- **Shells**: Bash with shellcheck/shfmt
- **Containers**: Docker, Podman, Buildah, Distrobox
- **Version Control**: Git, GitHub CLI

### AI/ML Stack
[Suggested by: Gemini 2.5 Pro, Claude Opus 4.1]
- **Frameworks**: PyTorch, TensorFlow (CUDA-enabled), Transformers, Datasets
- **Local LLM**: Ollama (CUDA version)
- **Tools**: JupyterLab, Claude Code, Gemini CLI, Simon Willison's llm
- **Python ML**: scikit-learn, pandas, numpy, matplotlib, huggingface-hub
- **Model Storage**: /home/models (dedicated directory)

### Cloud Development
[Suggested by: ChatGPT-5, Claude Sonnet 4]
- **AWS**: aws-cli-v2, SAM CLI
- **GCP**: google-cloud-cli
- **Azure**: azure-cli
- **Infrastructure**: Terraform, Ansible

### Gaming Infrastructure
[Suggested by: All models with gaming focus]
- **Core**: Steam, Lutris, Bottles
- **Optimization**: GameMode, MangoHud, Proton management via protonup
- **Tools**: GOverlay, ProtonUp-Qt
- **Compatibility**: Wine-staging, winetricks
- **Libraries**: lib32-mesa, lib32-vulkan-icd-loader, lib32-nvidia-utils

### Security Hardening
[Suggested by: Mistral, Perplexity]
- **Firewall**: ufw
- **Encryption**: GnuPG
- **Password Management**: 1Password, 1Password CLI
- **GPG Configuration**: Keyserver setup for reliable package signing

## Build Order and Dependencies

### Critical Path (Must complete in order)
1. Base system installation
2. Network configuration
3. paru installation
4. AI agent deployment
5. Display server (Wayland/Hyprland)
6. NVIDIA drivers

### Parallel Installation Groups
Once critical path complete, these can be done simultaneously:

**Group A: Gaming**
- Steam
- Proton management via protonup
- Game tools

**Group B: Development**
- Programming languages
- IDEs
- Container tools

**Group C: Productivity**
- Browsers
- Office tools
- Communication apps

## Maintenance Strategy

### Update Procedures
```bash
# Weekly system update (AI agent can automate)
paru -Syu --noconfirm

# Gaming driver update (manual review recommended)
paru -S nvidia-dkms nvidia-utils

# Kernel update procedure
paru -S linux linux-headers
sudo mkinitcpio -P
# Reboot and test
```

### Performance Monitoring
```bash
# Create monitoring script
cat > ~/.local/bin/perf-check << 'EOF'
#!/bin/bash
echo "=== System Performance Check ==="
echo "CPU Governor: $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)"
echo "GPU Mode: $(nvidia-smi --query-gpu=performance_state --format=csv,noheader)"
echo "Memory Usage: $(free -h | grep Mem | awk '{print $3 "/" $2}')"
echo "Disk I/O: $(iostat -x 1 2 | grep nvme)"
EOF

chmod +x ~/.local/bin/perf-check
```

### Backup Recommendations
- Configuration files: Git repository
- User data: rsync to external drive
- System list: `paru -Qqe > packages.txt`

## Automation Hooks Implementation

### Basic REST API for System Control
[Based on Gemini 2.5 Pro concept]

```python
# ~/.local/bin/system-api.py
from fastapi import FastAPI
import subprocess
import json

app = FastAPI()

@app.get("/api/system/packages/{package}")
def get_package(package: str):
    result = subprocess.run(["paru", "-Qi", package], 
                          capture_output=True, text=True)
    return {"installed": result.returncode == 0, 
            "info": result.stdout}

@app.post("/api/system/packages/{package}")
def install_package(package: str):
    result = subprocess.run(["paru", "-S", "--noconfirm", package],
                          capture_output=True, text=True)
    return {"success": result.returncode == 0,
            "output": result.stdout}

@app.post("/api/gaming/gamemode/toggle")
def toggle_gamemode():
    # Implementation for GameMode toggle
    pass

@app.get("/api/wm/workspaces")
def get_workspaces():
    result = subprocess.run(["hyprctl", "workspaces", "-j"],
                          capture_output=True, text=True)
    return json.loads(result.stdout)

# Run with: uvicorn system-api:app --reload
```

### Gaming Automation Scripts

```bash
# ~/.local/bin/game-optimize
#!/bin/bash
# Optimize system for gaming

GAME=$1

# Enable performance mode
sudo cpupower frequency-set -g performance

# Set GPU to max performance
nvidia-settings -a "[gpu:0]/GPUPowerMizerMode=1"

# Disable compositor animations
hyprctl keyword animations:enabled 0

# Start game with optimizations
gamemoderun mangohud steam steam://rungameid/$GAME

# Restore on exit
trap 'sudo cpupower frequency-set -g schedutil; \
      hyprctl keyword animations:enabled 1' EXIT
```

## Validation Checklist

### System Functionality
- [ ] System boots successfully
- [ ] Network connectivity established
- [ ] AI agents (Claude Code/Gemini CLI) operational
- [ ] Hyprland starts and responds to commands
- [ ] NVIDIA drivers loaded with Wayland support

### Gaming Performance
- [ ] Steam launches and games run
- [ ] Proton versions manageable via protonup
- [ ] GameMode activates successfully
- [ ] MangoHud displays performance metrics
- [ ] 60+ FPS in target games

### Development Environment
- [ ] All programming languages installed
- [ ] Docker/Podman functional
- [ ] AI/ML frameworks detect CUDA
- [ ] Cloud CLIs authenticated

### Automation Capabilities
- [ ] paru handles AUR packages
- [ ] Hyprctl controls window manager
- [ ] Configuration files parseable by LLMs
- [ ] System API responds to requests

## Success Metrics

### Performance Targets
- Boot time: <10 seconds
- Game launch: <30 seconds
- Package installation: Via paru with no manual intervention
- AI agent response: <2 seconds for system queries

### Automation Goals
- 90% of system tasks scriptable
- All configurations in text format
- Git-managed dotfiles
- AI agent can perform routine maintenance

## Troubleshooting Guide

### Common Issues and Solutions

**NVIDIA Wayland Issues**
```bash
# Ensure modeset is enabled
cat /sys/module/nvidia_drm/parameters/modeset  # Should show Y

# Force Wayland for Electron apps
--enable-features=UseOzonePlatform --ozone-platform=wayland
```

**Audio Issues**
```bash
# Restart PipeWire
systemctl --user restart pipewire pipewire-pulse wireplumber

# Check audio devices
pactl list sinks
```

**Game Performance Issues**
```bash
# Check if GameMode is active
gamemoded -s

# Verify GPU performance state
nvidia-smi -q -d PERFORMANCE

# Check CPU frequency
watch -n 1 "grep MHz /proc/cpuinfo"
```

## Next Steps After Implementation

1. **Fine-tune Hyprland** configuration based on personal preferences
2. **Create dotfiles repository** for configuration management
3. **Implement OS hooks API** for advanced automation
4. **Develop game-specific** optimization profiles
5. **Setup AI agent workflows** for routine tasks
6. **Configure cloud development** environments
7. **Optimize kernel parameters** for specific workloads

## Notes for AI Agents

When working on this system:
- Always use `paru` instead of `pacman` for package management
- Prefer `--noconfirm` flag for automated installations
- Configuration files are in `~/.config/` and `/etc/llm-laptop/`
- Check `hyprctl` for window manager operations
- Use `systemctl --user` for user services
- Gaming optimizations take priority over other concerns
- System is XFS - no snapshot rollbacks available
- Performance over stability is the guiding principle
