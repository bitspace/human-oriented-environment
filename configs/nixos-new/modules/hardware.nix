# Hardware Configuration Module
# ThinkPad P16 Gen 2 specific optimizations

{ config, pkgs, lib, ... }:

{
  # Hardware-specific optimizations for ThinkPad P16 Gen 2
  hardware = {
    # Enable Intel graphics with optimal settings  
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        intel-media-driver  # VAAPI driver for hardware acceleration
        vaapiIntel         # Legacy VAAPI driver
        vaapiVdpau         # VDPAU driver
        libvdpau-va-gl     # VDPAU-VA-GL driver
      ];
    };

    # CPU optimization
    cpu.intel.updateMicrocode = true;
    
    # Enable firmware updates
    enableRedistributableFirmware = true;
    
    # Bluetooth support (ThinkPad P16 Gen 2 has Bluetooth 5.3)
    bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
          Experimental = true;  # Enable experimental features
        };
      };
    };
  };

  # Power management optimizations for development workstation
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "performance";  # Optimize for development workloads
    powertop.enable = true;           # Power optimization tool
  };

  # Thermal management for i9-13980HX
  services.thermald.enable = true;
  
  # SSD optimization for 4TB NVMe
  services.fstrim.enable = true;
  
  # TLP for advanced power management (optional, can conflict with powertop)
  # services.tlp = {
  #   enable = true;
  #   settings = {
  #     CPU_SCALING_GOVERNOR_ON_AC = "performance";
  #     CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
  #     CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
  #     CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
  #   };
  # };

  # Support for various filesystems that might be needed
  boot.supportedFilesystems = [ "xfs" "ntfs" "exfat" "btrfs" ];

  # Enable udev rules for hardware devices
  services.udev = {
    enable = true;
    extraRules = ''
      # Allow users in input group to access input devices
      KERNEL=="event*", GROUP="input", MODE="0664"
      
      # Allow users in video group to control brightness
      ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="intel_backlight", GROUP="video", MODE="0664"
      
      # USB device rules for development devices
      SUBSYSTEM=="usb", ATTR{idVendor}=="*", ATTR{idProduct}=="*", GROUP="plugdev", MODE="0664"
    '';
  };

  # Additional hardware support packages
  environment.systemPackages = with pkgs; [
    # Hardware monitoring
    lm_sensors
    psensor
    
    # Power management tools
    powertop
    acpi
    
    # Disk utilities
    smartmontools
    hdparm
    
    # USB utilities
    usbutils
    
    # System information
    dmidecode
    lshw
    hwinfo
    
    # Performance monitoring
    iotop
    nethogs
    
    # Bluetooth tools
    bluez
    bluez-tools
    
    # Intel GPU tools
    intel-gpu-tools
  ];

  # Load necessary kernel modules
  boot.kernelModules = [
    "kvm-intel"      # Virtualization support
    "acpi_call"      # ACPI support
    "coretemp"       # CPU temperature monitoring
  ];

  # Kernel parameters for hardware optimization
  boot.kernelParams = [
    # Intel graphics optimizations
    "i915.enable_guc=3"              # Enable GuC and HuC
    "i915.enable_fbc=1"              # Enable frame buffer compression
    "i915.fastboot=1"                # Fast boot for Intel graphics
    
    # Power management
    "intel_pstate=active"            # Use Intel P-state driver
    
    # Memory management for large RAM
    "transparent_hugepage=always"    # Enable transparent huge pages
  ];

  # Services for hardware support
  services = {
    # Enable CUPS for printing support
    printing.enable = true;
    
    # Bluetooth service
    blueman.enable = true;
    
    # Location services (for timezone/brightness)
    geoclue2.enable = true;
    
    # Automatic device mounting
    udisks2.enable = true;
    
    # Hardware event handling
    acpid = {
      enable = true;
      handlers = {
        # Power button handler
        power = {
          event = "button/power.*";
          action = ''
            # Graceful shutdown on power button press
            /run/current-system/sw/bin/systemctl poweroff
          '';
        };
        
        # Lid switch handler (suspend)
        lid = {
          event = "button/lid.*";
          action = ''
            # Suspend on lid close
            /run/current-system/sw/bin/systemctl suspend
          '';
        };
      };
    };
  };

  # Systemd services for hardware optimization
  systemd.services = {
    # Set Intel GPU performance mode
    intel-gpu-performance = {
      description = "Set Intel GPU to performance mode";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.bash}/bin/bash -c 'echo performance > /sys/class/drm/card0/gt_cur_freq_mhz || true'";
        RemainAfterExit = true;
      };
    };
  };

  # Hardware-specific font rendering optimizations
  fonts.fontconfig = {
    enable = true;
    antialias = true;
    hinting = {
      enable = true;
      autohint = true;
      style = "full";
    };
    subpixel = {
      rgba = "rgb";
      lcdfilter = "default";
    };
  };
}