# Desktop Environment Configuration - Hyprland
# Optimized for LLM orchestration and development workflows

{ config, pkgs, lib, ... }:

{
  # Enable Hyprland Wayland compositor
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    package = pkgs.hyprland;
  };

  # XDG Desktop Portal configuration for screen sharing and file operations
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland  # Hyprland-specific portal
      xdg-desktop-portal-gtk       # GTK file dialogs
    ];
    config.common.default = "*";
  };

  # Display manager - greetd with tuigreet
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --cmd Hyprland";
        user = "greeter";
      };
    };
  };

  # Audio system - PipeWire with professional audio support
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    
    # Professional audio configuration for music production
    config.pipewire = {
      "context.properties" = {
        "default.clock.rate" = 48000;
        "default.clock.quantum" = 1024;
        "default.clock.min-quantum" = 64;
        "default.clock.max-quantum" = 8192;
        "core.daemon" = true;
        "core.name" = "pipewire-0";
      };
    };
    
    config.pipewire-pulse = {
      "pulse.properties" = {
        "pulse.min.req" = "32/48000";        # Minimum request
        "pulse.default.req" = "32/48000";    # Default request 
        "pulse.max.req" = "32/48000";        # Maximum request
        "pulse.min.quantum" = "32/48000";    # Minimum quantum
        "pulse.max.quantum" = "32/48000";    # Maximum quantum
      };
      
      "stream.properties" = {
        "node.latency" = "32/48000";         # Low latency for music production
        "resample.quality" = 1;              # Fast resampling
      };
    };
  };

  # Fonts optimized for HiDPI display (3840x2400)
  fonts = {
    packages = with pkgs; [
      # System fonts
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      liberation_ttf
      
      # Programming fonts
      fira-code
      fira-code-symbols
      jetbrains-mono
      source-code-pro
      cascadia-code
      
      # Nerd Fonts for terminal/editor icons
      (nerdfonts.override { 
        fonts = [ 
          "FiraCode" 
          "JetBrainsMono" 
          "CascadiaCode"
          "SourceCodePro"
          "Hack"
          "UbuntuMono"
        ]; 
      })
      
      # Additional fonts
      inter
      roboto
      open-sans
    ];
    
    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [ "Noto Serif" "Liberation Serif" ];
        sansSerif = [ "Inter" "Noto Sans" "Liberation Sans" ];
        monospace = [ "JetBrains Mono" "Fira Code" "Source Code Pro" ];
        emoji = [ "Noto Color Emoji" ];
      };
      
      hinting = {
        enable = true;
        autohint = true;
        style = "full";
      };
      
      antialias = true;
      subpixel.rgba = "rgb";
    };
  };

  # Essential desktop packages
  environment.systemPackages = with pkgs; [
    # Wayland utilities
    wl-clipboard          # Clipboard manager for Wayland
    wl-color-picker       # Color picker tool
    wlr-randr            # Display configuration tool
    
    # Screenshot and screen recording
    grim                 # Screenshot utility
    slurp                # Area selection tool
    swappy               # Screenshot annotation
    wf-recorder          # Screen recorder
    
    # Application launcher
    wofi                 # Wayland native launcher
    
    # File managers
    nautilus             # GNOME file manager
    nemo                 # Alternative file manager
    
    # Archive managers  
    file-roller          # GNOME archive manager
    
    # Media viewers
    mpv                  # Video player
    imv                  # Image viewer
    
    # PDF viewers
    zathura              # Minimalist PDF viewer
    evince               # GNOME document viewer
    
    # Text editors
    gedit                # Simple text editor
    
    # System utilities
    pavucontrol          # PulseAudio/PipeWire volume control
    blueman              # Bluetooth manager
    networkmanagerapplet # Network manager GUI
    
    # Terminal emulators
    alacritty           # GPU-accelerated terminal
    kitty               # Feature-rich terminal
    
    # Web browsers
    firefox             # Primary browser
    chromium            # Alternative browser for testing
    
    # Communication
    discord             # Voice/text chat
    telegram-desktop    # Messaging
    
    # Development tools GUI
    gitg                # Git GUI
    meld                # File/directory comparison
    
    # System monitoring GUI
    mission-center      # Modern system monitor
    
    # Themes and customization
    papirus-icon-theme  # Icon theme
    adwaita-icon-theme  # Fallback icons
    
    # Wayland-specific tools
    wev                 # Event viewer (debugging)
    wlsunset            # Blue light filter
    kanshi              # Display configuration daemon
  ];

  # Thunar file manager configuration
  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [
      thunar-archive-plugin
      thunar-volman
    ];
  };

  # Enable GVfs for mounting drives in file managers
  services.gvfs.enable = true;

  # Enable CUPS for printing
  services.printing.enable = true;

  # Enable location service for automatic timezone/theme switching
  location.provider = "geoclue2";
  services.geoclue2.enable = true;

  # Automatic login for development convenience (optional - comment out for security)
  # services.greetd.settings.initial_session = {
  #   command = "Hyprland";
  #   user = "chris";  # Replace with your username
  # };

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

  # Enable desktop integration features
  services = {
    # D-Bus desktop integration
    dbus = {
      enable = true;
      packages = with pkgs; [ dconf ];
    };
    
    # Power management
    upower.enable = true;
    
    # Thumbnail generation
    tumbler.enable = true;
  };

  # GTK themes and configuration
  environment.etc = {
    "gtk-2.0/gtkrc".text = ''
      gtk-theme-name = "Adwaita-dark"
      gtk-icon-theme-name = "Papirus-Dark"
      gtk-font-name = "Inter 11"
      gtk-cursor-theme-name = "Adwaita"
      gtk-toolbar-style = GTK_TOOLBAR_BOTH_HORIZ
      gtk-toolbar-icon-size = GTK_ICON_SIZE_LARGE_TOOLBAR
      gtk-button-images = 1
      gtk-menu-images = 1
      gtk-enable-event-sounds = 0
      gtk-enable-input-feedback-sounds = 0
      gtk-xft-antialias = 1
      gtk-xft-hinting = 1
      gtk-xft-hintstyle = "hintslight"
      gtk-xft-rgba = "rgb"
    '';
    
    "gtk-3.0/settings.ini".text = ''
      [Settings]
      gtk-theme-name = Adwaita-dark
      gtk-icon-theme-name = Papirus-Dark  
      gtk-font-name = Inter 11
      gtk-cursor-theme-name = Adwaita
      gtk-toolbar-style = GTK_TOOLBAR_BOTH_HORIZ
      gtk-toolbar-icon-size = GTK_ICON_SIZE_LARGE_TOOLBAR
      gtk-button-images = 1
      gtk-menu-images = 1
      gtk-enable-event-sounds = 0
      gtk-enable-input-feedback-sounds = 0
      gtk-xft-antialias = 1
      gtk-xft-hinting = 1
      gtk-xft-hintstyle = hintslight
      gtk-xft-rgba = rgb
      gtk-application-prefer-dark-theme = 1
    '';
  };

  # Qt theming
  qt = {
    enable = true;
    platformTheme = "gtk2";
    style = "gtk2";
  };
}