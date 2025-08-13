# Base System Configuration
# Core NixOS settings optimized for LLM orchestration workstation

{ config, pkgs, lib, ... }:

{
  # Boot configuration (enhanced from current)
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 10;  # Keep 10 boot entries for rollback
        editor = false;           # Security: disable boot entry editing
      };
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
      timeout = 3;
    };
    
    # Keep latest kernel (current setting)
    kernelPackages = pkgs.linuxPackages_latest;
    
    # Enhanced kernel parameters for ThinkPad P16 Gen 2
    kernelParams = [
      "intel_iommu=on"                    # Enable Intel IOMMU for virtualization
      "i915.enable_guc=3"                # Enable GuC and HuC for Intel graphics
      "processor.max_cstate=1"            # Optimize for performance
      "intel_idle.max_cstate=1"           # Reduce CPU idle latency
      "quiet"                             # Clean boot output
      "loglevel=3"                        # Reduce kernel log verbosity
    ];
    
    # Kernel modules for development and virtualization
    kernelModules = [ "kvm-intel" ];
    
    # Plymouth for graphical boot
    plymouth = {
      enable = true;
      theme = "breeze";
    };
  };

  # Locale and internationalization (keep current settings)
  time.timeZone = "America/New_York";
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
  };

  # Console configuration
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;  # Use xkb config for console keymap
  };

  # Nix configuration (enhanced from current)
  nix = {
    settings = {
      # Keep current flakes setting
      experimental-features = [ "nix-command" "flakes" ];
      
      # Optimize store
      auto-optimise-store = true;
      
      # Build settings optimized for 188GB RAM and i9-13980HX
      max-jobs = "auto";
      cores = 0;  # Use all available cores
      
      # Substituters for faster downloads
      substituters = [
        "https://cache.nixos.org/"
        "https://hyprland.cachix.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      
      # Allow wheel group to use nix commands
      trusted-users = [ "root" "@wheel" ];
    };
    
    # Automatic garbage collection
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    
    # Optimize store automatically
    optimise = {
      automatic = true;
      dates = [ "03:45" ];  # Run at 3:45 AM daily
    };
  };

  # Package configuration
  nixpkgs = {
    config = {
      allowUnfree = true;  # Required for many development tools
      allowBroken = false;
      allowInsecure = false;
    };
  };

  # Enhanced system packages (includes current + additions)
  environment.systemPackages = with pkgs; [
    # Keep current essential system tools
    curl
    git
    htop
    nodejs
    nodePackages.npm
    python3
    python3Packages.pip
    unzip
    vim
    wget
    which
    
    # Add new essential tools
    tree  # Keep user's current package
    rsync
    p7zip
    zip
    
    # Text editors for emergency editing
    nano
    
    # System monitoring
    btop
    iotop
    lsof
    strace
    
    # Network tools
    dig
    nmap
    tcpdump
    
    # File utilities
    file
    fd
    ripgrep
    
    # Build tools
    gcc
    gnumake
    pkg-config
    
    # Version control
    git-lfs
    
    # Archive tools
    gnutar
    gzip
    bzip2
    xz
  ];

  # Shell configuration
  programs = {
    bash.enable = true;  # Use bash as default shell
    
    # Command-not-found for better UX
    command-not-found.enable = false;  # We'll use nix-index instead
    nix-index.enable = true;
  };

  # Environment variables for LLM tools
  environment.variables = {
    # Editor preference
    EDITOR = "vim";  # Keep safe default, can be overridden by user
    VISUAL = "vim";
    
    # Nix-specific
    NIXOS_OZONE_WL = "1";  # Enable Wayland for Electron apps
    
    # Development
    BROWSER = "firefox";
    TERMINAL = "alacritty";
    
    # XDG compliance
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_CACHE_HOME = "$HOME/.cache";
  };

  # Session variables
  environment.sessionVariables = {
    # Wayland support
    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM = "wayland";
    SDL_VIDEODRIVER = "wayland";
    _JAVA_AWT_WM_NONREPARENTING = "1";
    
    # Development paths
    PATH = [
      "$HOME/.local/bin"
      "$HOME/bin"
    ];
  };

  # Memory and performance optimizations for 188GB system
  boot.kernel.sysctl = {
    # Virtual memory settings
    "vm.swappiness" = 10;              # Prefer RAM over swap
    "vm.vfs_cache_pressure" = 50;      # Keep directory/inode cache
    "vm.dirty_ratio" = 15;             # Start async writes at 15% RAM
    "vm.dirty_background_ratio" = 5;   # Background writes at 5% RAM
    "vm.max_map_count" = 2147483642;   # For gaming and development tools
    
    # Network optimizations
    "net.core.rmem_max" = 134217728;   # 128MB receive buffer
    "net.core.wmem_max" = 134217728;   # 128MB send buffer
    
    # File system optimizations
    "fs.file-max" = 2097152;           # Maximum file descriptors
    "fs.inotify.max_user_watches" = 1048576;  # For development tools
    
    # Security
    "kernel.dmesg_restrict" = 1;
    "net.ipv4.conf.default.log_martians" = 1;
    "net.ipv4.conf.all.log_martians" = 1;
  };
}