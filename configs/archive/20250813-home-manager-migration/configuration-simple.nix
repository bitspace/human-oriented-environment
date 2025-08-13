# Simple Working NixOS Configuration - Just Add Hyprland to Current System
# Based on current working configuration with minimal additions

{ config, pkgs, lib, ... }:

let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-25.05.tar.gz";
in
{
  imports = [
    /etc/nixos/hardware-configuration.nix
    (import "${home-manager}/nixos")
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

  # System-level packages (keep minimal)
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

  # Home Manager configuration
  home-manager = {
    # Backup existing files when Home Manager takes control
    backupFileExtension = "backup";
    
    users.chris = { pkgs, ... }: {
      home.stateVersion = "25.05";
      
      # Allow unfree packages in Home Manager
      nixpkgs.config = {
        allowUnfree = true;
        allowUnfreePredicate = (_: true);
      };
      
      # Essential user packages via Home Manager  
      home.packages = with pkgs; [
        # Primary applications
        google-chrome     # Primary browser
        
        # Qt-based GUI applications (preferred over GTK)
        kdePackages.dolphin      # Qt file manager
        kdePackages.okular       # Qt PDF viewer  
        kdePackages.gwenview     # Qt image viewer
        
        # Development tools
        git
        vim
        nano
        curl
        wget
        
        # File management
        ranger            # Terminal file manager
        
        # System utilities (btop instead of htop)
        btop              # Modern system monitor
        tree
        fd                # Better find
        ripgrep           # Better grep
        bat               # Better cat
        eza               # Better ls
        
        # Media applications
        mpv               # Video player
        vlc               # Alternative video player
        
        # Archive tools
        unzip
        p7zip
        
        # Network tools
        nmap
        dig
        
        # Development utilities
        jq                # JSON processor
        yq                # YAML processor
        fzf               # Fuzzy finder
        zoxide            # Better cd command
        direnv            # Environment management
        
        # Modern CLI tools
        delta             # Better git diff viewer
        lazygit           # Terminal git UI
        starship          # Modern shell prompt
        
        # Authentication and security
        _1password-cli    # 1Password CLI
        _1password-gui    # 1Password GUI application
      ];
      
      # Git configuration (respects existing user config)
      programs.git = {
        enable = true;
        # Don't override existing userName/userEmail
        extraConfig = {
          init.defaultBranch = "main";
          pull.rebase = true;
          push.autoSetupRemote = true;
          # Additional helpful git settings
          core.editor = "vim";
          core.pager = "delta";
          merge.tool = "vimdiff";
          diff.algorithm = "patience";
          log.decorate = "short";
          status.showUntrackedFiles = "all";
          # Delta (better diff) configuration
          delta.navigate = true;
          delta.light = false;
          merge.conflictstyle = "diff3";
          diff.colorMoved = "default";
          # Global gitignore
          core.excludesfile = "~/.gitignore_global";
        };
      };
      
      # Bash configuration  
      programs.bash = {
        enable = true;
        enableCompletion = true;
        historyControl = [ "ignoredups" "ignorespace" ];
        historySize = 50000;
        historyFileSize = 100000;
        shellOptions = [
          # Append to history instead of overwriting
          "histappend"
          # Check window size after each command
          "checkwinsize"
          # Correct minor directory spelling errors
          "cdspell"
          # Enable extended glob patterns
          "extglob"
        ];
        shellAliases = {
          # Enhanced ls commands
          ls = "eza --color=auto --group-directories-first";
          ll = "eza -la --group-directories-first";
          la = "eza -a --group-directories-first";
          tree = "eza --tree";
          
          # Navigation
          ".." = "cd ..";
          "..." = "cd ../..";
          "....." = "cd ../../../..";
          
          # Enhanced utilities  
          grep = "rg";
          cat = "bat --style=plain";
          find = "fd";
          
          # Git shortcuts
          gs = "git status";
          gd = "git diff";
          ga = "git add";
          gc = "git commit";
          gp = "git push";
          gl = "git log --oneline --graph --decorate";
          
          # System utilities
          htop = "btop";
          df = "df -h";
          du = "du -h";
          free = "free -h";
          
          # NixOS specific
          nrs = "sudo nixos-rebuild switch";
          nrt = "sudo nixos-rebuild test";
          hms = "home-manager switch";
        };
        bashrcExtra = ''
          # Initialize Starship prompt
          if command -v starship >/dev/null 2>&1; then
            eval "$(starship init bash)"
          else
            # Fallback prompt
            export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
          fi
          
          # Better history handling
          export HISTTIMEFORMAT="%F %T "
          
          # Enable fzf if available
          if command -v fzf >/dev/null 2>&1; then
            eval "$(fzf --bash)"
          fi
          
          # Enable zoxide if available
          if command -v zoxide >/dev/null 2>&1; then
            eval "$(zoxide init bash)"
          fi
        '';
      };
      
      # Additional program configurations
      programs.fzf = {
        enable = true;
        enableBashIntegration = true;
        defaultCommand = "fd --type f --hidden --follow --exclude .git";
        defaultOptions = [ "--height 40%" "--border" ];
      };
      
      programs.zoxide = {
        enable = true;
        enableBashIntegration = true;
      };
      
      programs.direnv = {
        enable = true;
        enableBashIntegration = true;
        nix-direnv.enable = true;
      };
      
      # Dotfiles and configuration management
      home.file = {
        # Git global ignore file
        ".gitignore_global".text = ''
          # OS generated files
          .DS_Store
          .DS_Store?
          ._*
          .Spotlight-V100
          .Trashes
          ehthumbs.db
          Thumbs.db
          
          # Editor files
          *~
          *.swp
          *.swo
          .vscode/
          .idea/
          
          # Build artifacts
          *.o
          *.so
          *.a
          *.exe
          
          # Logs
          *.log
          
          # Temporary files
          *.tmp
          *.temp
        '';
        
        # Starship prompt configuration
        ".config/starship.toml".text = ''
          format = """
          $username\
          $hostname\
          $directory\
          $git_branch\
          $git_state\
          $git_status\
          $cmd_duration\
          $line_break\
          $python\
          $character"""
          
          [directory]
          style = "blue"
          
          [character]
          success_symbol = "[❯](purple)"
          error_symbol = "[❯](red)"
          vimcmd_symbol = "[❮](green)"
          
          [git_branch]
          format = "[$branch]($style)"
          style = "bright-black"
          
          [git_status]
          format = "[[(*$conflicted$untracked$modified$staged$renamed$deleted)](218) ($ahead_behind$stashed)]($style)"
          style = "cyan"
          
          [git_state]
          format = '\([$state( $progress_current/$progress_total)]($style)\) '
          style = "bright-black"
          
          [cmd_duration]
          format = "[$duration]($style) "
          style = "yellow"
          
          [python]
          format = "[$virtualenv]($style) "
          style = "bright-black"
        '';
      };
      
      # Hyprland uses the standard config location ~/.config/hypr/hyprland.conf
    };
  };

  system.stateVersion = "25.05";
}