# Desktop Environment Configuration Module
# Hyprland Wayland compositor with supporting applications

{ config, pkgs, lib, ... }:

{
  # Enable Wayland session support
  services.xserver = {
    enable = true;
    displayManager = {
      gdm = {
        enable = true;
        wayland = true;
      };
    };
    
    # XKB configuration
    xkb = {
      layout = "us";
      variant = "";
    };
  };

  # Hyprland configuration
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    
    # Use latest Hyprland from cachix
    package = pkgs.hyprland;
  };

  # XDG portal for Wayland
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
  };

  # Audio configuration
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    
    # Wireplumber for session management
    wireplumber.enable = true;
  };

  # Bluetooth GUI support
  services.blueman.enable = true;

  # Font configuration for desktop
  fonts = {
    packages = with pkgs; [
      # System fonts
      dejavu_fonts
      liberation_ttf
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      
      # Programming fonts
      fira-code
      fira-code-symbols
      jetbrains-mono
      source-code-pro
      
      # Icon fonts
      font-awesome
      material-design-icons
      
      # Additional fonts for better compatibility
      corefonts  # Microsoft fonts
      ubuntu_font_family
    ];
    
    fontconfig = {
      defaultFonts = {
        serif = [ "DejaVu Serif" "Noto Serif" ];
        sansSerif = [ "DejaVu Sans" "Noto Sans" ];
        monospace = [ "Fira Code" "JetBrains Mono" "DejaVu Sans Mono" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };

  # Desktop applications and tools
  environment.systemPackages = with pkgs; [
    # Wayland utilities
    wl-clipboard      # Clipboard manager for Wayland
    wlr-randr        # Display configuration
    grim             # Screenshot tool
    slurp            # Screen area selection
    swappy           # Screenshot editing
    
    # Terminal emulator
    alacritty        # GPU-accelerated terminal
    
    # Application launcher and bars
    wofi             # Application launcher
    waybar           # Status bar for Wayland
    dunst            # Notification daemon
    
    # File manager
    nautilus         # GNOME file manager
    file-roller      # Archive manager
    
    # Web browsers
    firefox          # Primary browser
    chromium         # Alternative browser for development
    
    # Text editors and IDEs
    neovim           # Enhanced vim
    vscode           # Popular code editor
    
    # Media applications
    vlc              # Media player
    eog              # Image viewer
    evince           # PDF viewer
    
    # System utilities
    pavucontrol      # PulseAudio volume control
    blueman          # Bluetooth manager
    network-manager-applet  # NetworkManager applet
    
    # Productivity applications
    libreoffice      # Office suite
    gimp             # Image editing
    inkscape         # Vector graphics
    
    # Communication
    discord          # Chat application
    thunderbird      # Email client
    
    # Development tools (basic desktop integration)
    dbeaver-bin      # Database GUI
    postman          # API testing
    
    # Gaming support (basic)
    steam            # Gaming platform
    lutris           # Gaming management
    
    # Music production basics
    audacity         # Audio editor
    
    # System information and monitoring
    htop             # System monitor
    neofetch         # System information
    
    # Themes and customization
    adwaita-icon-theme
    gnome.gnome-themes-extra
    gtk-engine-murrine
    
    # QT theming for better integration
    qt5.qtwayland
    qt6.qtwayland
    libsForQt5.qtstyleplugin-kvantum
    
    # Archive support
    p7zip
    unrar
    
    # Additional Wayland tools
    wdisplays        # Display configuration GUI
    wlogout          # Logout menu
    
    # Clipboard history
    cliphist         # Clipboard history for Wayland
    
    # Color picker
    hyprpicker       # Color picker for Hyprland
  ];

  # Polkit authentication agent
  security.polkit.enable = true;
  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "polkit-gnome-authentication-agent-1";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  # Desktop portal configuration
  services.gnome.gnome-keyring.enable = true;
  programs.seahorse.enable = true;

  # Enable dconf for GTK applications
  programs.dconf.enable = true;

  # Thunar file manager with additional functionality
  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [
      thunar-archive-plugin
      thunar-media-tags-plugin
      thunar-volman
    ];
  };

  # Additional desktop services
  services = {
    # Automatic device mounting
    udisks2.enable = true;
    
    # Thumbnail generation
    tumbler.enable = true;
    
    # GVFS for virtual filesystems
    gvfs.enable = true;
    
    # Power profiles daemon for laptop power management
    power-profiles-daemon.enable = true;
    
    # Location services
    geoclue2 = {
      enable = true;
      appConfig.gammastep = {
        isAllowed = true;
        isSystem = false;
      };
    };
  };

  # Gammastep (blue light filter) configuration
  services.redshift = {
    enable = false;  # Disabled in favor of gammastep for Wayland
  };
  
  # Enable flatpak for additional application support
  services.flatpak.enable = true;

  # XDG directories
  environment.sessionVariables = {
    # Wayland specific
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    
    # QT Wayland support
    QT_QPA_PLATFORM = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    
    # SDL Wayland support  
    SDL_VIDEODRIVER = "wayland";
    
    # Java applications on Wayland
    _JAVA_AWT_WM_NONREPARENTING = "1";
    
    # GTK theme
    GTK_THEME = "Adwaita:dark";
    
    # Cursor theme
    XCURSOR_THEME = "Adwaita";
    XCURSOR_SIZE = "24";
  };

  # Hardware acceleration for multimedia
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
    ];
    enable32Bit = true;  # Enable 32-bit support for games and compatibility
  };

  # Gaming optimizations
  programs.gamemode.enable = true;
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  # Enable CUPS for printing
  services.printing = {
    enable = true;
    drivers = with pkgs; [ cups-filters gutenprint ];
  };

  # Scanner support
  hardware.sane = {
    enable = true;
    extraBackends = [ pkgs.sane-airscan ];
  };

  # Desktop environment specific systemd services
  systemd.user.services = {
    # Auto-start Waybar
    waybar = {
      description = "Highly customizable Wayland bar";
      wantedBy = [ "hyprland-session.target" ];
      partOf = [ "hyprland-session.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.waybar}/bin/waybar";
        Restart = "on-failure";
        RestartSec = 1;
      };
    };
  };

  # Systemd target for Hyprland session
  systemd.user.targets.hyprland-session = {
    description = "Hyprland compositor session";
    bindsTo = [ "graphical-session.target" ];
    wants = [ "graphical-session-pre.target" ];
    after = [ "graphical-session-pre.target" ];
  };
}