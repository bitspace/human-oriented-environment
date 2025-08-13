# Phase 3: System Architecture Design - NixOS + Hyprland

**Design Date:** August 12, 2025  
**Target System:** Lenovo ThinkPad P16 Gen 2 (i9-13980HX, 192GB DDR5, 4TB SSD, Intel UHD Graphics)  
**Architecture:** NixOS (unstable) + Hyprland + Home Manager  
**Primary Goal:** LLM-Orchestrated Development Workstation  

## I. Base System Architecture

### Core Design Principles
1. **Declarative Configuration**: Everything defined in version-controlled Nix expressions
2. **LLM-Parseable Structure**: Consistent, well-documented configuration format
3. **Atomic Operations**: All system changes reversible and trackable
4. **Modular Composition**: Separate concerns into manageable modules
5. **Development-First**: Optimized for polyglot software development workflows

### System Configuration Structure

```
/etc/nixos/
├── configuration.nix           # Main system configuration
├── hardware-configuration.nix  # Auto-generated hardware config
├── modules/
│   ├── base.nix               # Core system settings
│   ├── hardware.nix           # Hardware-specific optimizations
│   ├── networking.nix         # Network configuration
│   ├── security.nix           # Security policies and hardening
│   ├── desktop.nix            # Desktop environment (Hyprland)
│   ├── development.nix        # Development tools and environments
│   ├── gaming.nix             # Gaming and multimedia
│   ├── ai-ml.nix              # AI/ML infrastructure
│   └── services.nix           # System services configuration
├── overlays/
│   ├── custom-packages.nix    # Custom package definitions
│   └── overrides.nix          # Package overrides and patches
└── secrets/
    └── secrets.nix            # Encrypted secrets management
```

### User Configuration Structure (Home Manager)

```
~/.config/home-manager/
├── home.nix                   # Main home configuration
├── modules/
│   ├── hyprland.nix          # Hyprland configuration
│   ├── shell.nix             # Shell and CLI tools
│   ├── development.nix       # User development tools
│   ├── applications.nix      # GUI applications
│   └── dotfiles/
│       ├── git.nix           # Git configuration
│       ├── neovim.nix        # Editor configuration
│       └── terminals.nix     # Terminal configurations
└── secrets/
    └── keys.nix              # User secrets and keys
```

## II. Core System Configuration

### Main Configuration.nix Template

```nix
# /etc/nixos/configuration.nix
{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./modules/base.nix
    ./modules/hardware.nix
    ./modules/networking.nix
    ./modules/security.nix
    ./modules/desktop.nix
    ./modules/development.nix
    ./modules/gaming.nix
    ./modules/ai-ml.nix
    ./modules/services.nix
  ];

  # System metadata for LLM agents
  system.llmWorkstation = {
    enable = true;
    targetUse = [ "development" "ai-ml" "gaming" "music-production" ];
    hardware = "lenovo-thinkpad-p16-gen2";
    lastUpdated = "2025-08-12";
  };

  # NixOS version
  system.stateVersion = "24.11";
}
```

### Base System Module

```nix
# /etc/nixos/modules/base.nix
{ config, pkgs, ... }:

{
  # Boot configuration optimized for NVMe SSD
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      timeout = 3;
    };
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [
      "intel_iommu=on"           # Enable Intel IOMMU
      "i915.enable_guc=3"        # Enable GuC and HuC for Intel graphics
      "processor.max_cstate=1"   # Optimize for performance
      "intel_idle.max_cstate=1"  # Reduce latency
    ];
  };

  # Locale and internationalization
  time.timeZone = "America/New_York";  # Adjust as needed
  i18n.defaultLocale = "en_US.UTF-8";
  
  # Console configuration
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Nix configuration for optimal performance
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      max-jobs = "auto";
      cores = 0;  # Use all available cores
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  # Allow unfree packages (needed for some development tools)
  nixpkgs.config.allowUnfree = true;
}
```

### Hardware Optimization Module

```nix
# /etc/nixos/modules/hardware.nix
{ config, pkgs, ... }:

{
  # Hardware-specific optimizations for ThinkPad P16 Gen 2
  hardware = {
    # Enable Intel graphics with optimal settings
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [
        intel-media-driver  # VAAPI driver
        vaapiIntel         # Legacy VAAPI driver
        vaapiVdpau         # VDPAU driver
        libvdpau-va-gl     # VDPAU-VA-GL driver
      ];
    };

    # CPU frequency scaling
    cpu.intel.updateMicrocode = true;
    
    # Audio configuration with PipeWire
    pulseaudio.enable = false;
    
    # Bluetooth support
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };

    # Firmware updates
    enableRedistributableFirmware = true;
  };

  # Power management optimizations
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "performance";  # For development workloads
  };

  # Thermal management
  services.thermald.enable = true;
  
  # SSD optimization
  services.fstrim.enable = true;

  # Memory optimization for 192GB system
  boot.kernel.sysctl = {
    "vm.swappiness" = 10;           # Prefer RAM over swap
    "vm.vfs_cache_pressure" = 50;   # Optimize VFS cache
    "vm.dirty_ratio" = 15;          # Async write threshold
    "vm.dirty_background_ratio" = 5; # Background write threshold
  };
}
```

## III. Hyprland Desktop Environment

### Desktop Module Integration

```nix
# /etc/nixos/modules/desktop.nix
{ config, pkgs, ... }:

{
  # Enable Wayland and Hyprland
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Display manager configuration
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd Hyprland";
        user = "greeter";
      };
    };
  };

  # XDG portal for screen sharing and file operations
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
  };

  # Audio system with PipeWire
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    
    # Professional audio configuration
    config.pipewire = {
      "context.properties" = {
        "default.clock.rate" = 48000;
        "default.clock.quantum" = 1024;
        "default.clock.min-quantum" = 64;
        "default.clock.max-quantum" = 8192;
      };
    };
  };

  # Fonts for HiDPI display
  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      liberation_ttf
      fira-code
      fira-code-symbols
      jetbrains-mono
      source-code-pro
      (nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono" "SourceCodePro" ]; })
    ];
    
    fontconfig = {
      defaultFonts = {
        serif = [ "Noto Serif" ];
        sansSerif = [ "Noto Sans" ];
        monospace = [ "JetBrains Mono" ];
      };
      hinting.autohint = true;
      antialias = true;
    };
  };

  # Essential desktop packages
  environment.systemPackages = with pkgs; [
    # Wayland utilities
    wl-clipboard
    wl-color-picker
    wlr-randr
    
    # Screenshot and screen recording
    grim
    slurp
    swappy
    wf-recorder
    
    # File manager
    nautilus
    
    # Media
    mpv
    imv
    
    # System monitoring
    htop
    btop
    
    # Network tools
    networkmanagerapplet
  ];
}
```

### Home Manager Hyprland Configuration

```nix
# ~/.config/home-manager/modules/hyprland.nix
{ config, pkgs, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      # Monitor configuration for 4K display
      monitor = [
        "eDP-1,3840x2400@60,0x0,1.5"  # 150% scaling for 16" 4K
        ",preferred,auto,1"            # External monitors auto-detect
      ];

      # Input configuration
      input = {
        kb_layout = "us";
        follow_mouse = 1;
        natural_scroll = true;
        touchpad = {
          natural_scroll = true;
          disable_while_typing = true;
          tap-to-click = true;
        };
        sensitivity = 0;
      };

      # General configuration
      general = {
        gaps_in = 5;
        gaps_out = 20;
        border_size = 2;
        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";
        layout = "dwindle";
        allow_tearing = false;
      };

      # Visual effects optimized for Intel graphics
      decoration = {
        rounding = 10;
        
        blur = {
          enabled = true;
          size = 3;
          passes = 1;
          vibrancy = 0.1696;
        };
        
        drop_shadow = true;
        shadow_range = 4;
        shadow_render_power = 3;
        "col.shadow" = "rgba(1a1a1aee)";
      };

      # Animations for smooth experience
      animations = {
        enabled = true;
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "borderangle, 1, 8, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };

      # Dwindle layout settings
      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      # Window rules for development applications
      windowrulev2 = [
        "float,class:^(pavucontrol)$"
        "float,class:^(nm-applet)$"
        "float,class:^(blueman-manager)$"
        "opacity 0.90,class:^(Alacritty)$"
        "opacity 0.90,class:^(kitty)$"
        "workspace 2,class:^(firefox)$"
        "workspace 3,class:^(code)$"
        "workspace 9,class:^(discord)$"
        "workspace 10,class:^(steam)$"
      ];

      # Keybindings optimized for development workflow
      bind = [
        # Basic window management
        "SUPER, Q, exec, alacritty"
        "SUPER, C, killactive,"
        "SUPER, M, exit,"
        "SUPER, E, exec, nautilus"
        "SUPER, V, togglefloating,"
        "SUPER, R, exec, wofi --show drun"
        "SUPER, P, pseudo,"
        "SUPER, J, togglesplit,"

        # Move focus with vim keys
        "SUPER, h, movefocus, l"
        "SUPER, l, movefocus, r"
        "SUPER, k, movefocus, u"
        "SUPER, j, movefocus, d"

        # Move windows with vim keys
        "SUPER SHIFT, h, movewindow, l"
        "SUPER SHIFT, l, movewindow, r"
        "SUPER SHIFT, k, movewindow, u"
        "SUPER SHIFT, j, movewindow, d"

        # Workspace navigation
        "SUPER, 1, workspace, 1"
        "SUPER, 2, workspace, 2"
        "SUPER, 3, workspace, 3"
        "SUPER, 4, workspace, 4"
        "SUPER, 5, workspace, 5"
        "SUPER, 6, workspace, 6"
        "SUPER, 7, workspace, 7"
        "SUPER, 8, workspace, 8"
        "SUPER, 9, workspace, 9"
        "SUPER, 0, workspace, 10"

        # Move windows to workspaces
        "SUPER SHIFT, 1, movetoworkspace, 1"
        "SUPER SHIFT, 2, movetoworkspace, 2"
        "SUPER SHIFT, 3, movetoworkspace, 3"
        "SUPER SHIFT, 4, movetoworkspace, 4"
        "SUPER SHIFT, 5, movetoworkspace, 5"
        "SUPER SHIFT, 6, movetoworkspace, 6"
        "SUPER SHIFT, 7, movetoworkspace, 7"
        "SUPER SHIFT, 8, movetoworkspace, 8"
        "SUPER SHIFT, 9, movetoworkspace, 9"
        "SUPER SHIFT, 0, movetoworkspace, 10"

        # Screenshot and screen recording
        "SUPER SHIFT, S, exec, grim -g \"$(slurp)\" - | swappy -f -"
        "SUPER, Print, exec, grim ~/Pictures/Screenshots/$(date +'%Y%m%d_%H%M%S').png"
        
        # Media keys
        ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioPause, exec, playerctl play-pause"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPrev, exec, playerctl previous"
        
        # Brightness control
        ", XF86MonBrightnessUp, exec, brightnessctl set 10%+"
        ", XF86MonBrightnessDown, exec, brightnessctl set 10%-"
      ];

      # Mouse bindings
      bindm = [
        "SUPER, mouse:272, movewindow"
        "SUPER, mouse:273, resizewindow"
      ];
    };
  };

  # Supporting applications for Hyprland
  home.packages = with pkgs; [
    # Application launcher
    wofi
    
    # Status bar
    waybar
    
    # Screen lock
    swaylock-effects
    
    # Idle management
    swayidle
    
    # Notification daemon
    mako
    
    # Wallpaper manager
    swww
    
    # Color picker
    wl-color-picker
    
    # Clipboard manager
    cliphist
    
    # Terminal emulator
    alacritty
    
    # System monitoring
    brightnessctl
    playerctl
    
    # Image viewer
    imv
  ];
}
```

## IV. LLM Orchestration Integration Points

### Automation Framework Design

```nix
# /etc/nixos/modules/automation.nix
{ config, pkgs, ... }:

{
  # LLM orchestration infrastructure
  environment.systemPackages = with pkgs; [
    # Core automation tools
    git
    jq
    yq
    
    # Configuration parsing
    nix-prefetch-git
    nix-tree
    
    # System inspection
    nix-info
    nixos-rebuild
    home-manager
  ];

  # LLM agent integration points
  systemd.services.llm-config-watcher = {
    description = "Watch for LLM configuration changes";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.git}/bin/git -C /etc/nixos add -A && ${pkgs.git}/bin/git -C /etc/nixos commit -m 'Auto-commit LLM changes'";
      User = "root";
    };
  };

  # Configuration validation service
  systemd.services.config-validator = {
    description = "Validate NixOS configuration before rebuild";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.nixos-rebuild}/bin/nixos-rebuild dry-build";
      User = "root";
    };
  };
}
```

### LLM-Parseable Configuration Structure

```yaml
# ~/.config/llm-workstation/config.yaml (LLM agent reference)
system:
  type: "nixos"
  version: "24.11"
  last_update: "2025-08-12"
  
hardware:
  model: "lenovo-thinkpad-p16-gen2"
  cpu: "intel-i9-13980hx"
  memory: "192gb-ddr5"
  storage: "4tb-nvme"
  graphics: "intel-uhd"

desktop:
  compositor: "hyprland"
  manager: "home-manager"
  scaling: 1.5
  
configuration:
  system_config: "/etc/nixos/configuration.nix"
  home_config: "~/.config/home-manager/home.nix"
  modules_path: "/etc/nixos/modules/"
  
automation:
  git_tracking: true
  auto_commit: true
  validation: true
  rollback_enabled: true
```

## V. Development Environment Architecture

### Language-Specific Isolation Strategy

```nix
# /etc/nixos/modules/development.nix
{ config, pkgs, ... }:

{
  # Development shells and environments
  environment.systemPackages = with pkgs; [
    # Version control
    git
    git-lfs
    
    # Container technologies
    docker
    docker-compose
    podman
    podman-compose
    
    # Build tools
    gnumake
    cmake
    ninja
    
    # Language servers and development tools
    tree-sitter
    ripgrep
    fd
    
    # Network development
    postman
    wireshark
    
    # Database tools
    postgresql
    sqlite
    
    # Text editors
    neovim
    emacs
    
    # IDEs
    vscode
  ];

  # Docker configuration
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    autoPrune.enable = true;
  };

  # Container optimizations
  virtualisation.containers = {
    enable = true;
    storage.settings = {
      storage = {
        driver = "overlay";
        runroot = "/run/containers/storage";
        graphroot = "/var/lib/containers/storage";
      };
    };
  };
}
```

### Per-Project Development Shells

```nix
# Development shell templates for LLM agents to customize

# Python development shell
# shell.nix template
{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    python311
    python311Packages.pip
    python311Packages.virtualenv
    python311Packages.poetry
    
    # AI/ML frameworks
    python311Packages.torch
    python311Packages.tensorflow
    python311Packages.jupyter
    python311Packages.numpy
    python311Packages.pandas
    python311Packages.scikit-learn
    
    # Development tools
    python311Packages.black
    python311Packages.flake8
    python311Packages.mypy
    python311Packages.pytest
  ];
  
  shellHook = ''
    echo "Python development environment activated"
    echo "Python version: $(python --version)"
    
    # Create virtual environment if it doesn't exist
    if [ ! -d ".venv" ]; then
      python -m venv .venv
      echo "Created virtual environment at .venv"
    fi
    
    source .venv/bin/activate
  '';
}
```

## VI. Gaming and Multimedia Configuration

### Gaming Infrastructure

```nix
# /etc/nixos/modules/gaming.nix
{ config, pkgs, ... }:

{
  # Steam configuration
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    
    # Proton GE support
    extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];
  };

  # GameMode for performance optimization
  programs.gamemode.enable = true;

  # Gaming packages
  environment.systemPackages = with pkgs; [
    # Game launchers
    lutris
    heroic
    
    # Game development
    godot_4
    blender
    
    # Wine and compatibility
    wine
    winetricks
    bottles
    
    # Game utilities
    mangohud
    goverlay
  ];

  # Optimize for gaming performance
  boot.kernel.sysctl = {
    "kernel.sched_autogroup_enabled" = 0;
    "vm.max_map_count" = 2147483642;
  };
}
```

### Audio Production Setup

```nix
# Audio production configuration
services.pipewire.config.pipewire-pulse = {
  "pulse.properties" = {
    "pulse.min.req" = "32/48000";
    "pulse.default.req" = "32/48000";
    "pulse.max.req" = "32/48000";
    "pulse.min.quantum" = "32/48000";
    "pulse.max.quantum" = "32/48000";
  };
  
  "stream.properties" = {
    "node.latency" = "32/48000";
    "resample.quality" = 1;
  };
};

# Music production packages
environment.systemPackages = with pkgs; [
  # Digital Audio Workstations
  ardour
  qtractor
  
  # Audio editors
  audacity
  
  # Virtual instruments
  helm
  surge-XT
  
  # Audio utilities
  jack2
  qjackctl
  carla
  
  # MIDI tools
  qsynth
  fluidsynth
  
  # Audio plugins
  lsp-plugins
  calf
];
```

## VII. Next Phase Preparation

### Configuration Management Strategy

1. **Git Repository Structure**
   - System configurations tracked in `/etc/nixos/.git`
   - Home configurations tracked in `~/.config/home-manager/.git`
   - LLM agents can safely commit configuration changes

2. **Atomic Deployment Process**
   - `nixos-rebuild switch` for system changes
   - `home-manager switch` for user changes
   - Automatic rollback on failure

3. **LLM Integration Points**
   - Structured configuration files
   - JSON/YAML metadata for agent parsing
   - Shell hooks for automation scripts

4. **Testing and Validation**
   - `nixos-rebuild dry-build` for validation
   - Configuration diff tools
   - Automated backup before changes

<function_calls>
<invoke name="TodoWrite">
<parameter name="todos">[{"id": "phase3-design-base-architecture", "content": "Design NixOS base system architecture and configuration structure", "status": "completed"}, {"id": "phase3-hyprland-integration", "content": "Design Hyprland integration with Home Manager and system config", "status": "completed"}, {"id": "phase3-llm-orchestration-hooks", "content": "Design LLM orchestration integration points and automation framework", "status": "completed"}, {"id": "phase3-development-environments", "content": "Design isolated development environments for multiple languages", "status": "completed"}, {"id": "phase3-aiml-infrastructure", "content": "Design AI/ML infrastructure with model storage and GPU optimization", "status": "pending"}, {"id": "phase3-gaming-multimedia", "content": "Design gaming and music production configuration", "status": "completed"}, {"id": "phase3-directory-structure", "content": "Design LLM-optimized directory structure and configuration organization", "status": "completed"}, {"id": "phase3-automation-framework", "content": "Design automation framework and LLM integration architecture", "status": "completed"}]