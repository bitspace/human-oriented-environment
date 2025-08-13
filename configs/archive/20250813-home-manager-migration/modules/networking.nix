# Networking Configuration Module
# Enhanced networking for development and LLM orchestration

{ config, pkgs, lib, ... }:

{
  # Keep existing networking configuration but enhance it
  networking = {
    # Keep current hostname
    hostName = "strider";
    
    # Keep current network manager setup
    networkmanager = {
      enable = true;
      wifi = {
        powersave = false;  # Disable WiFi power saving for better performance
        macAddress = "preserve";  # Keep existing MAC address
      };
      ethernet.macAddress = "preserve";
      
      # DNS configuration
      dns = "systemd-resolved";
    };
    
    # Disable wireless (keep current setting)
    wireless.enable = false;
    
    # Enhanced firewall configuration
    firewall = {
      enable = true;
      # Keep SSH open (current setting)
      allowedTCPPorts = [ 
        22      # SSH (current)
        # Development ports that might be needed
        3000    # Common development server
        8000    # Alternative development server
        8080    # Alternative web server
      ];
      allowedUDPPorts = [ ];
      
      # Allow specific interfaces
      trustedInterfaces = [ "lo" ];  # Trust loopback interface
      
      # Log dropped packets (for debugging)
      logReversePathDrops = true;
      
      # Extra rules for development
      extraCommands = ''
        # Allow Docker containers to communicate
        iptables -I INPUT -i docker0 -j ACCEPT || true
        iptables -I FORWARD -i docker0 -o docker0 -j ACCEPT || true
      '';
    };
    
    # Enable systemd-resolved for better DNS handling
    nameservers = [ "1.1.1.1" "1.0.0.1" "8.8.8.8" "8.8.4.4" ];
    
    # Network optimization
    enableIPv6 = true;
    useDHCP = lib.mkDefault true;
    
    # Proxy configuration (if needed for corporate environments)
    # proxy = {
    #   default = "http://proxy:port";
    #   noProxy = "127.0.0.1,localhost,internal.domain";
    # };
    
    # Hosts file for development
    extraHosts = ''
      127.0.0.1 localhost.localdomain
      ::1 localhost.localdomain
      
      # Development hosts
      127.0.0.1 dev.local
      127.0.0.1 api.local
      127.0.0.1 app.local
    '';
  };

  # Systemd-resolved configuration
  services.resolved = {
    enable = true;
    dnssec = "true";
    domains = [ "~." ];
    fallbackDns = [ "1.1.1.1#one.one.one.one" "1.0.0.1#one.one.one.one" ];
    extraConfig = ''
      DNS=1.1.1.1#cloudflare-dns.com 1.0.0.1#cloudflare-dns.com
      DNSOverTLS=yes
      MulticastDNS=yes
      LLMNR=yes
      Cache=yes
      CacheFromLocalhost=no
    '';
  };

  # Network tools and utilities
  environment.systemPackages = with pkgs; [
    # Network diagnostics
    dig
    nslookup
    whois
    traceroute
    mtr
    netcat-gnu
    socat
    tcpdump
    wireshark
    nmap
    
    # Network management
    networkmanager
    networkmanagerapplet
    networkmanager-openvpn
    
    # WiFi tools
    iw
    wireless-tools
    wpa_supplicant_gui
    
    # Monitoring
    nethogs
    iftop
    vnstat
    
    # SSH tools
    openssh
    sshfs
    
    # VPN clients
    openvpn
    wireguard-tools
    
    # Web tools
    wget
    curl
    httpie
    
    # File sharing
    rsync
    
    # Network utilities
    bind  # For dig and nslookup
    inetutils  # For telnet, ftp, etc
  ];

  # SSH configuration (enhanced from current)
  services.openssh = {
    enable = true;
    ports = [ 22 ];
    
    settings = {
      # Security settings (keep current)
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      
      # Additional security
      PermitRootLogin = "no";
      MaxAuthTries = 3;
      ClientAliveInterval = 300;
      ClientAliveCountMax = 2;
      
      # Performance settings
      UseDns = false;
      
      # Allow agent forwarding for development
      AllowAgentForwarding = true;
      AllowTcpForwarding = true;
      
      # X11 forwarding for GUI applications over SSH (when needed)
      X11Forwarding = false;  # Disabled by default for security
    };
    
    # SSH host keys
    hostKeys = [
      {
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
      {
        path = "/etc/ssh/ssh_host_rsa_key";
        type = "rsa";
        bits = 4096;
      }
    ];
  };

  # Enable avahi for local network discovery
  services.avahi = {
    enable = true;
    nssmdns4 = true;  # Support .local domains
    nssmdns6 = true;  # Support .local domains over IPv6
    openFirewall = true;
    publish = {
      enable = true;
      addresses = true;
      domain = true;
      hinfo = true;
      userServices = true;
      workstation = true;
    };
  };

  # Network optimization settings
  boot.kernel.sysctl = {
    # TCP optimization
    "net.core.rmem_max" = 134217728;        # 128MB
    "net.core.wmem_max" = 134217728;        # 128MB
    "net.ipv4.tcp_rmem" = "4096 87380 134217728";
    "net.ipv4.tcp_wmem" = "4096 65536 134217728";
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.core.default_qdisc" = "fq";
    
    # Network security
    "net.ipv4.conf.all.rp_filter" = 1;
    "net.ipv4.conf.default.rp_filter" = 1;
    "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
    "net.ipv4.icmp_ignore_bogus_error_responses" = 1;
    "net.ipv4.conf.all.accept_redirects" = 0;
    "net.ipv4.conf.all.send_redirects" = 0;
    "net.ipv4.conf.all.accept_source_route" = 0;
    
    # IPv6 security
    "net.ipv6.conf.all.accept_redirects" = 0;
    "net.ipv6.conf.default.accept_redirects" = 0;
    
    # Connection tracking
    "net.netfilter.nf_conntrack_max" = 524288;
  };

  # Additional network services for development
  services = {
    # Enable printing over network
    printing = {
      enable = true;
      drivers = with pkgs; [ cups-filters gutenprint ];
    };
    
    # Enable SAMBA for Windows compatibility (optional)
    # samba = {
    #   enable = false;  # Enable if needed for file sharing
    #   securityType = "user";
    #   extraConfig = ''
    #     workgroup = WORKGROUP
    #     server string = NixOS Samba Server
    #     netbios name = strider
    #   '';
    # };
    
    # Enable NFS client support (for network storage)
    rpcbind.enable = false;  # Enable if NFS is needed
  };

  # Systemd network configuration for additional interfaces
  systemd.network = {
    enable = false;  # Keep NetworkManager as primary, enable if needed
    
    # Example configuration if systemd-networkd is preferred
    # networks."10-wired" = {
    #   matchConfig.Name = "en*";
    #   DHCP = "yes";
    # };
    # networks."20-wireless" = {
    #   matchConfig.Name = "wl*";
    #   DHCP = "yes";
    # };
  };
}