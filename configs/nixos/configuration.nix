# NixOS Configuration for LLM-Orchestrated ThinkPad P16 Gen 2
# Target: High-performance development workstation with AI/ML capabilities
# Generated: 2025-08-12
# Architecture: NixOS + Hyprland + Home Manager

{ config, pkgs, lib, ... }:

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
    ./modules/automation.nix
  ];

  # System metadata for LLM agents
  system.llmWorkstation = {
    enable = true;
    targetUse = [ "development" "ai-ml" "gaming" "music-production" "cloud-dev" ];
    hardware = "lenovo-thinkpad-p16-gen2";
    lastUpdated = "2025-08-12";
    architecture = "nixos-hyprland-home-manager";
  };

  # User configuration
  users.users.chris = {  # Replace with your username
    isNormalUser = true;
    description = "Chris - LLM Orchestration User";
    extraGroups = [ 
      "networkmanager" 
      "wheel" 
      "docker" 
      "audio" 
      "video" 
      "input"
      "storage"
      "optical"
      "scanner"
    ];
    shell = pkgs.zsh;
    
    # SSH keys for remote LLM orchestration
    openssh.authorizedKeys.keys = [
      # Add your SSH public keys here for remote access
    ];
  };

  # Enable home-manager integration
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.chris = import ./home.nix;  # Replace 'chris' with your username
  };

  # NixOS version - DO NOT CHANGE without understanding implications
  system.stateVersion = "24.11";
}