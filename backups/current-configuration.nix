# Backup of current minimal NixOS configuration
# Saved: 2025-08-12

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable flakes and new nix command (required for modern NixOS)
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "strider"; # Define your hostname.
  # Pick only one of the below networking options.
  networking.wireless.enable = false;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users.chris = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ]; # Enable 'sudo' for the user.
    packages = with pkgs; [
      tree
    ];
  };

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
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
  ];

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };

  # Firewall configuration
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 ];

  system.stateVersion = "25.05"; # Did you read the comment?
}