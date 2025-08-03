# Customized Rolling-Release Linux Setup for a System76 Kudu6 Laptop

## Introduction

This report outlines a comprehensive plan to set up a high-performance Linux environment on a System76 **Kudu6** laptop (AMD Ryzen 9 5900HX CPU with Radeon iGPU, NVIDIA RTX 3060 dGPU, 64 GB RAM, 2 TB NVMe SSD) for uses including gaming, software development, AI/ML research, cloud tools, and music production. The focus is on **rolling-release** distributions that use **systemd** and modern package managers (binary or hybrid) to ensure up-to-date software and flexibility. We also identify suitable **Wayland** compositors (window managers/DEs) beyond GNOME/KDE that emphasize keyboard navigation, scripting, and full-screen application support. Finally, we provide a full installation and configuration plan with automation hooks, assuming much of the setup will be orchestrated via an AI/LLM agent (e.g. OpenAI Codex or Claude).

Throughout the report, we include structured comparisons (with tables) and snippet examples in **JSON**, **shell script**, and **Nix** to illustrate how an LLM can assist in automating key steps. All sources are cited for verification of claims.

## 1. Top 5 Rolling-Release Linux Distributions (systemd-based)

Below we compare five distributions that meet the criteria: rolling-release model, systemd init, and modern package management (binary or hybrid). Each is well-suited for a development- and gaming-ready laptop, with considerations for GPU support, software availability, and maintenance.

| **Distro**                       | **Package Manager & Type**       | **Systemd**                | **Key Features for This Use-Case**                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| -------------------------------- | -------------------------------- | -------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Arch Linux**                   | Pacman (binary + AUR source)     | Yes (default)              | Cutting-edge rolling updates, huge software ecosystem (official + AUR), highly customizable minimal base. Ideal for latest drivers (e.g. new NVIDIA, Mesa versions) and gaming libraries. Requires user to manage updates (rolling release means no reinstalls).                                                                                                                                                                                                        |
| **Gentoo Linux**                 | Portage (source; binary options) | Yes (with systemd profile) | True rolling-release source distro with extreme flexibility. User builds packages with chosen optimizations; can enable a systemd profile. Highly customizable for performance (e.g. custom compile flags, USE flags for AI libs). Gentoo now also provides many **binary packages** to speed up installs. Maintenance is complex (must rebuild updates, ensure 32-bit libs for Steam, etc.), but an LLM agent could help automate routine emerges and config edits.    |
| **openSUSE Tumbleweed**          | Zypper (RPM, binary)             | Yes                        | **Stable** rolling-release with thorough testing (openQA). Provides up-to-date kernels, drivers and software with enterprise-level stability. Systemd-based, with tools like YaST for easy config. Great hardware support (e.g. official NVIDIA driver repo) and cloud-friendly tooling (Docker, Podman out-of-box). Slightly heavier base install, but very robust for daily use.                                                                                      |
| **NixOS (Unstable)**             | Nix (functional pkg mgr, hybrid) | Yes                        | Declarative, **reproducible** OS configuration. NixOS has stable releases, but using the *unstable channel* yields a rolling stream of latest packages. Uses systemd and integrates it deeply. Ideal for power-users: configuration is code, which an AI agent can easily parse/modify. Rollbacks are easy (good safety for a rolling distro). Steep learning curve, but excellent for managing complex setups (custom dev environments, isolated AI toolchains, etc.). |
| **Manjaro Linux** *(Arch-based)* | Pacman (binary + AUR)            | Yes                        | User-friendly rolling distro based on Arch. It slightly delays updates for extra QA, making it more stable than vanilla Arch. Comes with an installer and hardware detection – **especially useful for hybrid graphics** via its `mhwd` tool (can auto-configure NVIDIA Prime/Optimus). Large software repo plus AUR access. Good choice if the user wants Arch benefits with less manual setup.                                                                        |

**Note:** Other candidates considered included Fedora Rawhide (very bleeding-edge but not as stable), Solus (rolling but smaller community), and Void Linux (rolling, fast, but uses runit by default). The five above were chosen for their strong community support and relevance to the user’s preferences (pacman/portage, etc.). All five use systemd as init (or can be configured to use it in Gentoo’s case).

## 2. Top 5 Wayland-Compatible Window Managers/Compositors (Non-GNOME/KDE)

For a keyboard-driven, lightweight GUI on Wayland, here are five leading options. Each supports tiling or dynamic window management, works with full-screen applications (gaming), and is scriptable/configurable (suitable for automation via scripts/LLM). All are compatible with the AMD+NVIDIA hybrid graphics setup, though some may require tweaks for NVIDIA’s proprietary driver (as noted).

| **Wayland Compositor (WM/DE)** | **Style**          | **Scriptability & Config**                                                                                                                                                                            | **Notable Features**                                                                                                                                                                                                                                                                                                                                                                                                                         |
| ------------------------------ | ------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Sway** (wlroots-based)       | Tiling (i3-like)   | Configured via simple text file (i3-compatible syntax). Supports i3 IPC commands (`swaymsg`) for runtime control.                                                                                     | Extremely stable and popular; essentially “i3 for Wayland”. Well-documented and reliable. Great for keyboard workflows. **Note:** Requires Nvidia driver with GBM support (495+) to work; otherwise needs the `wlroots-nvidia` build.                                                                                                                                                                                                        |
| **Hyprland** (wlroots-based)   | Dynamic tiling     | Uses an INI-like config and includes `hyprctl` CLI for runtime control. Highly configurable (can script window rules, etc.).                                                                          | Emphasizes eye-candy *and* tiling – has animations, blur, and modern effects, without sacrificing performance. Active development and community; documentation is considered very good. Slightly newer, but many use it daily as a drop-in WM.                                                                                                                                                                                               |
| **River** (wlroots-based)      | Dynamic tiling     | **Extremely scriptable:** no static config file – you provide an init script (executable) that calls `riverctl` commands to set keybindings, rules, etc. Runtime control via `riverctl` is supported. | Minimalist dwm/bspwm-inspired tiling compositor. Uses tags (“views”) instead of fixed workspaces, and allows custom layout generators (e.g. `rivertile`). Simple, predictable behavior by design. Documentation is decent (man pages, wiki). Great for advanced users who want to manage window state via scripts.                                                                                                                           |
| **Wayfire** (wlroots-based)    | Stacking + plugins | Configured via a single INI-style file; supports **plugins** for optional tiling, window effects, etc. Hotkeys can be bound to any action (exposed by plugins).                                       | A 3D compositor inspired by Compiz. Can be lightweight (if you disable fancy effects) or provide flashy animations and zooms. Particularly good for those who want some eye-candy or use cases like presentation zoom, without a full desktop environment. Tiling is not its focus (the tiling plugin exists but is basic, per community feedback). Suitable if you prefer mostly classic windowing with occasional tiling and a wow-factor. |
| **Qtile (Wayland mode)**       | Tiling (dynamic)   | Config is a Python program, allowing complex logic and on-the-fly changes. Highly hackable – you can script window management in Python itself.                                                       | A full-featured tiling WM that now supports Wayland. It brings the flexibility of writing your own layout behaviors in Python. Well-documented and great for developers. Still catching up to others in Wayland support, but very usable. Good for integrating custom automation (an AI agent could directly modify the Python config to, say, change keybindings or layouts).                                                               |

**Other notable mentions:** *Enlightenment* (E) – a long-standing lightweight DE with Wayland support (stacking window management, very configurable via GUI). *Labwc* – an Openbox-like Wayland compositor (manual stacking, with XML configs; lightweight but lacks tiling). *dwl* – a tiny dwm reimplementation for Wayland (configured in C). These are viable but the five above are more popular and better documented for our purposes.

**NVIDIA compatibility:** All listed compositors rely on either wlroots or their own compositing, which now generally works with NVIDIA’s proprietary driver as long as the driver supports GBM (version ≥495). For instance, Mutter and KWin adopted GBM for NVIDIA by default, and similarly Sway/Hyprland can work with the latest drivers (some may require setting `GBM_BACKEND=nvidia-drm` and related env vars). An LLM agent can help apply such configuration if needed. In hybrid setups, the usual approach is to run the Wayland session on the iGPU and use NVIDIA for rendering offload (e.g. running games with environment variables for PRIME render offload).

## 3. Installation and Setup Plan (Automated & LLM-Orchestrated)

This section presents a detailed installation plan, assuming the user will script and automate most steps, possibly by leveraging an AI agent. We cover initial OS installation, post-install configuration (drivers, packages, etc.), and automation hooks to allow iterative refinement via an LLM. The plan is organized into phases, with notes on differences between the recommended distros (Arch, Gentoo, Tumbleweed, NixOS, Manjaro). Example snippets are provided in **JSON** (for Archinstall), **shell scripts** (for general automation), and **Nix** (for NixOS config), demonstrating how an LLM-readable structure can be used.

### 3.1 Pre-Installation: Partitioning and Bootloader

**Disk setup:** The 2 TiB NVMe SSD will use a GPT partition scheme. We create: an EFI system partition (~~1 GiB, FAT32, mounted at `/efi` or `/boot/efi`), a 16 GiB swap partition, and allocate the rest (~~≈1.8 TiB) to the root filesystem. The user prefers **XFS** for the root volume, which is supported by all chosen distros. This matches the current layout. If installing multiple distros (for evaluation), consider partitioning the 1.8 TiB into multiple smaller root partitions or using btrfs subvolumes; but since the plan is to settle on one OS, a single large XFS root is fine.

**Bootloader:** Use **systemd-boot** (for UEFI) across all setups for consistency. Systemd-boot integrates well on a systemd distro and is lightweight. Arch, NixOS, and Gentoo (with systemd) all support it easily; openSUSE Tumbleweed now has experimental support for systemd-boot as well (though its default installer uses GRUB). We will mount the EFI partition at `/efi` (as in current Gentoo setup) and install systemd-boot to the EFI. The boot entries can be managed via configuration or `bootctl`. An LLM agent can reliably configure systemd-boot because of its simple drop-in file format.

*Automation:* For Arch, we can specify the partitions and bootloader in an **archinstall** config JSON (see snippet in the next section). For NixOS, the config will include `boot.loader.systemd-boot.enable = true;`. For Gentoo, after base install one would install `systemd-boot` (from `sys-boot/systemd-boot` package) and use `bootctl install`. These steps can be scripted. An example snippet to partition the disk non-interactively (using `sgdisk` and `mkfs`) is below, which an LLM could adapt if the layout changes:

```bash
# Shell script: partition and format disk (for GPT UEFI with EFI, swap, XFS root)
sgdisk -o /dev/nvme0n1 
sgdisk -n1:0:+1G -t1:EF00 -c1:"EFI System" /dev/nvme0n1 
sgdisk -n2:0:+16G -t2:8200 -c2:"Linux swap" /dev/nvme0n1 
sgdisk -n3:0:0    -t3:8300 -c3:"Linux filesystem" /dev/nvme0n1 
mkfs.vfat -F32 /dev/nvme0n1p1 
mkswap /dev/nvme0n1p2 && swapon /dev/nvme0n1p2 
mkfs.xfs -f /dev/nvme0n1p3 
```

*(The AI agent could confirm these operations with the user before executing, to avoid data loss.)*

### 3.2 Base System Installation (by Distribution)

Below we outline installation procedures for each distro, emphasizing how they can be automated/scripted. We assume network is available (Ethernet or Wi-Fi with appropriate steps to connect in installer).

#### Arch Linux (archinstall with JSON)

Arch Linux can be installed via the `archinstall` automated script. We prepare a **JSON configuration** that archinstall can consume (`archinstall --config=install.json`). This JSON defines disk layout, bootloader, packages, and other settings. For example:

```json
{
  "disk": "/dev/nvme0n1",
  "disk_layouts": {
    "/dev/nvme0n1": [
      { "mountpoint": "/efi", "size": "1 GiB", "partition_type": "primary", "filesystem": "vfat", "flags": ["boot"] },
      { "mountpoint": "swap", "size": "16 GiB", "partition_type": "primary", "filesystem": "linuxswap" },
      { "mountpoint": "/", "size": "100%", "partition_type": "primary", "filesystem": "xfs" }
    ]
  },
  "bootloader": "systemd-boot",
  "hostname": "kudu",
  "locale": "en_US.UTF-8",
  "keyboard_layout": "us",
  "timezone": "America/New_York",
  "additional-repositories": [ "multilib" ], 
  "packages": [
     "base", "linux", "linux-firmware", "vim", 
     "sudo", "networkmanager",
     "mesa", "nvidia-dkms", "nvidia-utils", "lib32-nvidia-utils", 
     "sway", "wayland", "xorg-xwayland", "pipewire", "wireplumber",
     "steam", "wine-staging", "wine-mono", "winetricks", "lutris", 
     "docker", "git", "aws-cli", "cuda", "cudnn"
  ],
  "user_accounts": [
    {
      "username": "alice",
      "password": "$6$...$...(hashed)...", 
      "groups": ["wheel"] 
    }
  ]
}
```

> **Explanation:** This config creates the three partitions with the specified filesystems, enables the `[multilib]` repository (needed for 32-bit Steam/Wine support), installs systemd-boot, sets up a user, and includes a selection of packages (more on package choices in Post-Install section). The JSON format is well-structured for an LLM to modify (e.g., the agent could add a package to the list or change a mountpoint if instructed). Archinstall’s schema covers many options, including toggling multilib and even audio server (PipeWire) in one go.

Using this config, the installation is a single command. Archinstall will partition the disk, install the base system, enable multilib repo, install packages, set locale, and even enable services like NetworkManager by default for a “base” profile. We include `nvidia-dkms` driver so it builds against the installed kernel, and the 32-bit driver (`lib32-nvidia-utils`) for Proton/Wine compatibility.

After install and reboot, Arch would come up with a minimal system. We will still need to configure the Wayland compositor autostart and some other tuning (covered in post-install).

#### Gentoo Linux (stage3 with systemd)

For Gentoo, we automate the traditional manual install. The key is to use the **Gentoo stage3 tarball with the systemd desktop profile**, which the user already did (the current system is “desktop profile/systemd stage3”). Steps to script:

* Boot a live environment (could be Gentoo ISO or any Linux ISO with Gentoo stage tarball access).
* Partition and format as above (script provided earlier).
* Mount the root (`/mnt/gentoo`) and EFI (`/mnt/gentoo/efi`), enable swap.
* Download the *stage3-amd64-desktop-systemd.tar.xz* from a Gentoo mirror.
* Extract stage3 into `/mnt/gentoo`. Then chroot into it (mounting `proc`, `sys`, etc. and using `chroot` or Gentoo’s `install-chroot` helper).
* Inside chroot: set up make.conf (e.g., use a suitable `COMMON_FLAGS` for Ryzen 9, `-march=znver3`), set `VIDEO_CARDS="amdgpu nvidia"` and `USE="X wayland"` to ensure graphics drivers build, and set ACCEPT\_LICENSE (Steam requires accepting some licenses).
* Set the profile to an appropriate systemd desktop profile (e.g., `eselect profile set default/linux/amd64/17.1/desktop/plasma/systemd` or similar desktop/systemd profile).
* Update @world to ensure everything matches the profile. E.g., if switching from stage3’s default, run `emerge --ask --update --deep --newuse @world`.
* Install kernel (user can choose gentoo-sources + manual config or use distribution kernel `sys-kernel/gentoo-kernel-bin` for quick setup), plus install `sys-kernel/linux-firmware`.
* Install NVIDIA drivers: `emerge --ask nvidia-drivers` (the package will auto-select correct driver series; ensure `VIDEO_CARDS` was set so it knows to build it). Also install `x11-base/xorg-server` (for Xwayland) and enable the `wayland` USE flag globally so that Wayland support is built into relevant packages.
* Install key system packages: `emerge --ask networkmanager dhcpcd sudo grub systemd-boot` etc. (Gentoo’s `systemd-boot` package can be used to install the bootloader).
* Enable multilib if not already: The chosen stage3 desktop profile likely has multilib enabled by default (Gentoo’s default AMD64 is multilib). If not, we must use a multilib profile because Steam **requires 32-bit libraries**. (If the system was no-multilib, one must switch profile and rebuild many packages with `ABI_X86="32"` support).
* Add the **steam-overlay** (Gentoo’s community repository for Steam and related packages). This can be done via `emerge --noreplace app-eselect/eselect-repository && eselect repository enable steam-overlay && emaint sync -r steam-overlay`. Then install `games-util/steam-launcher`. The Gentoo Wiki’s Steam guide lists all packages that need `abi_x86_32` enabled for Steam to work; an automation script could parse that list and add the `abi_x86_32` USE to those packages in `/etc/portage/package.use`.
* Install other desired software: e.g., `games-util/lutris`, `app-emulation/wine-staging` (Gentoo has multiple Wine packages: proton, staging, etc., which can be selected depending on needs), development tools (`gcc`, interpreters, etc.), and so on.
* Set root password, add a user (with `usermod` or edit `/etc/passwd`).
* Enable needed systemd services: `systemctl enable NetworkManager`. (Gentoo’s `emerge --config` or dispatch-conf might prompt for enabling openrc vs systemd services; since we use systemd, we’d do manual systemctl enabling).
* Finally, install bootloader: mount EFI and run `bootctl install`. Create a boot entry for Gentoo (specifying the EFISTUB kernel or using an initramfs – if using distro kernel, it may have an EFI stub).

Much of the above can be put into a single **bash script** to automate Gentoo install. An LLM could assist by generating or adjusting that script. For example, an excerpt:

```bash
# Inside Gentoo chroot
emerge --quiet --ask sys-kernel/gentoo-kernel-bin linux-firmware
emerge --quiet --ask nvidia-drivers xorg-server
# Ensure 32-bit libs for steam:
echo ">=media-libs/mesa-9999 abi_x86_32" >> /etc/portage/package.use/steamdeps
# (Repeat for other packages as per wiki) ...
eselect repository enable steam-overlay && emaint sync -r steam-overlay
emerge --quiet --ask games-util/steam-launcher wine-staging lutris
systemctl enable NetworkManager
```

This is just illustrative. After installation, Gentoo will require more manual tuning (e.g., building any out-of-tree kernel modules like NVIDIA, which the above used gentoo-kernel-bin to avoid manual kernel config). An AI agent could be very useful here to resolve compilation errors or adjust USE flags on the fly by analyzing emerge output.

#### openSUSE Tumbleweed (automated via AutoYaST or manual)

openSUSE Tumbleweed offers a graphical and text installer. For full automation, **AutoYaST** can be used: this is an XML-based configuration that the installer can consume to do an unattended install. Crafting AutoYaST manually is complex, but an AI agent could help modify a template. Alternatively, since the user has an AI assistant, one approach is to perform a normal Tumbleweed installation (which is relatively quick through the GUI, selecting Btrfs or XFS as needed, and choosing “No Desktop” or a minimal desktop since we plan to install Sway/others). The installer can add online repositories including NVIDIA’s driver repo.

Key points for Tumbleweed:

* Choose **Desktop: None (text mode)** during install, or XFCE minimal, then we’ll add our Wayland WM later. Do include the **“Development Tools”** pattern if doing software development (or these can be added with Zypper later).
* On the partitioning screen, select custom setup to use the pre-formatted XFS partition for root (if reusing the existing one) or create anew. openSUSE defaults to Btrfs+snapshots for root, which is nice for rollback, but XFS is acceptable if snapshots are not needed.
* Ensure the **“NVIDIA GPU”** option is selected if available (Tumbleweed’s installer can set up the NVIDIA repository). If not, after install, enable the official NVIDIA repo and install `nvidia-glG06` (or G05) package which includes the driver.
* The installer will by default install GRUB. If we want systemd-boot, we might switch later (openSUSE has experimental support, requiring manual steps).
* After first boot, use Zypper to install desired packages: `sudo zypper in sway wayland-utils xorg-xwayland NetworkManager docker aws-cli steam wine lutris pipewire-tools ...` etc. Tumbleweed has everything in its official repos. The `multilib` is handled via the `-32bit` packages on SUSE (installing Steam will pull those in, or one can add the `patterns-devel-32bit`).
* Enable services: `sudo systemctl enable --now NetworkManager docker`. Add user to `docker` group, etc.
* Setup the chosen WM: for example, install **sway** and create a user systemd service to launch sway on login, or configure a display manager. On openSUSE, one can use SDDM or GDM (though GDM brings GNOME dependencies). A simpler method: use `swayidle` and `swaylock` for session locking, and enable auto-login on tty for the user then launch sway. This can be scripted in `/etc/systemd/system/auto-sway.service` (an agent could write this unit file).

AutoYaST approach: An AI can generate an AutoYast XML with the above choices. However, given time, manual or semi-automated install with LLM guidance might be easier (the user could ask the agent step-by-step “Which option to choose here?” during the graphical install).

#### NixOS (configuration.nix)

NixOS is fundamentally configured via a single (or few) **Nix** files. We can install NixOS by booting the ISO, partitioning as outlined, and then creating a `/mnt/etc/nixos/configuration.nix` that describes the system. The power here is that we can predefine almost everything in that config, and running `nixos-install` will produce a fully configured system. This is extremely LLM-friendly: the agent can modify JSON-like nix expressions easily.

A sample **configuration.nix** snippet for our scenario:

```nix
{ config, pkgs, ... }:

{
  # Basic system settings:
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  fileSystems."/" = { device = "/dev/nvme0n1p3"; fsType = "xfs"; };
  fileSystems."/efi" = { device = "/dev/nvme0n1p1"; fsType = "vfat"; };
  swapDevices = [ { device = "/dev/nvme0n1p2"; } ];

  networking.hostName = "kudu";
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  # Users
  users.users.alice = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
    initialPassword = "plaintext_or_hash"; 
  };

  # Enable services and packages:
  services.openssh.enable = true;
  services.networking.networkmanager.enable = true;
  services.docker.enable = true;
  # Use greetd for login (minimal DM for Wayland):
  services.greetd.enable = true;
  services.greetd.autoLogin.user = "alice";
  services.greetd.autoLogin.session = "sway";

  # Desktop environment: none; enable sway WM
  programs.sway.enable = true;
  programs.sway.configFile = ''  # (Optionally, custom sway config content)
    bindsym Mod4+Return exec foot
    # ... other keybinds
  '';

  # Audio via PipeWire:
  services.pipewire.enable = true;
  services.pipewire.pulse.enable = true;
  services.pipewire.media-session.enable = true;

  # GPU drivers:
  hardware.opengl.enable = true;
  hardware.opengl.driSupport32Bit = true;
  services.xserver.videoDrivers = [ "amdgpu" "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    prime = { offload.enable = true; };
  };

  # Packages to install system-wide:
  environment.systemPackages = with pkgs; [
    vim git gcc glibc.multiStdenv
    # Dev and ML tools:
    python310 python310Packages.tensorflow cuda cudatoolkit cudnn
    # Gaming:
    steam lutris wineWowPackages.full winetricks vkBasalt
    # Cloud:
    awscli_2 terraform
    # Utilities:
    htop
  ];
}
```

> **Notes:** This configuration does the following – enables systemd-boot, mounts partitions, sets up a user, and crucially, **describes the entire system state**: we turn on Docker, set NetworkManager, enable `greetd` (a minimal TUI login that can launch sway), enable PipeWire for audio, and specify **both** AMD and NVIDIA drivers. The `hardware.nvidia.prime.offload.enable = true;` will set up the environment so that the NVIDIA GPU can be used for offloading (it configures `__NV_PRIME_RENDER_OFFLOAD` and related bits in X11, and for Wayland we would rely on proper DRM support). We include `glibc.multiStdenv` to get multilib support (so 32-bit Vulkan etc. work for Steam). We list a bunch of packages: Nix will ensure their dependencies (including 32-bit libs for Steam) are in place.

After writing this config (the AI can generate and validate it), we run `nixos-install`. NixOS will build the configuration, download binary substitutes for packages (if available from cache, which covers most), and set up systemd-boot with the generated config. On reboot, the system should be ready with sway available.

Any future change (like adding a new package or enabling a service) is just editing the Nix config and running `nixos-rebuild switch`. This fits perfectly with agentic orchestration: the user can instruct the LLM to “enable XYZ service” and it can modify the declarative config, which is much safer than imperative commands. (Declarative approach mitigates many systemd quirks and makes it easy to track changes or rollback if something breaks.)

#### Manjaro Linux (Calamares installer)

Manjaro’s installation is straightforward using its GUI (Calamares). For automation, Manjaro doesn’t have an official JSON like archinstall, but one could preseed Calamares if needed. However, given the presence of an AI agent, one approach is to let the user be guided by the AI through the graphical install (the agent can explain each step or even with OCR and input automation, though that’s experimental).

Post-install, Manjaro would have set up the GPU drivers via its Hardware Detection tool (likely installing `video-hybrid-amd-nvidia-prime` driver set). We would then: enable multilib (Manjaro enables `[multilib]` by default unlike Arch), and install packages via pacman. Most steps mirror Arch’s post-install, except the base system is already configured.

### 3.3 Post-Install Configuration and Tuning

After base installation, the following configurations are applied (these can be scripted or handled by the AI agent sequentially):

**User and Privileges:** Ensure the created user is an admin (in wheel or sudo group) and configure `sudoers` (Arch/Gentoo: add `%wheel ALL=(ALL) ALL`). In Gentoo, install `sudo` if not done and add user to necessary groups (`video`, `audio`, `wheel`, `docker`, etc.). On NixOS, we did that in config. This allows the AI agent to execute root-needed commands through the user account (with proper sudo password input).

**Network:** Enable NetworkManager (`systemctl enable --now NetworkManager`). Verify internet works. For Wi-Fi, ensure `wpa_supplicant` or iwd is installed (most distros include it with NetworkManager). The agent can assist in connecting to Wi-Fi by editing connection files or using `nmcli` if needed.

**Graphics Drivers:** This is crucial on this hybrid system:

* **AMD iGPU:** Use Mesa drivers. On Arch/Manjaro, `mesa` is installed by default (we included it in Arch package list). On Gentoo, the desktop profile includes Mesa; ensure `VIDEO_CARDS="amdgpu radeon"` (for older or just amdgpu if Vega 8). Verify Vulkan works on AMD: e.g. run `vulkaninfo | grep GPU`.
* **NVIDIA dGPU:** On Arch/Manjaro, we installed `nvidia-dkms` and `nvidia-utils`. The `nvidia-smi` tool should show the GPU is recognized. On Tumbleweed, ensure the proprietary driver is installed (if not, use `sudo zypper in nvidia-glG06 kernel-default-devel` and reboot). On Gentoo, ensure `nvidia-drivers` module is loaded (`lsmod | grep nvidia`). If Secure Boot is on, we’d have to sign the NVIDIA module or disable Secure Boot.
* **Hybrid Graphics (PRIME Offloading):** To use the NVIDIA GPU for rendering on demand (while the AMD iGPU drives the display), we configure Prime Render Offload. In Arch, that means installing `nvidia-prime` package or manually setting environment variables. For example, create a script `prime-run`:

  ```bash
  #!/bin/bash
  __NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia __VK_LAYER_NV_optimus=NVIDIA_only "$@"
  ```

  and put it in `$PATH`. Then running `prime-run <game>` will use the NVIDIA. Arch’s wiki explains this official method. On Tumbleweed, the package `nvidia-glG06` sets up `/usr/bin/prime-select` and similar tools. On Gentoo, after installing `x11-drivers/nvidia-drivers` with USE=“X” and `x11-misc/prime-run`, the offload should work similarly.

  *Wayland:* If using a Wayland compositor like Sway, full PRIME offload is slightly different (because there is no GLX layer in pure Wayland). However, games running via Xwayland can still use the above env vars. For native Wayland games, the driver will offload if the env vars are set (NVIDIA’s EGL implementation respects them). We ensure the compositor is launched with `WLR_RENDER_DRM_DEVICE` pointing to the AMD card (to avoid it picking the NVIDIA as primary). The agent can verify by checking `DRI_PRIME` status or simply launching a game with the env and seeing GPU usage (`nvidia-smi` output).

  In practice, many users on Sway/Hyprland with AMD/NVIDIA combos report success using the offload environment variables. An example test after setup: `glxinfo64 | grep "OpenGL renderer"` and `glxinfo32 | grep "OpenGL renderer"` (for 32-bit) with the env var toggled to confirm both AMD and NVIDIA renderers are accessible.

**Display Manager / Auto-starting Wayland**: Since we want to avoid full GNOME/KDE, we’ll set up a lightweight way to log in:

* The **simplest method** is to add an autologin on TTY for our user and start the compositor in the shell profile. For instance, on Arch, enable `agetty` autologin on tty1 and in `~/.bash_profile` put `exec sway`. This way, on boot it goes straight into Sway/Hyprland.
* Alternatively, use **greetd** (as in NixOS config above). Greetd with the `gtkgreet` or `tuigreet` allows a minimal login prompt that can start any Wayland session. It’s desktop-agnostic and scriptable.
* For a more traditional approach, one could install LightDM or SDDM and configure it to start a Sway session. However, these bring extra overhead. We assume the user, being power-user, is fine with autologin and manual locking.
* Ensure the compositor is set to launch on the correct GPU if needed. Usually, just running `sway` will use whatever DRM device is “first” (which on a laptop is typically the integrated). If needed, one can set the `WLR_DRM_DEVICES` env.

**Wayland Compositor Config:** We will configure the chosen WM:

* **Sway**: create `~/.config/sway/config`. We can mostly copy the default config and then tweak. Key tweaks for this setup: set **output scaling** if HiDPI, configure multiple outputs if an external monitor will be used (the NVIDIA GPU might handle external outputs if wired to it, which is common on Optimus laptops – this might require `WLR_DRM_DEVICES` ordering or using `swaymsg output ... dpms` commands to power the dGPU output).

* **Hyprland**: create `~/.config/hypr/hyprland.conf` with desired settings (the defaults are reasonable; we might adjust super key to open a launcher like `wofi` or `rofi`).

* **Shared**: Install a Wayland status bar like **waybar** (works with Sway and others). Also install **wl-clipboard**, **grim**/**slurp** (for screenshots in Wayland), and **mako** (notification daemon). These were not explicitly listed in packages above but should be added. An automation script might look like:

  ```bash
  # Arch example:
  pacman -S waybar wl-clipboard slurp grim mako wofi
  systemctl --user enable --now pipewire.service
  ```

  And Sway config entries to run waybar and mako: e.g. `exec waybar`, `exec mako`.

* **Input**: Configure keyboard layout (we set US in install), and touchpad settings. In sway, for example:

  ```
  input "1267:12398:ELAN0678:00 04F3:3196 Touchpad" {
      tap enabled
      natural_scroll enabled
  }
  ```

  The device identifier can be found via `swaymsg -t get_inputs`. An agent can insert the correct identifier once it reads the hardware.

**Audio:** By default, modern distros use **PipeWire** which handles both audio and Bluetooth. We installed pipewire where needed. Ensure `pipewire` and `wireplumber` (or PipeWire’s session manager) are running. On Arch/Manjaro, enabling the `pipewire.service` user unit (and `pipewire-pulse` for PulseAudio compatibility) is sufficient. In Gentoo, compile with `pipewire` USE flags and perhaps use `media-video/pipewire` package with the service units. The AI agent can verify sound by playing a test sound (e.g. using `aplay` on a WAV).

For **music production** needs, consider installing `jack2` and `helvum` or `pavucontrol` for audio routing. Set real-time priorities: add user to `audio` group, and perhaps configure `limits.d` for rt priorities if using JACK. If low-latency kernel is needed, Arch’s `linux-rt` or Tumbleweed’s `kernel-rt` can be installed (ensuring NVIDIA DKMS builds for it). This is optional; the user said “light music production” so the stock kernel + PipeWire should suffice (PipeWire provides low latency audio with the right config).

**Gaming and Compatibility Tools:** With drivers in place, finalize the gaming stack:

* **Steam:** On Arch, we installed the `steam` package (which is the 64-bit Steam runtime launcher plus it pulls in 32-bit libraries from `multilib`). On first run, Steam will update itself. The AI agent can automate the first-run by launching Steam in a `nohup` and waiting for it to install updates.
* **Proton GE:** The user wants to use custom Proton (GloriousEggroll). Rather than manually downloading, use a helper like **ProtonUp**. On Arch, `protonup-qt` is in AUR; on any distro, the agent could use `pip install protonup-cli` to get a CLI tool to install Proton-GE into Steam’s compatibilitytools.d. This could be scripted. For example:

  ```bash
  pip install --user protonup-cli
  ~/.local/bin/protonup -q install --proton-ge --latest
  ```

  This would download the latest Proton-GE release. The agent can verify by checking `~/.steam/root/compatibilitytools.d/` directory.
* **Wine (non-Steam games):** We installed Wine (and on Gentoo, perhaps Wine-Proton or Wine-Staging). Configure wineprefix with `winecfg` (the agent could auto-create a 64-bit prefix and enable staging optimizations). Install **Winetricks** (we did) for any game-specific tweaks (the agent can use winetricks to install corefonts, dxvk, etc. if needed).
* **Lutris:** installed to manage non-Steam games and emulators. The user can use it normally; the agent can also assist in downloading community install scripts for games via Lutris APIs.
* **DXVK/VKD3D:** These come with Proton, but for system Wine, ensure DXVK is present. On Arch, `dxvk-bin` AUR or using winetricks to get dxvk. On Gentoo, `vulkan use` flag and `app-emulation/dxvk` package.
* **GPU overclock or tweaks:** If desired, install `greenwithenvy` for Nvidia control or use nvidia-smi commands for powerMizer. Could also set `nvidia-settings -a "[gpu:0]/GpuPowerMizerMode=1"` to prefer max perf when on AC, etc.

**Development tools:** We ensure compilers and libraries are installed:

* GCC, Clang, Python, Node.js, Java (as needed) – likely installed via patterns or our package list. The AI agent can install any missing toolchain on the fly upon request.
* IDEs or editors: user may install VS Code or PyCharm. On NixOS, one can use `nix-env` or `environment.systemPackages` for that, or use Flatpaks. On Arch, use `pacman -S code` (for VS Code OSS) or `yay -S visual-studio-code-bin` for MS version if needed.
* Cloud CLI: We installed `aws-cli` (v2) and `google-cloud-sdk` (if needed, can be installed similarly). Verify they work (agent can run `aws --version`).
* Containerization: Docker was installed and enabled. Test with a hello-world container. Alternatively or additionally, **Podman** could be used (Tumbleweed includes it by default). If using Podman, enable usermode and lingering if needed. We stick to Docker as requested.

**AI/ML tools:** With CUDA and cuDNN in place, test a simple TensorFlow or PyTorch program to ensure it sees the GPU. For instance:

```python
import torch
print(torch.cuda.is_available(), torch.cuda.get_device_name(0))
```

The agent can run this in a python interpreter. If not, perhaps driver issues or missing `export LD_LIBRARY_PATH` for CUDA. On NixOS, it’s handled via environment. On Gentoo, ensure `cuda` USE flag and environment set in `/etc/env.d/`. On Arch, the `cuda` package provides `/opt/cuda` and we may add `export PATH=/opt/cuda/bin:$PATH` for nvcc if needed.

Consider installing newer frameworks or bleeding-edge versions:

* The user mentioned *experimental AI toolchains*. This could mean things like nightly builds of PyTorch, or frameworks like JAX. On Arch, one can use pip inside venv (the agent can do that) or AUR packages for pytorch-nightly. NixOS can pin specific git versions in configuration (LLM can help edit a Nix overlay).
* Ensure that **GPU passthrough experiments** (if any) are possible: This laptop’s dGPU could in theory be passed to a VM. For that, we’d need virtualization enabled (install QEMU/KVM, add `intel_iommu=on` or `amd_iommu=on` to kernel params for IOMMU). The agent can add kernel parameters in the bootloader config if asked. Also, on systemd-boot, editing `/efi/loader/entries/*.conf` to add iommu is straightforward.

**Automation & Hooks for LLM:**

Throughout the above, we envision the AI agent assisting at each step. To facilitate this, we implement a few hooks:

* **Logging and State:** Enable `ttyrec` or `script` command logging of installation steps so the agent can “remember” what was done by reading logs. (For instance, the agent can open the pacman log or emerge log to see what’s installed, and decide next actions.)

* **JSON Task List:** We maintain a `tasks.json` file that the agent updates. For example, after base install, `tasks.json` might contain:

  ```json
  { "post_install": [
      {"action": "enable_service", "name": "docker"}, 
      {"action": "run_cmd", "cmd": "protonup -q install --proton-ge --version=8.3"}
  ] }
  ```

  A simple Python or shell program can parse this and execute tasks in sequence. The agent can modify this file in response to user requests (“Install the latest Proton-GE” adds the second action).

* **Systemd unit for initial config:** We can create a one-shot systemd service that runs on first boot, which executes a script of final setup commands (like finishing touches that couldn’t be done in chroot). This script could call out to an online AI API if needed (though that raises complexity of embedding API keys etc.). More practically, the agent will likely connect via SSH or through the user session and continue configuration interactively.

* **Periodic updates:** Since it’s rolling release, updates are frequent. We can set a **systemd timer** to check for updates weekly. For Arch, an LLM could decide to hold certain updates if it knows of issues, but that’s advanced. Simpler: schedule `pacman -Syu` (or `emerge --sync && emerge -uUD @world` for Gentoo, or `nix-channel --update && nixos-rebuild` for NixOS) with user confirmation. Possibly integrate a hook to notify the user (e.g., via a desktop notification using `mako` or email) and only update on approval.

Below is an **example hook script** that could be used after major package installations to verify GPU usage via AI:

```bash
#!/bin/bash
# post-install-checks.sh: Run diagnostics and ask AI agent for analysis.
echo "Running GPU diagnostics..."
vulkaninfo > /tmp/vulkaninfo.txt 2>&1
glxinfo -B > /tmp/glxinfo.txt 2>&1
nvidia-smi -L > /tmp/nvidia.txt 2>&1
# Send these logs to AI agent for analysis (this is conceptual; implement via API or file exchange)
echo "Logs saved. Please review GPU setup."
```

The idea: the agent can read `/tmp/vulkaninfo.txt` and confirm both GPUs are recognized (it might look for "Renderer: AMD Radeon" and "NVIDIA" in the output). If something is wrong (e.g., missing 32-bit Vulkan on Gentoo causing Steam to fail), the agent can deduce the missing piece (perhaps from `glxinfo32` errors) and then fix (install the needed library).

### 3.4 Final Steps and Testing

At this stage, the system should be fully configured. We perform a series of tests to ensure each requirement is met, with the AI assisting in troubleshooting:

* **Wayland session test:** Open a few terminals, ensure keybindings (e.g., Super+Enter for terminal) work. Toggle full-screen (usually F11 or a keybinding) and multi-window layouts. The tiling WM should allow moving and resizing via keyboard – test those shortcuts. The agent can adjust the config if the user says “I want Mod+Shift+Enter to launch Firefox” – it can edit the config file accordingly and reload the WM (`swaymsg reload` or Hyprland’s equivalent via `hyprctl reload`).
* **Gaming test:** Launch Steam, install a small free game or a DXVK test (like Heaven benchmark). Run with `prime-run` (or however offloading is done) and monitor `nvidia-smi` to ensure the dGPU is being utilized. If performance is poor, check that `glxinfo` on the game shows “NVIDIA” renderer. The AI can parse fps or logs to detect if perhaps the game fell back to software rendering (then we’d troubleshoot missing libs or driver issues).
* **Development test:** Compile a simple CUDA sample (`nvcc` from CUDA toolkit can compile a vectorAdd sample). Use Docker to run an Ubuntu container and compile something to ensure Docker + GPU works (with nvidia-container-toolkit if desired, though setting that up might involve installing it and configuring daemon.json).
* **Cloud test:** Use `aws s3 ls` with proper credentials (would need user to configure credentials – could use AWS Vault). Ensure internet connectivity and DNS are fine.
* **Music/audio test:** Install a DAW like `audacity` or `ardour` (if desired) and test JACK via PipeWire (PW can provide a JACK sink). Or simpler: play an audio file with `aplay` or `paplay` and confirm sound. The agent can adjust volume or detect if audio device is muted, etc.
* **Power management:** Since this is a laptop, ensure TLP or power management is set. Possibly install `tlp` on Arch or enable `power-profiles-daemon`. On hybrid graphics, ensure the dGPU turns off when not in use. The NVIDIA driver typically will power it down when idle (check `cat /proc/driver/nvidia/gpus/0/power` status). If not, we can enable NVIDIA’s runtime power management (`options nvidia NVreg_DynamicPowerManagement=0x02` in a modprobe conf). The AI can add that config if battery life is an issue.
* **Kernel updates:** On rolling release, new kernels come often (e.g., 6.x to 6.y). We ensure DKMS builds the NVIDIA module after updates (Arch handles this via hooks). On NixOS, new generations include the driver. On Gentoo, an agent could detect a new kernel and auto-emerge `@module-rebuild`. Possibly set up **ocl-icd** for OpenCL if needed for ML or video encode support (NVENC – on Arch `nvidia-utils` already provides NVENC, test with `ffmpeg` encoding).
* **Bleeding edge AI tools:** To accommodate rapid changes, we might use containerized environments for things like new AI frameworks. E.g., use Docker images for PyTorch nightly. The system is ready for that (with Docker + NVIDIA). The agent can pull an image `docker run --gpus all --rm nvcr.io/nvidia/pytorch:latest` to test quickly.

Finally, document the installed system state (the agent could generate a Markdown report of installed packages and config for the user’s records), and maintain the citations of any non-obvious configurations in comments (for example, in the Nix config or shell scripts, include comments referencing ArchWiki or Gentoo Wiki for why a certain option is set – this helps future maintainers and even the AI itself to recall context).

With this plan executed, the user will have a **fully up-to-date, rolling-release Linux** on the Kudu6, leveraging both GPUs effectively, ready for gaming (Steam/Proton including Proton-GE for the latest fixes), robust software development in multiple languages, cutting-edge AI/ML capabilities with CUDA, cloud management tools, and a lightweight yet powerful Wayland desktop environment. The entire setup is defined in code/config files, making it easy to tweak via ChatGPT or other agents in the future.
