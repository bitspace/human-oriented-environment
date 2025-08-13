# Security Configuration Module
# Security hardening and policies for development workstation

{ config, pkgs, lib, ... }:

{
  # User security configuration
  security = {
    # Enable sudo with reasonable defaults
    sudo = {
      enable = true;
      wheelNeedsPassword = true;  # Require password for sudo (security best practice)
      
      # Additional sudo rules for development
      extraRules = [
        {
          users = [ "chris" ];
          commands = [
            {
              command = "${pkgs.systemd}/bin/systemctl";
              options = [ "NOPASSWD" ];  # Allow passwordless service management
            }
            {
              command = "${pkgs.nixos-rebuild}/bin/nixos-rebuild";
              options = [ "NOPASSWD" ];  # Temporary: allow passwordless rebuilds for deployment
            }
          ];
        }
      ];
    };
    
    # Enable polkit for GUI privilege escalation
    polkit.enable = true;
    
    # Real-time kit for audio
    rtkit.enable = true;
    
    # PAM configuration
    pam.services = {
      # Enable fingerprint authentication if available
      login.fprintAuth = false;  # Can be enabled if fingerprint reader is set up
      sudo.fprintAuth = false;
      
      # Increase login delay after failed attempts
      login.failDelay.delay = 3000000;  # 3 seconds
    };
    
    # AppArmor for application sandboxing (optional)
    apparmor = {
      enable = false;  # Enable if additional sandboxing is needed
      killUnconfinedConfinables = false;
    };
    
    # Enable audit framework (for compliance if needed)
    audit = {
      enable = false;  # Enable if auditing is required
      rules = [
        "-a exit,always -F arch=b64 -S execve"  # Audit all executions
      ];
    };
  };

  # Systemd security hardening
  systemd = {
    extraConfig = ''
      DefaultTimeoutStopSec=10s
      DefaultTimeoutStartSec=30s
    '';
    
    # User service hardening
    user.extraConfig = ''
      DefaultTimeoutStopSec=10s
    '';
  };

  # Kernel security parameters
  boot.kernel.sysctl = {
    # Disable core dumps (security)
    "kernel.core_pattern" = "|/bin/false";
    
    # Enable ASLR
    "kernel.randomize_va_space" = 2;
    
    # Restrict access to kernel logs
    "kernel.dmesg_restrict" = 1;
    
    # Restrict access to kernel pointers
    "kernel.kptr_restrict" = 2;
    
    # Disable magic SysRq key
    "kernel.sysrq" = 0;
    
    # Restrict perf events
    "kernel.perf_event_paranoid" = 2;
    
    # Network security (additional to networking.nix)
    "net.ipv4.conf.all.log_martians" = 1;
    "net.ipv4.conf.default.log_martians" = 1;
    "net.ipv4.tcp_syncookies" = 1;
    
    # Protect against time-wait assassination
    "net.ipv4.tcp_rfc1337" = 1;
  };

  # Security-related packages
  environment.systemPackages = with pkgs; [
    # System security tools
    sudo
    polkit
    
    # Password management
    pass
    
    # Network security
    fail2ban  # Will be configured below
    
    # Encryption tools
    gnupg
    cryptsetup
    
    # System monitoring
    lynis      # Security auditing
    # rkhunter   # Rootkit detection (not available in nixpkgs)
    
    # Secure communication
    openssh
    
    # File integrity
    # aide       # File integrity checker (may not be available)
    
    # Secure deletion
    # secure-delete  # Package name may be different in nixpkgs
    
    # System hardening
    # hardening-check  # Package name may be different in nixpkgs
  ];

  # Fail2ban configuration for SSH protection
  services.fail2ban = {
    enable = true;
    maxretry = 3;
    bantime = "1h";
    ignoreIP = [
      "127.0.0.0/8"
      "::1"
      "10.0.0.0/8"
      "172.16.0.0/12"
      "192.168.0.0/16"
    ];
    
    jails = {
      # SSH protection
      ssh = ''
        enabled = true
        port = ssh
        filter = sshd
        logpath = /var/log/auth.log
        maxretry = 3
        bantime = 3600
      '';
      
      # Nginx protection (if web server is installed)
      nginx-http-auth = ''
        enabled = false
        filter = nginx-http-auth
        logpath = /var/log/nginx/error.log
        maxretry = 6
      '';
    };
  };

  # GPG agent configuration
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryPackage = pkgs.pinentry-gtk2;
  };

  # Additional security services
  services = {
    # Automatic security updates (careful with this on development systems)
    # Can be enabled for security-critical environments
    # Note: NixOS handles updates differently than other distros
    # unattended-upgrades.enable = false;
    
    # USB Guard (optional - can interfere with development)
    # usbguard = {
    #   enable = false;
    #   rules = ''
    #     allow with-interface equals { 03:00:01 03:01:01 09:00:00 }
    #   '';
    # };
    
    # File integrity monitoring (optional)
    # aide = {
    #   enable = false;
    #   config = ''
    #     database_in = file:/var/lib/aide/aide.db
    #     database_out = file:/var/lib/aide/aide.db.new
    #     database_new = file:/var/lib/aide/aide.db.new
    #     gzip_dbout = yes
    #     
    #     /etc p+i+n+u+g+s+b+m+c+md5+sha1
    #     /bin p+i+n+u+g+s+b+m+c+md5+sha1
    #   '';
    # };
    
    # ClamAV antivirus (optional)
    # clamav = {
    #   daemon.enable = false;
    #   updater.enable = false;
    # };
  };

  # File system security
  fileSystems = {
    # Add noexec to /tmp if it's a separate partition
    # "/tmp" = {
    #   options = [ "noexec" "nosuid" "nodev" ];
    # };
    
    # Secure /proc
    "/proc" = {
      options = [ "hidepid=2" ];
    };
  };

  # Systemd service hardening templates
  systemd.services = {
    # Example hardened service template
    # custom-service = {
    #   serviceConfig = {
    #     # User/Group isolation
    #     DynamicUser = true;
    #     User = "custom-service";
    #     Group = "custom-service";
    #     
    #     # Filesystem isolation
    #     ProtectSystem = "strict";
    #     ProtectHome = true;
    #     PrivateTmp = true;
    #     PrivateDevices = true;
    #     
    #     # Network isolation
    #     PrivateNetwork = false;
    #     RestrictAddressFamilies = [ "AF_UNIX" "AF_INET" "AF_INET6" ];
    #     
    #     # Capability restrictions
    #     CapabilityBoundingSet = [ "" ];
    #     AmbientCapabilities = [ "" ];
    #     NoNewPrivileges = true;
    #     
    #     # System call filtering
    #     SystemCallFilter = [ "@system-service" ];
    #     SystemCallArchitectures = "native";
    #     
    #     # Resource limits
    #     MemoryDenyWriteExecute = true;
    #     LockPersonality = true;
    #     RestrictRealtime = true;
    #     RestrictSUIDSGID = true;
    #     ProtectKernelTunables = true;
    #     ProtectKernelModules = true;
    #     ProtectControlGroups = true;
    #   };
    # };
  };

  # Security-focused environment variables
  environment.variables = {
    # Secure defaults
    HISTCONTROL = "ignoredups:ignorespace";
    LESSHISTFILE = "/dev/null";  # Don't save less history
  };

  # Secure boot configuration (if enabled)
  # boot.loader.systemd-boot.secureBoot = false;  # Enable if secure boot is set up
  
  # Kernel module blacklist for security
  boot.blacklistedKernelModules = [
    # Disable uncommon network protocols
    "dccp"
    "sctp"
    "rds"
    "tipc"
    
    # Disable uncommon filesystems
    "cramfs"
    "freevxfs"
    "jffs2"
    "hfs"
    "hfsplus"
    "udf"
    
    # Disable firewire and thunderbolt if not needed (comment out if needed)
    # "firewire-ohci"
    # "thunderbolt"
  ];

  # Additional hardening
  boot.kernelParams = [
    # Enable SMEP (Supervisor Mode Execution Protection)
    "smep=on"
    
    # Enable SMAP (Supervisor Mode Access Prevention)
    "smap=on"
    
    # Disable vsyscalls (potential attack vector)
    "vsyscall=none"
    
    # Enable KASLR (Kernel Address Space Layout Randomization)
    "kaslr"
    
    # Disable legacy 32-bit syscalls on 64-bit systems
    # "ia32_emulation=0"  # Uncomment if no 32-bit compatibility needed
  ];

  # Umask for better default permissions
  security.pam.loginLimits = [
    {
      domain = "@users";
      type = "soft";
      item = "nofile";
      value = "65536";
    }
    {
      domain = "@users";
      type = "hard";
      item = "nofile";
      value = "65536";
    }
  ];
}