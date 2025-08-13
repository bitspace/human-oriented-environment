# NixOS Configuration for LLM-Orchestrated ThinkPad P16 Gen 2
# Target: High-performance development workstation with AI/ML capabilities
# Hostname: strider
# User: chris
# Generated: 2025-08-12

{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./modules/base.nix
    ./modules/hardware.nix
    ./modules/networking.nix
    ./modules/desktop.nix
    ./modules/development.nix
    ./modules/security.nix
  ];

  # System metadata for LLM agents (stored as comment for reference)
  # Target use: development, ai-ml, gaming, music-production, cloud-dev
  # Hardware: lenovo-thinkpad-p16-gen2
  # Architecture: nixos-hyprland-home-manager
  # Last updated: 2025-08-12

  # Hostname (keep existing)
  networking.hostName = "strider";

  # User configuration (enhanced from current)
  users.users.chris = {
    isNormalUser = true;
    description = "Chris - LLM Orchestration User";
    extraGroups = [ 
      "networkmanager" 
      "wheel" 
      "audio" 
      "video" 
      "input"
      "storage"
      "optical"
      "scanner"
      "lp"
      "docker"
      "libvirtd"
      "postgres"
      "plugdev"
    ];
    shell = pkgs.zsh;
    
    packages = with pkgs; [
      # Keep existing user packages
      tree
      # Add essential user tools
      firefox
      git
      neovim
      alacritty
    ];
  };

  # NixOS version - keep current
  system.stateVersion = "25.05";
}