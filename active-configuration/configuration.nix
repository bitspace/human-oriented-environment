# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable flakes and new nix command
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Use latest kernel with AMD and NVIDIA optimizations
  boot.kernelPackages = pkgs.linuxPackages_latest;
  
  # Kernel parameters for AMD Ryzen 9 5900HX and NVIDIA RTX 3060
  boot.kernelParams = [
    "nvidia-drm.modeset=1"    # Enable NVIDIA modesetting (required for Wayland/Hyprland)
    "amd_pstate=passive"      # AMD CPU scaling optimization
    "amdgpu.si_support=1"     # AMD GPU support
    "amdgpu.cik_support=1"    # AMD GPU support
  ];

  # NVIDIA kernel modules
  boot.extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];

  networking.hostName = "gimli"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Hardware Configuration
  
  # NVIDIA Configuration for RTX 3060
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    nvidiaSettings = true;
    open = false;  # Use proprietary drivers for better compatibility
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    powerManagement.enable = true;
    
    # PRIME configuration for hybrid graphics (AMD Vega 8 + NVIDIA RTX 3060)
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      # Actual bus IDs from lspci
      amdgpuBusId = "PCI:5:0:0";   # AMD Radeon Vega (Cezanne)
      nvidiaBusId = "PCI:1:0:0";   # NVIDIA RTX 3060 Mobile
    };
  };

  # OpenGL/Vulkan support for both GPUs
  hardware.graphics = {
    enable = true;
    
    enable32Bit = true;  # For 32-bit gaming support
    
    extraPackages = with pkgs; [
      amdvlk
      libvdpau-va-gl
      nvidia-vaapi-driver
      vaapiVdpau
    ];
    
    extraPackages32 = with pkgs.pkgsi686Linux; [
      amdvlk
      libvdpau-va-gl
      nvidia-vaapi-driver
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  # Hyprland Configuration
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Display Manager for Hyprland
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd Hyprland";
        user = "greeter";
      };
    };
  };

  # NVIDIA-specific environment variables for Hyprland/Wayland
  environment.sessionVariables = {
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    __NV_PRIME_RENDER_OFFLOAD = "1";
    __VK_LAYER_NV_optimus = "NVIDIA_only";
    GBM_BACKEND = "nvidia-drm";
    LIBVA_DRIVER_NAME = "nvidia";
    NIXOS_OZONE_WL = "1";
    WLR_NO_HARDWARE_CURSORS = "1";  # Required for NVIDIA
    XDG_SESSION_TYPE = "wayland";
  };

  # Audio Configuration - PipeWire (modern, required for Wayland)
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Configure keymap in X11 (for Xwayland compatibility)
  services.xserver = {
    enable = true;  # Needed for Xwayland
    xkb.layout = "us";
  };

  # Enable touchpad support
  services.libinput.enable = true;

  # Bluetooth Configuration
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  # Gaming Configuration - Phase 3
  
  # Steam Configuration
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    gamescopeSession.enable = true;
  };

  # GameMode for performance optimizations
  programs.gamemode.enable = true;

  # Development Services - Phase 4
  virtualisation.docker.enable = true;



  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users.chris = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" "gamemode" "docker" ];
    packages = with pkgs; [];
  };

  # Enable sudo for wheel group
  security.sudo.wheelNeedsPassword = true; # Re-enable password for sudo (required for production)

  # programs.firefox.enable = true;
  
  # Enable Flatpak for additional software like VSCode Insiders
  services.flatpak.enable = true;

  # List packages installed in system profile.
  # Don't restrict licenses. That's lame ideology.
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    alacritty
    cabal-install
    cargo
    cudaPackages.cudnn
    cudatoolkit
    curl
    docker
    docker-compose
    gamemode
    gamescope
    gcc
    ghc
    gh
    git
    gnupg
    go
    google-chrome
    grim
    htop
    kitty
    lshw
    lutris
    mako
    mangohud
    neovim
    networkmanagerapplet
    bluez
    bluez-tools
    blueman
    nodejs
    nodePackages.npm
    nvitop
    ollama
    openjdk
    pciutils
    protonup-qt
    python3
    python3Packages.numpy
    python3Packages.pandas
    python3Packages.pip
    python3Packages.pytorch
    python3Packages.scikit-learn
    radeontop
    rustc
    slurp
    tmux
    unzip
    usbutils
    vim
    vscode
    waybar
    wget
    wine
    winetricks
    which
    wl-clipboard
    wofi
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };

  # Open ports in the firewall.
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 ];

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # Automatic system updates/upgrades
  system.autoUpgrade = {
    enable = true;
    dates = "04:00";           # Run at 4 AM daily
    allowReboot = false;       # Don't auto-reboot to avoid interrupting work
    channel = "https://channels.nixos.org/nixos-unstable";
    flake = null;              # Use channel-based updates
    randomizedDelaySec = "45min"; # Random delay to avoid server load
  };
  
  # Automatic garbage collection to free disk space
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
  
  # Optimize nix store periodically
  nix.optimise = {
    automatic = true;
    dates = [ "03:45" ];       # Run just before auto-upgrade
  };

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05"; # Did you read the comment?

}
