# NixOS System Configuration - Clean system-wide setup
# User configurations managed separately via Home Manager

{ config, pkgs, lib, ... }:

{
  imports = [
    /etc/nixos/hardware-configuration.nix
  ];

  # Keep current working settings
  networking.hostName = "strider";
  time.timeZone = "America/New_York";

  # Keep current user exactly as is
  users.users.chris = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.bash;
  };

  # Configure sudo permissions for nixos-rebuild
  security.sudo.extraRules = [
    {
      users = [ "chris" ];
      commands = [
        {
          command = "/run/current-system/sw/bin/nixos-rebuild";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  # Boot - keep current
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Networking - keep current working setup
  networking.networkmanager.enable = true;
  networking.wireless.enable = false;
  networking.firewall.enable = true;

  # System-level packages (keep minimal - user packages managed by Home Manager)
  environment.systemPackages = with pkgs; [
    # Essential system tools only
    curl
    nodejs
    python3
    
    # Desktop essentials (needed system-wide)
    kitty      # Terminal emulator
    wofi       # Application launcher for Wayland
    
    # Screen locking (system-level services)
    swaylock          # Screen locker for Wayland
    swayidle          # Idle management daemon
    acpi              # ACPI event monitoring for lid detection
    
    # Qt support for Qt applications
    kdePackages.qtwayland       # Qt Wayland support
    kdePackages.kio             # KIO for Dolphin
    kdePackages.kio-extras      # Additional KIO protocols
    kdePackages.polkit-kde-agent-1  # Qt-based polkit agent
    
    # Keyboard remapping
    keyd                        # Keyboard remapping daemon
  ];

  # Locale
  i18n.defaultLocale = "en_US.UTF-8";

  # Services - keep minimal, working ones
  services = {
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
      };
    };
  };

  # Manual keyd systemd service
  systemd.services.keyd-manual = {
    description = "Keyd remapping daemon";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.keyd}/bin/keyd";
      Restart = "always";
      RestartSec = 1;
    };
  };

  # Nix settings
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = (_: true);  # Allow all unfree packages
  };

  # Display manager - greetd with tuigreet
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd Hyprland";
        user = "greeter";
      };
    };
  };

  # Enable X11 services for compatibility
  services.xserver = {
    enable = true;
    xkb.layout = "us";
  };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Minimal audio for Hyprland
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  # Basic graphics
  hardware.graphics.enable = true;

  # XDG portals for Hyprland
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      kdePackages.xdg-desktop-portal-kde  # Qt/KDE portal for Qt apps
    ];
  };
  
  # Polkit for privilege escalation (non-GNOME)
  security.polkit.enable = true;

  # Manual keyd configuration
  environment.etc."keyd/default.conf".text = ''
[ids]
*

[main]
capslock = overload(control, esc)
  '';

  system.stateVersion = "25.05";
}