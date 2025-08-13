# Minimal NixOS Configuration for LLM-Orchestrated Workstation
# Start with basic desktop, then add features incrementally

{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Basic system settings
  networking.hostName = "strider";
  time.timeZone = "America/New_York";

  # User configuration
  users.users.chris = {
    isNormalUser = true;
    description = "Chris - LLM Orchestration User";
    extraGroups = [ "networkmanager" "wheel" "audio" "video" ];
    shell = pkgs.bash;
    packages = with pkgs; [ tree firefox ];
  };

  # Boot configuration
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_latest;
  };

  # Networking
  networking = {
    networkmanager.enable = true;
    wireless.enable = false;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
    };
  };

  # Locale settings
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };

  # Services
  services = {
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
      };
    };
    
    xserver = {
      enable = true;
      displayManager.gdm.enable = true;
      xkb = {
        layout = "us";
        variant = "";
      };
    };
  };

  # Basic Hyprland setup
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Audio
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Graphics
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Essential packages
  environment.systemPackages = with pkgs; [
    # Basic system tools
    curl git htop nodejs python3 vim wget which tree
    
    # Wayland essentials
    wl-clipboard grim slurp
    
    # Terminal and basic apps
    alacritty wofi waybar
    
    # Development basics
    gcc gnumake vscode
    
    # Network tools
    dig nmap
  ];

  # Nix configuration
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  # Package config
  nixpkgs.config = {
    allowUnfree = true;
    allowBroken = false;
    allowInsecure = false;
  };

  # Shell - bash is enabled by default in NixOS

  # XDG portals
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
  };

  # System version
  system.stateVersion = "25.05";
}