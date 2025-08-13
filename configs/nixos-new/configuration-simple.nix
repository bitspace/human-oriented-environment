# Simple Working NixOS Configuration - Just Add Hyprland to Current System
# Based on current working configuration with minimal additions

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

  # Keep current packages (from your working system)
  environment.systemPackages = with pkgs; [
    curl
    git  
    htop
    nodejs
    python3
    tree
    
    # Basic desktop applications
    firefox
    kitty      # Terminal emulator
    wofi       # Application launcher for Wayland
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

  # Nix settings
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  nixpkgs.config.allowUnfree = true;

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
      xdg-desktop-portal-gtk
    ];
  };

  system.stateVersion = "25.05";
}