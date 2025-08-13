# Development Environment Configuration Module
# Comprehensive development tools for polyglot programming and AI/ML

{ config, pkgs, lib, ... }:

{
  # Virtualization support
  virtualisation = {
    docker = {
      enable = true;
      enableOnBoot = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
    };
    
    # Podman as alternative container runtime (disabled due to Docker conflict)
    # podman = {
    #   enable = true;
    #   dockerCompat = false;  # Disabled due to conflict with Docker
    #   defaultNetwork.settings.dns_enabled = true;
    # };
    
    # Enable libvirtd for VM management
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        ovmf.enable = true;  # UEFI support
        ovmf.packages = [ pkgs.OVMFFull.fd ];
      };
    };
    
    # Enable KVM
    kvmgt.enable = true;
  };

  # Development packages
  environment.systemPackages = with pkgs; [
    # Version Control
    git
    git-lfs
    gitui               # Git TUI
    gh                  # GitHub CLI
    gitlab-runner       # GitLab CI
    
    # Text Editors and IDEs
    neovim
    vscode              # VS Code
    jetbrains.idea-ultimate  # IntelliJ IDEA (requires unfree)
    jetbrains.pycharm-professional
    jetbrains.webstorm
    jetbrains.datagrip
    
    # Alternative editors
    emacs
    zed-editor          # Modern editor
    helix               # Modal editor
    
    # Programming Languages and Runtimes
    
    # Node.js ecosystem (current + enhanced)
    nodejs_20           # LTS version
    nodePackages.npm
    nodePackages.yarn
    nodePackages.pnpm
    bun                 # Fast JS runtime
    deno                # Secure JS/TS runtime
    
    # Python ecosystem (current + enhanced)
    python3
    python3Packages.pip
    python3Packages.pipx
    python3Packages.virtualenv
    poetry  # Top-level poetry package
    pyenv               # Python version management
    
    # Rust
    rustc
    cargo
    rustfmt
    clippy
    rust-analyzer
    
    # Go
    go
    gopls               # Go language server
    gotools
    
    # Java/JVM
    openjdk17
    openjdk21
    maven
    gradle
    sbt                 # Scala build tool
    
    # C/C++
    gcc
    clang
    cmake
    ninja
    ccache              # Compiler cache
    gdb                 # Debugger
    lldb                # LLVM debugger
    valgrind            # Memory debugging
    
    # C# / .NET
    dotnet-sdk_8
    omnisharp-roslyn
    
    # PHP
    php83
    php83Packages.composer
    
    # Ruby
    ruby
    bundler
    
    # Haskell
    ghc
    cabal-install
    stack
    
    # Database tools
    postgresql_15
    mysql80
    sqlite
    redis
    mongodb
    
    # Database clients and tools
    dbeaver-bin         # Universal database client
    pgadmin4           # PostgreSQL admin
    mysql-workbench    # MySQL admin
    
    # Cloud Development Tools
    
    # AWS
    awscli2
    aws-sam-cli
    ssm-session-manager-plugin
    
    # GCP
    google-cloud-sdk
    
    # Azure
    azure-cli
    
    # Kubernetes
    kubectl
    kubectx             # Context switching
    kubens              # Namespace switching
    k9s                 # Kubernetes TUI
    helm                # Package manager
    kustomize
    argocd              # GitOps
    
    # Terraform and Infrastructure
    terraform
    terragrunt
    packer
    vault
    consul
    nomad
    
    # Container tools
    docker
    docker-compose
    podman
    buildah
    skopeo
    dive                # Docker image analyzer
    
    # API Development
    postman
    insomnia
    httpie
    curl
    
    # Build Tools and Task Runners
    gnumake
    just                # Modern make alternative
    task                # Task runner
    
    # Monitoring and Observability
    prometheus
    grafana
    jaeger              # Distributed tracing
    
    # Security tools
    nmap
    wireshark
    burpsuite
    
    # AI/ML Development Tools
    
    # Python ML packages (system-wide for base functionality)
    python3Packages.numpy
    python3Packages.scipy
    python3Packages.pandas
    python3Packages.matplotlib
    python3Packages.seaborn
    python3Packages.scikit-learn
    python3Packages.jupyter
    python3Packages.ipython
    
    # CUDA support (if needed)
    # cudatoolkit
    # cudnn
    
    # R for statistical computing
    R
    rstudio
    
    # Julia
    julia
    
    # Documentation tools
    pandoc
    texlive.combined.scheme-full  # LaTeX
    
    # Utility tools
    jq                  # JSON processor
    yq                  # YAML processor
    fx                  # JSON viewer
    bat                 # Better cat
    exa                 # Better ls
    fd                  # Better find
    ripgrep             # Better grep
    fzf                 # Fuzzy finder
    zoxide              # Smart cd
    direnv              # Environment per directory
    
    # Network utilities
    nmap
    netcat-gnu
    socat
    tcpdump
    wireshark-cli
    
    # Performance profiling
    perf-tools
    flamegraph
    hyperfine           # Benchmarking
    
    # File utilities
    tree
    ncdu                # Disk usage analyzer
    duf                 # Better df
    
    # Archive tools
    p7zip
    unzip
    gnutar
    
    # System utilities
    htop
    btop
    iotop
    strace
    ltrace
    lsof
    
    # Terminal multiplexing
    tmux
    screen
    
    # Shell utilities
    starship            # Cross-shell prompt
    zsh-completions
    
    # Gaming development (basic)
    godot_4            # Game engine
    blender            # 3D modeling
    
    # Music production development
    # reaper             # DAW (proprietary, may not be available)
    # ardour            # Open source DAW
    # lmms              # Linux MultiMedia Studio
    
    # Image/Video processing
    imagemagick
    ffmpeg
    
    # Documentation generation
    mdbook             # Rust documentation
    gitbook-cli        # GitBook
    
    # Code quality tools
    shellcheck         # Shell script linter
    hadolint           # Dockerfile linter
    yamllint           # YAML linter
    
    # Backup and sync
    rclone             # Cloud storage sync
    restic             # Backup tool
    
    # Miscellaneous development utilities
    watchexec          # File watcher
    entr               # File watcher
    mkcert             # Local HTTPS certificates
    ngrok              # Tunneling
    
    # Protocol buffers
    protobuf
    grpcurl
    
    # Message queues
    kafkactl           # Kafka CLI
    
    # Time tracking and productivity
    timewarrior
  ];

  # Programming language-specific configurations
  programs = {
    # Java
    java = {
      enable = true;
      package = pkgs.openjdk17;
    };
    
    # Node.js tools
    npm = {
      enable = true;
      npmrc = ''
        prefix=$HOME/.npm-global
        init-author-name=chris
        init-license=MIT
      '';
    };
    
    # Neovim with plugins
    neovim = {
      enable = true;
      defaultEditor = true;
      configure = {
        customRC = ''
          set number
          set relativenumber
          set autoindent
          set tabstop=2
          set shiftwidth=2
          set expandtab
          set smarttab
          syntax on
        '';
      };
    };
    
    # Git configuration
    git = {
      enable = true;
      config = {
        init.defaultBranch = "main";
        pull.rebase = true;
        push.autoSetupRemote = true;
        core.editor = "nvim";
        diff.tool = "nvim -d";
        merge.tool = "nvim -d";
      };
    };
    
    # Zsh enhancements for development
    zsh = {
      enable = true;
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;
      ohMyZsh = {
        enable = true;
        theme = "robbyrussell";
        plugins = [ 
          "git" 
          "docker" 
          "kubectl" 
          "terraform" 
          "aws" 
          "gcloud" 
          "python" 
          "nodejs" 
          "rust" 
          "golang"
          "helm"
        ];
      };
    };
    
    # Direnv for per-project environments
    direnv = {
      enable = true;
      enableZshIntegration = true;
    };
    
    # GPG for signing commits
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  # Development services
  services = {
    # PostgreSQL database
    postgresql = {
      enable = true;
      package = pkgs.postgresql_15;
      enableTCPIP = true;
      authentication = pkgs.lib.mkOverride 10 ''
        local all all trust
        host all all 127.0.0.1/32 trust
        host all all ::1/128 trust
      '';
      initialScript = pkgs.writeText "backend-initScript" ''
        CREATE ROLE chris WITH LOGIN PASSWORD 'dev' CREATEDB;
        CREATE DATABASE development;
        GRANT ALL PRIVILEGES ON DATABASE development TO chris;
      '';
    };
    
    # Redis for caching
    redis = {
      servers."development" = {
        enable = true;
        port = 6379;
        bind = "127.0.0.1";
      };
    };
    
    # MongoDB
    mongodb = {
      enable = true;
      bind_ip = "127.0.0.1";
    };
    
    # Docker socket access
    # Note: User must be in docker group (configured in main config)
  };

  # User groups for development - configured in main configuration.nix

  # Environment variables for development
  environment.variables = {
    # Development paths
    GOPATH = "$HOME/go";
    GOBIN = "$HOME/go/bin";
    CARGO_HOME = "$HOME/.cargo";
    RUSTUP_HOME = "$HOME/.rustup";
    
    # Python
    PYTHONPATH = "$HOME/.local/lib/python3.11/site-packages";
    PIP_USER = "1";
    
    # Node.js
    NPM_CONFIG_PREFIX = "$HOME/.npm-global";
    NODE_PATH = "$HOME/.npm-global/lib/node_modules";
    
    # Java
    JAVA_HOME = "${pkgs.openjdk17}/lib/openjdk";
    
    # Editor preferences
    EDITOR = "nvim";
    VISUAL = "nvim";
    
    # Development tools
    DOCKER_BUILDKIT = "1";
    COMPOSE_DOCKER_CLI_BUILD = "1";
    
    # Cloud development
    AWS_CLI_AUTO_PROMPT = "on-partial";
    
    # Kubernetes
    KUBE_EDITOR = "nvim";
  };

  # Session PATH additions for development tools
  environment.sessionVariables = {
    PATH = [
      "$HOME/.local/bin"
      "$HOME/go/bin"
      "$HOME/.cargo/bin"
      "$HOME/.npm-global/bin"
      "$HOME/.dotnet/tools"
    ];
  };

  # System-wide shell aliases for development
  environment.shellAliases = {
    # Git shortcuts
    "gs" = "git status";
    "ga" = "git add";
    "gc" = "git commit";
    "gp" = "git push";
    "gl" = "git log --oneline";
    "gd" = "git diff";
    
    # Docker shortcuts
    "dps" = "docker ps";
    "dcu" = "docker-compose up";
    "dcd" = "docker-compose down";
    "dcl" = "docker-compose logs";
    
    # Kubernetes shortcuts
    "k" = "kubectl";
    "kgp" = "kubectl get pods";
    "kgs" = "kubectl get services";
    "kgd" = "kubectl get deployments";
    
    # System shortcuts
    "ll" = "ls -la";
    "la" = "ls -la";
    "l" = "ls -l";
    "grep" = "grep --color=auto";
    
    # Development shortcuts
    "py" = "python3";
    "pip" = "pip3";
    "tf" = "terraform";
    "tg" = "terragrunt";
    
    # Modern alternatives
    "cat" = "bat";
    "ls" = "exa";
    "find" = "fd";
    "cd" = "z";  # zoxide
  };

  # Systemd services for development
  systemd.services = {
    # Development database init
    dev-db-setup = {
      description = "Initialize development databases";
      wantedBy = [ "multi-user.target" ];
      after = [ "postgresql.service" "redis-development.service" ];
      serviceConfig = {
        Type = "oneshot";
        User = "chris";
        ExecStart = pkgs.writeScript "dev-db-setup" ''
          #!${pkgs.bash}/bin/bash
          # Create additional development databases if needed
          ${pkgs.postgresql}/bin/createdb -h localhost testing 2>/dev/null || true
          ${pkgs.postgresql}/bin/createdb -h localhost integration 2>/dev/null || true
        '';
      };
    };
  };

  # Nix development tools
  nix.settings = {
    # Allow flakes and nix-command for modern Nix development
    experimental-features = [ "nix-command" "flakes" ];
    
    # Build settings for development
    keep-outputs = true;
    keep-derivations = true;
    
    # Trusted users for nix commands
    trusted-users = [ "root" "@wheel" "chris" ];
  };

  # Additional development-related kernel parameters
  boot.kernel.sysctl = {
    # Increase inotify limits for development tools
    "fs.inotify.max_user_watches" = 1048576;
    "fs.inotify.max_user_instances" = 8192;
    
    # Increase file descriptor limits
    "fs.file-max" = 2097152;
    
    # Network development
    "net.core.somaxconn" = 4096;
    "net.ipv4.ip_local_port_range" = "1024 65535";
  };

  # Development-specific firewall rules
  networking.firewall = {
    # Common development ports
    allowedTCPPorts = [
      3000   # React/Node.js dev server
      3001   # Alternative dev server
      4000   # Various dev frameworks
      5000   # Flask default
      5432   # PostgreSQL
      6379   # Redis
      8000   # Django/Python dev server
      8080   # Alternative HTTP
      8090   # Various dev servers
      9000   # Various dev servers
      9090   # Prometheus
      3306   # MySQL
      27017  # MongoDB
    ];
    
    allowedTCPPortRanges = [
      { from = 3000; to = 3010; }  # Development server range
      { from = 8000; to = 8010; }  # Alternative dev server range
    ];
  };

  # Gaming development support (configured in desktop.nix)
  
  # Music production JACK support
  services.pipewire.jack.enable = true;
  
  # Enable real-time scheduling for audio
  security.rtkit.enable = true;
  
  # Additional groups for development
  users.groups = {
    plugdev = {};  # For hardware access
  };
}