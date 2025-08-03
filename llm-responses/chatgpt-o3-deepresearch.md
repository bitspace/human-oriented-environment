# Top 5 Rolling-Release Linux Distributions for an AI/Gaming Laptop

The target system is a high-end System76 Kudu6 laptop (AMD Ryzen 9 5900HX with integrated Vega GPU, plus Nvidia RTX 3060 dGPU, 64GB RAM) with UEFI, systemd init, and an XFS root filesystem (no Btrfs/ZFS). Below we identify **five** Linux distributions that best meet the requirements, followed by recommendations for **five** Wayland-capable window managers, and finally a **step-by-step installation & configuration plan** optimized for automation via an LLM agent.

## Best-Suited Rolling-Release Distributions

Each of the following distros is rolling-release (or similar), uses systemd, supports systemd-boot, and provides robust ecosystems for development, gaming, and AI/ML work:

### 1. **Arch Linux** – Cutting-Edge and Pacman/AUR Ecosystem

Arch Linux is a minimal rolling distro that delivers the latest packages quickly after upstream release. It uses the `pacman` package manager and offers a huge official repo plus the Arch User Repository (AUR) for community-contributed build scripts. This means virtually any development tool or niche software (e.g. Proton-GE, CUDA, cloud CLI, etc.) is available either as a binary package or via AUR. Arch uses systemd as init by default and works seamlessly with systemd-boot. It requires a manual installation (or use of the `archinstall` script), but the Arch Wiki documentation is excellent for automation scripts. Arch is less curated than some others, so occasional breakages can happen, but it’s favored by advanced users who want full control and up-to-date software. For our use-case, Arch provides: latest kernels and drivers (great for new hardware and AI frameworks), easy installation of gaming tools (Steam, Wine, Lutris, etc.), and a straightforward way to install development languages and libraries. The active community ensures guides for things like NVIDIA/AMD hybrid graphics, Wayland issues, and other tweaks are readily available.

### 2. **Gentoo Linux (with Binary Package Support)** – Ultimate Flexibility via Portage

Gentoo is a source-based rolling distribution known for extreme customization. By default, all packages are compiled from source with user-defined USE flags and compiler optimizations. This yields a highly optimized system at the cost of long build times. **However, Gentoo now offers an official binary package repository (since late 2023) for many popular packages**. This hybrid approach means you can fetch pre-compiled binaries for large packages (e.g. LibreOffice, KDE/GNOME, Docker, etc.) and compile others from source as needed – a balance that addresses the concern of slow builds causing automation tools to lag or crash. Gentoo’s package manager is **Portage** (`emerge`), which is very powerful and supports mixing binary packages with source builds seamlessly. Gentoo is rolling-release and very up-to-date, though its “stable” vs “testing” branches allow pinning critical systems on stable and selectively using \~amd64 (testing) for latest versions. Crucially, Gentoo fully supports **systemd** (you can choose a systemd profile instead of OpenRC), satisfying the init requirement. It also supports UEFI and systemd-boot (manual configuration). For our needs, Gentoo shines if we want fine-tuned control – e.g., building Python with specific options, optimizing the kernel for our hardware, or applying custom patches. The **Portage** ecosystem has a wide range of development tools and libraries; anything not in the main tree can often be found in **Gentoo overlays** or built from source. Gaming support is decent (Steam is available via the distribution or Flatpak, and Proton/Wine can be built with custom USE flags). Gentoo’s flexibility extends to AI/ML: you can install frameworks via Portage or just use pip/Conda for Python packages in a controlled environment. Overall, Gentoo (with binary packages enabled) offers a highly customizable, automation-friendly environment – you can declaratively define make.conf, package.use, etc., and an LLM agent can edit those text configs to orchestrate the system setup.

### 3. **openSUSE Tumbleweed** – Stable Rolling Base with Strong Tooling

openSUSE Tumbleweed is a **fully rolling-release** distro known for its robustness and thorough testing process. It provides **frequent updates** (snapshots are typically released several times per week) but each update passes automated quality assurance to ensure system-wide consistency. This makes Tumbleweed one of the most stable rolling distros in practice. Tumbleweed uses the `zypper` package manager (RPM packages) and has a very large repository of software, including all major development languages, libraries, and tools. It uses systemd as init and supports UEFI; by default it installs with GRUB, but as of late 2023 **experimental support for systemd-boot** is available in the installer. You can use the graphical YaST installer or an automated AutoYaST profile to set up a systemd-boot + XFS configuration. Tumbleweed is particularly strong for our use-case because it offers **latest kernels and drivers** (good for new GPUs and frameworks) while maintaining enterprise-level stability. It also embraces modern tech like Btrfs snapshots with Snapper by default (though you can opt for XFS as in our case). For **gaming**, openSUSE has you covered: Steam, Lutris and Wine are in the repos or easily added (and proprietary NVIDIA drivers are available via the official repository). Tumbleweed’s official stance is to provide the *latest gaming-related software* for a smooth experience. For development, openSUSE’s packages cover all listed languages (Python, C/C++, Rust, Java, Haskell, etc.), and its Open Build Service (OBS) lets you access additional community packages if needed. Cloud CLI tools (AWS, Azure, GCP SDKs) are either packaged or installable via pip or other language-specific managers. While not as bleeding-edge as Arch, Tumbleweed strikes a good balance with **automation-friendly tools**: for instance, YaST and AutoYaST can be leveraged by an LLM to script configurations, and many settings can be managed via plain text in `/etc` that an LLM can edit. In summary, openSUSE Tumbleweed is an excellent choice when you want rolling updates with a safety net, a rich binary package ecosystem (no compiling needed), and a systemd-based setup that supports our hardware and use-cases out-of-the-box.

### 4. **NixOS (Unstable Channel)** – Declarative Configuration, Reproducible Environment

NixOS is a unique rolling (or more precisely *model-based*) Linux distribution built around the Nix package manager and a purely declarative configuration model. By default NixOS has periodic stable releases, but using the **unstable channel** gives you a continuously updated stream of the latest packages, similar to a rolling release. NixOS stands out for its **reproducible and automation-friendly configuration**: the entire system state (packages, services, settings) is defined in a single or set of `.nix` config files, which an LLM agent can easily edit to orchestrate the system. With Nix, if you specify “I need Python, CUDA, PyTorch, and NVIDIA driver version X”, the system builds exactly that environment, no manual tinkering. This is great for consistency and for complex setups like AI research environments. NixOS uses systemd as the init system by default, meeting our requirement. It fully supports UEFI and systemd-boot (in fact, enabling systemd-boot is just a line in the config). The **learning curve** is steep, but the NixOS community and wiki provide lots of examples. Using NixOS unstable gives you very up-to-date software (often as cutting-edge as Arch) – but note that the unstable channel can occasionally have breakages before a fix is merged (testing is lighter than Tumbleweed’s). The **declarative approach mitigates many issues** because you can roll back any failed update with one command, and the configuration is source-controlled. For our needs: NixOS has packages or definitions for all common development tools and can seamlessly pull in obscure ones from Nixpkgs. Python/Rust/Java/etc development is well-supported (you can even have multiple compiler versions isolated). Gaming on NixOS is possible – Steam and Proton are packaged (one must enable 32-bit support via `hardware.opengl.driSupport32Bit` option and use Steam’s runtime or Steam-run wrappers). There are community modules for gaming tweaks (e.g. setting up gamescope or MangoHUD). NVIDIA proprietary drivers are supported via configuration (`services.xserver.videoDrivers = [ "nvidia" ]` plus setting `nvidiaSettings` options). For AI/ML, you can pin specific versions of CUDA or frameworks in your config to avoid environment drift, which is a big plus when experimenting with LLM tooling. In sum, NixOS (unstable) offers an **LLM-friendly** environment: an agent can modify the Nix configuration (a single source of truth) to install packages or change settings, then rebuild the system declaratively. This ensures automation steps are repeatable and avoids “drift” that could confuse the AI. It’s a forward-looking choice ideal for users comfortable with a bit of functional programming and who value reproducibility.

### 5. **Manjaro Linux** – User-Friendly Arch with Added Stability

Manjaro is an Arch Linux derivative that aims to be to Arch what Ubuntu is to Debian – i.e., more user-friendly and slightly more stable by **buffering updates**. Manjaro is a rolling release, but unlike Arch (which updates packages immediately), Manjaro holds new packages for additional testing and integration, then releases them in batches. This means you get the Arch ecosystem (pacman, AUR support, latest kernels) with a short delay that often avoids the most bleeding-edge breakages. Manjaro uses systemd and can be set up with systemd-boot if desired (Manjaro’s default is GRUB, but community documentation exists for switching to systemd-boot). It fully supports UEFI installations. For our purposes, Manjaro offers the same huge range of software as Arch – its official repos cover most needs, and the AUR can be enabled for anything else. Out of the box it provides nice extras: an installer that can partition and format with XFS easily, automated hardware detection (it will install proprietary NVIDIA drivers during setup if you opt in), and pre-configured kernels with easy switching via `mhwd` (Manjaro Hardware Detection). This can be attractive for an AI/Gaming laptop – you could, for example, easily install a real-time kernel or the latest bleeding-edge kernel for better hardware support using Manjaro’s tools. Gaming is well-supported (Manjaro even has a “Gaming” edition); things like Steam, Lutris, and Wine are either pre-installed or one pacman command away. Development tools are identical to Arch’s offering. Manjaro also has an active community and documentation, which an LLM could leverage. The trade-off is that Manjaro’s slight divergence from Arch (custom repos, different default package versions) means the Arch Wiki must be used with caution (though 95% of it still applies). If ease-of-setup and a bit of extra stability are desired, Manjaro is a solid choice. In an automated context, using Manjaro could save time in base installation and driver setup (letting the installer handle NVIDIA driver, locales, etc.), allowing the LLM agent to start higher-level configuration sooner. Essentially, Manjaro gives you Arch’s advantages with a quicker initial ramp-up and a safety net of tested rolling updates.

*(**Note:** Another Arch-based option is **EndeavourOS**, which is very close to vanilla Arch with an easy installer. EndeavourOS might be used to get an Arch system quickly, and then treat it as Arch. We include Manjaro here as it provides a distinct approach with the update buffer and defaults that can benefit a laptop user. Both are compatible with the Arch ecosystem preferences.)*

---

**Why Not Others?** We focused on distros aligning with the user’s preferences (portage or pacman style, systemd, rolling). Honorable mentions include **Void Linux** (rolling, very stable, but it uses runit by default and XBPS package manager – not systemd unless manually configured), **Solus** (rolling and user-friendly, systemd-based, but smaller ecosystem), and **Fedora Rawhide** (the development branch of Fedora, effectively rolling – it has cutting-edge packages and systemd, but it’s less a daily-driver and more for testing). Ubuntu/Debian-based distros were excluded since they are not rolling and would lag in the fast-moving AI/ML tooling space. The above five choices should cover the needs for fresh packages, reliability, and ease of automation.

## Top 5 Wayland-Compatible Window Managers/Compositors (for Scriptable, Minimal DE)

To avoid heavy desktop environments like GNOME or KDE (as requested), we recommend these five lightweight **Wayland** compositors/window managers. Each supports a scriptable configuration, is well-documented, and works with tools like swaymsg, hyprctl, etc., making them suitable for automation and control via LLM:

* **Sway** – A mature tiling compositor that is a *drop-in replacement for i3* on Wayland. Sway is stable, highly configurable via a plain text config (just like i3’s syntax), and has a large community. It supports an IPC interface (`swaymsg`) which allows external scripts (or an AI agent) to control windows, workspaces, and more. Sway has no desktop bloat – you assemble your environment with separate status bar (e.g. `waybar`), app launcher (`wofi` or `rofi`), etc., which fits the modular “scriptable” requirement well. Documentation is extensive (man pages, Arch Wiki, etc.), making it easy for an LLM to find configuration details. **In short:** Sway is a top choice for a tiling Wayland WM, offering i3-like productivity in Wayland and proven reliability.

* **Hyprland** – A modern dynamic tiling Wayland compositor written in C++ with eye-candy. Hyprland is known for its flashy visuals (animations, blur, rounded corners) and flexible tiling layouts. It supports both tiling and floating windows (dynamic layout), tabs, and a range of customization options. The configuration is in one file (`hyprland.conf`), which can be reloaded on the fly; it also has an IPC (`hyprctl`) to automate tasks. Hyprland’s **documentation is very good** (the project maintains a wiki covering all config variables), which is beneficial for an LLM-driven setup. This compositor is still young (under active development), but it’s become quite popular. It strikes a balance between being scriptable and offering a polished look. If you want a flashy UI without a full DE, Hyprland is worth considering (just note that NVIDIA support is unofficial – on our hybrid GPU system, using the AMD iGPU for output and offloading to NVIDIA might be the way to go, regardless of WM choice).

* **river** – A minimal **dynamic tiling** Wayland compositor inspired by dwm, bspwm, and xmonad. River’s approach to configuration is unique: instead of a static config file, you write an *external executable (script or program)* that river runs on startup to configure keybindings and settings. This means you can use shell script or any language (via the provided `riverctl` commands) to set up your environment. At runtime, you (or an automated script) can use `riverctl` to control windows and change settings dynamically, which is very automation-friendly (it’s essentially an IPC interface). River aims for simple, predictable behavior with a small core, and lets the user extend it with their own “layout generators” or scripts. It’s well-documented on the Arch Wiki and in its man pages. For an LLM agent, river’s design is appealing: the agent could generate a new init script or call `riverctl` commands to reconfigure the WM on the fly. River doesn’t include any panel or launcher by itself (you integrate your own), keeping it lightweight. This WM is great if you want a tiling environment that is **literally script-driven**.

* **Wayfire** – A **3D floating** Wayland compositor that is **plugin-extensible**, reminiscent of Compiz in spirit. Wayfire focuses on providing a lightweight yet flashy compositor where windows are stacked (not tiled by default, though a tiling plugin exists) and you can have cool effects if desired. It’s built on wlroots and aims to be \*\*customizable and extendable without sacrificing appearance】. While Wayfire isn’t a tiling WM, it can be made keyboard-friendly and scriptable: it has a configuration file (`~/.config/wayfire.ini`) for core settings and uses plugins for additional features (there are plugins for window rules, tiling, etc.). You might use Wayfire if you prefer a classic stacking window manager (like openbox style workflow) but on Wayland and with the option of fancy effects. Documentation exists on the official site and community wikis. It might require a bit more effort to automate (since the config is static and it doesn’t have a rich IPC for live control), but editing the ini and sending signals (or just restarting the WM) is something an LLM can handle. Given the requirement of a “scriptable, automation-friendly graphical environment,” Wayfire qualifies through its simple config and modular design. It’s a good choice if you need a full-featured compositor that remains lighter than GNOME/KDE.

* **Labwc** – A **window-stacking** (traditional floating) Wayland compositor inspired by Openbox. Labwc (“Lab Wayland Compositor”) is very lightweight and adheres to the Openbox approach: no built-in panel or widgets, just window management. It supports keybindings, window rules, and uses the Openbox-like **XML configuration for themes and settings**, which will feel familiar if you’ve configured Openbox. Notably, Labwc explicitly **does not include animations or fancy effects** – it’s a no-frills, minimal compositor that “simply stacks windows”. This makes it extremely stable and predictable. For automation, Labwc doesn’t have an IPC mechanism like sway or river, but its config files are straightforward to edit (and an LLM could tweak XML or use `labwc` command-line options). It relies on external programs for things like panels or screenshots (meaning you can pick and script those separately). Labwc is a great option if you want a classic floating WM experience on Wayland, in a package that is small and easy to comprehend. It’s well-documented via its README and man pages, and being so minimal, there’s less to go wrong. In an LLM-managed setup, Labwc could be used as a stable base where the agent manages the supporting programs (like `waybar` for a panel, etc.) around it.

*(The above choices ensure Wayland support. If X11 was acceptable, many more options (bspwm, i3, awesome, etc.) would open up, but we focused on Wayland-compatible ones. Other notable Wayland WMs include **dwl** (a very minimal dwm-inspired compositor, configured in C source – ultra-light but harder to live-configure without recompiling) and **Niri** (a new Rust-based compositor with an innovative “infinite horizontal scrollable desktop” tiling paradigm). Depending on user interest, those could be explored, but the five listed are more established.)*

## Step-by-Step Installation and Configuration Plan (Optimized for LLM Automation)

Below is a general installation and configuration workflow that can be applied or adapted to any of the above distributions. The plan emphasizes automated, scriptable steps so that after the base system is installed, an LLM agent (e.g. running via SSH or a local console) can take over and configure the system consistently.

### **1. Pre-Installation Preparation**

* **Choose a Distribution & Acquire Installer**: Decide on one of the recommended distros (Arch, Gentoo, Tumbleweed, NixOS, Manjaro) based on your priorities. Download the latest installation ISO or image. For an automated install, use any “netboot” or minimal image if available (to avoid unnecessary packages).
* **Backup and Plan Disk Layout**: Since the system currently has an XFS root on an EFI system, ensure you have a backup if this is an existing install. Plan the partitioning scheme: you’ll need an EFI System Partition (ESP) (typically FAT32) for systemd-boot, and an XFS partition for root `/`. If starting fresh, create at least two partitions: e.g., 512 MB FAT32 for EFI, and the rest as XFS for `/`. (You might also allocate a swap file or partition as needed for your workload, though with 64GB RAM, swap is less critical – a 4–8 GB swap file is still useful for hibernation or safety).

### **2. Install Base System**

Perform a base installation of the chosen distro with minimal packages, using **UEFI** mode and **systemd**:

* **Boot Installer in UEFI Mode**: Ensure the laptop boots the USB in UEFI mode (disable Legacy/CSM). This is crucial for systemd-boot to work.
* **Partitioning**: Create partitions as planned. For example, using `gdisk` or installer’s partitioner:

  * EFI System Partition (mount at `/boot` or `/efi`, FAT32, set the type to EF00).
  * Root partition (mount at `/` with XFS). Optionally a separate home or others as needed (XFS or your choice, but given XFS requirement, use XFS where appropriate).
  * If using NixOS, you could use a single XFS for `/` (NixOS doesn’t demand special partitions unless using separate `/boot`). For Gentoo or Arch, XFS is fine for root (ensure the Live ISO kernel has XFS support – all listed distros do). For openSUSE, if using the guided setup, select XFS for root instead of Btrfs.
* **Formatting**: Format the ESP as FAT32. Format root as XFS: e.g., `mkfs.xfs -f /dev/<root-partition>`. (If reusing an existing XFS partition, you can skip formatting to preserve data, but usually a clean format is desired).
* **Mounting**: Mount the root (`/mnt` for Arch, Gentoo, etc., or as directed by installer), and mount the ESP at `/mnt/boot` (or `/mnt/efi` depending on distro conventions; Arch and Gentoo typically use `/boot` for the ESP when using systemd-boot, since the kernel and bootloader can reside together). In NixOS manual install, mount root to `/mnt` and `mkdir /mnt/boot && mount /dev/<ESP> /mnt/boot`. In openSUSE’s installer, mark the FAT32 partition as `/boot/efi`.
* **Base System Install**:

  * *Arch/Manjaro:* Use `pacstrap` (or the Manjaro architect installer) to install the base system. Include minimal packages: e.g. for Arch: `pacstrap /mnt base linux linux-firmware vim networkmanager` (plus any essentials). Arch’s `base` includes systemd by default, and systemd-boot comes with the `systemd` package. Manjaro’s installer will do similar automatically.
  * *Gentoo:* Stage 3 tarball extraction. Choose a **systemd stage3** tarball (Gentoo provides separate stage3 archives for OpenRC vs systemd – use the one with systemd). Follow the Gentoo Handbook steps in the chroot: set `eselect profile` to a systemd profile (e.g., `default/linux/amd64/17.1/desktop/gnome/systemd` for a desktop with systemd). Install the `gentoo-sources` kernel or `vanilla-sources`, and ensure `sys-kernel/dracut` (for initramfs) and `systemd` are emerged. Also, in Gentoo’s `/etc/fstab`, set the ESP to mount at `/boot` with vfat.
  * *openSUSE Tumbleweed:* Use the graphical or text installer (which can also be automated via AutoYaST XML). When prompted, choose **“Expert Partitioner”** to ensure XFS is selected for root and that **“Boot Loader >** is set to systemd-boot (there is now an option for systemd-boot in newer installer versions; if not visible, you might select “no bootloader” and plan to install systemd-boot manually later). Minimal installation: select a lightweight pattern or just the base system (you can skip installing a desktop since we’ll add a WM later). The installer will handle installing `systemd-boot` if you chose it, or you can do it manually post-install.
  * *NixOS:* After mounting, generate config with `nixos-generate-config --root /mnt`. Then edit `/mnt/etc/nixos/configuration.nix`: set `boot.loader.systemd-boot.enable = true;` and `boot.loader.efi.canTouchEfiVariables = true;` (this instructs using systemd-boot on the ESP). Also set `fileSystems."/"` with `fsType = "xfs";`. Ensure `services.openssh.enable = true;` if you want SSH for the LLM agent. You can also pre-add your user in this config. Then run `nixos-install`. This will build the system per config and install systemd-boot automatically.
  * **Networking:** All distros – ensure the base install includes a network service (e.g. NetworkManager or systemd-networkd + wpa\_supplicant) so that after first boot, internet is available for the LLM agent to install things. For Arch, installing `networkmanager` package and enabling it (`systemctl enable NetworkManager`) in chroot is a quick way. In Gentoo, you might use NetworkManager or dhcpcd; in NixOS just set `networking.networkmanager.enable = true;` in config.
* **Install systemd-boot (if not already done):** If the distro’s installer did not automatically set up systemd-boot, you need to install it manually from a chroot:

  * Mount/chroot into the new system (`arch-chroot /mnt` for Arch, or Gentoo chroot steps). Verify that `/boot` is the ESP mount. Then run `bootctl install`. This copies the bootloader and creates the boot entry in NVRAM. For example, on Arch:

    ```bash
    # bootctl install
    ```

    This should output that systemd-boot was installed to EFI and a boot entry was created (called “Linux Boot Manager”).
  * On Gentoo, after emerging systemd, the `bootctl` command is available (provided by systemd package). You’d run the same `bootctl install`. (Make sure `efivars` kernel module is loaded or `/sys/firmware/efi/efivars` is present, indicating you’re in UEFI mode).
  * If `bootctl` fails to create entries (it might inside a chroot for some systems), you can create a manual EFI entry using `efibootmgr` or simply rely on copying the EFI files and use the firmware’s boot menu to add it. Typically, though, `bootctl install` works if chrooted in UEFI mode.
  * After that, configure the bootloader entries: Create `/boot/loader/entries/` entry files if needed. On Arch, the mkinitcpio and kernel install should have created ones (if using `arch-install-scripts`). If not, manually create an entry like `/boot/loader/entries/arch.conf` with:

    ```
    title   Arch Linux  
    linux   /vmlinuz-linux  
    initrd  /initramfs-linux.img  
    options root=PARTUUID=<YOUR-ROOT-PARTUUID> rw  
    ```

    (Replace with actual PARTUUID from `blkid` and adjust kernel file names if different, e.g., gentoo uses `/vmlinuz` from your kernel package, NixOS creates its own entries automatically on rebuild).
  * Set `/boot/loader/loader.conf` to default to your entry (e.g., `default arch.conf`) and optionally a timeout.
* **Finalize and Reboot**: Exit chroot, unmount partitions, and reboot. The system should come up via systemd-boot into your new minimal OS. On first boot, verify that you get to a login (console TTY). If you installed an SSH server and network, you can also try SSHing in. At this point, you have a bare-bones system with systemd, systemd-boot, and network – ready for higher-level configuration.

### **3. Post-Install: Set up for LLM Agent Automation**

Now that the base is installed, we prepare the environment so an LLM agent (like Claude or GPT-4 in CLI form) can connect and perform automated setup tasks:

* **Create a User with Sudo**: Log in as root (or use the initial user on some distros) and create a primary user account (if not done by installer). For example, on Arch/Gentoo:

  ```bash
  useradd -m -G wheel -s /bin/bash myuser  
  passwd myuser  
  ```

  Then edit sudoers (install `sudo` if not already) to grant `%wheel ALL=(ALL) NOPASSWD: ALL` (or at least normal sudo access). This allows the automation agent to execute admin commands without being root or needing a password. On NixOS, you’d add a user in configuration.nix or just use `nixos-install` config; on openSUSE you likely created a user during install (ensure it has sudo or wheel group privileges).
* **Enable SSH Access**: If you plan to run the LLM agent externally and have it configure the laptop via SSH, make sure SSH server is running:

  * Install `openssh` if needed (`pacman -S openssh` on Arch, `emerge openssh` on Gentoo if not already, etc.).
  * Enable and start the sshd service: `systemctl enable --now sshd`.
  * It might be wise to set up key-based auth for convenience. Copy your public key into `~myuser/.ssh/authorized_keys` so the LLM agent (running as you from another machine) can login without password.
  * Ensure the firewall (if any) isn’t blocking SSH. (By default, Arch/Gentoo don’t enable a firewall; openSUSE does have firewalld – open port 22 or disable firewalld for now).
* **Prepare Package Manager for Automation**: This involves making non-interactive operations easier:

  * For distros with package prompts (like Gentoo’s `eselect-news` or `dispatch-conf`, or Arch’s pacman PGP key imports), you might want to pre-configure those to not stall automation. For instance, in Arch: initialize the pacman keyring (`pacman-key --init && pacman-key --populate archlinux`) so that the first package installs by the agent won’t prompt to import keys. In Gentoo, sync the Portage tree (`emerge --sync`) and enable the binary package repo in `/etc/portage/binrepos.conf` if not already (Gentoo’s stage3 might already include `gentoobinhost.conf` for binhost). This ensures the agent can just call `emerge -uDN @world` and get binaries for many packages.
  * On openSUSE, add the Packman repository (for multimedia codecs, if needed for gaming) – the agent can do this via `zypper ar`. On NixOS, the configuration.nix will be the primary interface rather than ad-hoc package commands, but you can still use `nix-env` for one-off installs if the agent prefers incremental steps.
  * Basically, update package lists: run a `pacman -Syu --noconfirm` (Arch), `emerge --sync` (Gentoo), `zypper ref && zypper dup` (Tumbleweed), or `nix-channel --update && nix-env -u '*'` (Nix) to ensure we start with up-to-date indices. This can also be done by the agent as a first step.

At this stage, the system is ready for the LLM agent to log in (locally or via SSH) as the sudo user and perform the remaining steps in an automated fashion. The following outlines the configuration tasks the agent should perform, in a logical sequence:

### **4. Automated Configuration & Setup by LLM Agent**

(*These steps would be executed by the AI agent through shell commands or config file edits. We assume the agent has access to internet and can consult documentation as needed.*)

1. **System Update and Essential Tools**: First, update the system to latest packages and install some essential utilities that will be useful for scripting:

   * Update package database and upgrade any out-of-date base packages. For example:

     * Arch/Manjaro: `pacman -Syu --noconfirm`
     * Gentoo: `emerge --update --deep --newuse @world` (with `--ask=n` for non-interactive)
     * Tumbleweed: `zypper dup -y` (distribution upgrade to current snapshot)
     * NixOS: if on unstable channel, `nix-channel --update nixos && nix-env -u` or simply proceed with config changes.
   * Install base development tools and utilities the agent might need for further steps (compilers, Git, etc.): e.g., a typical selection: `git`, `gcc`, `make`, `python3`, `htop`, `curl`, `wget`, `unzip`, etc. On Gentoo, you’d ensure the system profile includes `dev-tools` or just emerge those explicitly. The agent should ensure any tool it might call is installed (for instance, installing `python3-pip` if it plans to use pip for some AI packages, etc.).
   * (Optional) If using Gentoo, consider enabling parallel compilation in `/etc/portage/make.conf` (`MAKEOPTS="-j16"` for the 8-core/16-thread Ryzen) to speed up any source builds the agent triggers. Also, for Gentoo, the agent can enable the **binary package host** by making sure `binrepos.conf` has the Gentoo binhost and `FEATURES="binpkg-auto-install binpkg-respect-use"` is set, so it will fetch binaries when available.

2. **Graphics Drivers and GPU Setup**: Configure the system’s GPUs (integrated AMD and discrete NVIDIA) for optimal use:

   * **Install GPU drivers**:

     * For the NVIDIA RTX 3060, install the proprietary NVIDIA driver package (it yields better performance for gaming and AI than nouveau).

       * On Arch/Manjaro: `pacman -S --noconfirm nvidia-dkms nvidia-utils lib32-nvidia-utils` (including 32-bit libs for Steam/Proton). Also install `nvidia-settings` and `nvidia-prime` if available (for PRIME offloading). Arch’s rolling kernel will be supported by `nvidia-dkms`. Manjaro might have `mhwd` do this; the agent can either use `mhwd -a pci nonfree 0300` to auto-detect and install or directly install the driver packages as above.
       * On Gentoo: ensure the `nvidia-drivers` package is emerged with the correct USE flags (e.g., `X, wayland, uvm` for CUDA, etc.). Set `VIDEO_CARDS="nvidia amdgpu"` in `/etc/portage/make.conf` so that X/Wayland drivers build for both GPUs. Emerge `x11-drivers/nvidia-drivers` (which should also pull needed 32-bit libs if multilib is enabled). The agent can use `eselect opengl`/`eselect opencl` if needed to set NVIDIA as the GL provider.
       * On Tumbleweed: `zypper install nvidia-glG06 nvidia-G06-kmp-default` (assuming G06 series for 3000 series GPU) plus `vulkan-nvidia`. Tumbleweed provides 32-bit libs via `nvidia-glG06-32bit`. The openSUSE Wiki script (the agent can reference it) would guide these package names. Also run `sudo mkinitrd` after installation if prompted.
       * On NixOS: add to config:

         ```nix
         services.xserver.videoDrivers = [ "amdgpu" "nvidia" ];
         hardware.nvidia.modesetting.enable = true;
         hardware.opengl.enable = true;
         hardware.opengl.driSupport32Bit = true;
         ```

         This ensures NixOS includes both AMD and NVIDIA drivers and 32-bit support. Then `nixos-rebuild switch` to apply.
     * For the AMD integrated GPU (Vega), open-source drivers (AMDGPU) should already be installed as part of the kernel/mesa on all these distros. The agent should, however, install the 32-bit mesa drivers for AMD as well (for Proton on hybrid setups):

       * Arch: `pacman -S lib32-mesa lib32-vulkan-radeon vulkan-radeon`
       * Gentoo: ensure `VIDEO_CARDS="amdgpu"` and `ABI_X86=32` is set for mesa, then `emerge mesa` updates (or use `emerge --newuse @world` if you changed make.conf).
       * openSUSE: `zypper install Mesa-libGL1-32bit Mesa-vulkan-driver-32bit` (these provide 32-bit OpenGL/Vulkan for AMD).
       * NixOS: by enabling `driSupport32Bit` above, both AMD and NVIDIA 32-bit drivers will be handled.
   * **Configure Hybrid Graphics (if needed)**: On a laptop with NVIDIA Optimus (which this is), you have a few options: you can run the entire Wayland session on the integrated GPU and use offloading for NVIDIA when launching games (common approach), or run a separate X or Wayland on NVIDIA. The simplest path is to use AMD as the primary GPU for rendering the desktop (to avoid issues, since some Wayland compositors don’t play well with NVIDIA yet) and use PRIME render offload for games or CUDA work.

     * The agent should configure PRIME offloading: On Arch, that means ensuring the NVIDIA module is loaded and setting environment variables for offloading. For example, create `/etc/environment` with `__GLX_VENDOR_LIBRARY_NAME=nvidia` and `/etc/modprobe.d/nvidia.conf` with options if needed (the Arch Wiki has specifics, which the agent can follow). Installing `nvidia-prime` provides a script `prime-run` to launch apps on NVIDIA. The agent can test GPU offloading by running `glxinfo` or `vulkaninfo` with and without `prime-run`.
     * On Tumbleweed, openSUSE might have `prime-select` or similar. The agent could use `sudo prime-select offload` to set up offloading mode. It should verify `/etc/prime/current_type` is offload and that the NVIDIA card is not used for rendering the desktop.
     * Gentoo: configure X or Wayland such that Xwayland uses offloading. Possibly the agent writes a `/etc/X11/xorg.conf.d/10-prime-offload.conf` if using Xwayland for some games. For Wayland-only session, offloading will depend on explicit environment usage (like `DRI_PRIME` or Vulkan device select).
     * Ensure that for CUDA or AI, the NVIDIA GPU is accessible: installing `nvidia-cuda-toolkit` (Arch) or `dev-util/nvidia-cuda-toolkit` (Gentoo) or the equivalent can provide nvcc and GPU FFT libraries. This is optional unless doing GPU training builds on the laptop.
   * **Test**: The agent should test that both GPUs are recognized. E.g., run `nvidia-smi` (should show the RTX 3060 info) and `vulkaninfo | grep GPU` to see both AMD and NVIDIA. This ensures the drivers are correctly set up.

3. **Display Server and Wayland Compositor**: Set up the graphical environment using one of the recommended Wayland WMs:

   * **Install Wayland GUI Packages**: This includes the compositor itself and supporting tools:

     * Choose one of the WMs (Sway, Hyprland, etc.) to install. For example, if the user chooses **Sway**, the agent would install:

       * Arch: `pacman -S sway xorg-server-xwayland wayland-utils alacritty foot waybar wofi grim slurp` (and any other desired utilities like `mako` for notifications, `network-manager-applet` or `nmcli` for network, etc.). Sway on Arch requires the `seatd` or logind for input – systemd-logind is already in use, so that’s fine.
       * Gentoo: `emerge gui-wm/sway gui-apps/waybar gui-apps/swaybg gui-apps/swaylock gui-apps/wofi` etc., making sure USE flags for Xwayland are on.
       * openSUSE: `zypper in sway waybar foot wofi grim mako`.
       * NixOS: add to config:

         ```nix
         services.xserver.enable = true;
         services.xserver.displayManager.startx.enable = true;  # startx for non-Nix wms
         services.xserver.windowManager.sway.enable = true;
         programs.sway.enable = true;
         environment.systemPackages = [ pkgs.waybar pkgs.wofi pkgs.alacritty pkgs.mako ];
         ```

         (Alternatively, use home-manager for user-level config of these.)
     * If **Hyprland** is the choice: similar steps, just install `hyprland` and its deps (`xdg-desktop-portal-hyprland` for XDG integration, etc.). For example, on Arch: `pacman -S hyprland hyprland-wayland xdg-desktop-portal-hyprland`. On Gentoo, Hyprland might be in an overlay. The agent can handle whichever WM the user picks by consulting documentation.
     * If **river**: install `river` and perhaps the default `rivertile` layout generator. On Arch: `pacman -S river rivertile`. On others, build from source if needed.
     * For **labwc**: `pacman -S labwc` (Arch community repo), or compile on Gentoo (there’s an ebuild in guru or rusxm76 overlay).
     * **Wayfire**: `pacman -S wayfire wcm` (Wayfire Config Manager) plus a panel (maybe `wf-shell` or just Waybar), etc.
   * **Set up Auto-Start**: We need the system to start the Wayland compositor on login or boot, so that the LLM agent (if running in text mode) can eventually work in a GUI if needed (or the user can use the system normally). There are multiple ways:

     * Easiest for a single-user workstation: use the user’s shell profile to start the compositor on TTY1 after login. For instance, add to `~myuser/.bash_profile`:

       ```bash
       if [[ ! $DISPLAY && $(tty) == /dev/tty1 ]]; then
         exec sway
       fi
       ```

       (Replace `sway` with chosen compositor’s launch command, e.g., `Hyprland`, `river`, etc.). This will auto-launch the WM when the user logs into tty1. If you want auto-login to console, enable `getty@tty1.service` with autologin (via `agetty --autologin myuser` config in `/etc/systemd/system/getty@tty1.service.d/override.conf`). The agent can automate that using `systemctl edit getty@tty1`.
     * Alternatively, set up a minimal display manager or use systemd’s autostart: e.g., for sway, there’s `sway-user-service` package on Arch that runs sway via systemd -- the agent could enable a user linger and a systemd unit for sway. But the `.bash_profile` method is simpler.
     * On NixOS, you can use `services.xserver.displayManager.autoLogin.user = "myuser";` and `services.xserver.windowManager.sway.enable = true;` which will auto-login and start sway on tty1.
   * **Configure the Compositor**: Have the agent create initial config files:

     * For **Sway**: Create `~/.config/sway/config` (copy the default from `/etc/sway/config` as a base). Then the agent can programmatically adjust it: e.g., set the desired keybindings, add an exec for `waybar` and other startup apps, configure output resolution (maybe to the laptop’s screen resolution). The agent can use sway’s documentation (or even query sway at runtime via IPC) to adjust settings. Example customizations: set `output * scale 1.5` if HiDPI, set keyboard layout if needed, bind PrintScreen to `grimshot` for screenshots, etc. Because the config is a text file, the LLM can handle it easily.
     * For **Hyprland**: Create `~/.config/hypr/hyprland.conf` (or copy example). Hyprland config is also text (ini-like syntax). The agent should set `monitor=...` configurations for monitors (or let it auto-detect), configure workspace shortcuts, and autostart apps (via the `exec-once = waybar` lines, etc.). Ensure `xdg-desktop-portal-hyprland` is running for screenshots and such.
     * **river**: Create an executable script `~/.config/river/init` with riverctl commands. For example:

       ```bash
       #!/bin/sh
       riverctl spawn "waybar" &
       riverctl set-repeat 50 300   # keyboard repeat rate
       riverctl map normal Mod4 Enter spawn "alacritty"
       riverctl map normal Mod4 J focus-view next
       ... (etc)
       ```

       The agent can use the river man page and community configs as reference to write this. Because this is basically scripting, the LLM’s code-writing ability is directly applicable. After placing the file, make it executable.
     * **Labwc**: The agent should edit `~/.config/labwc/labwc.conf` (which is similar to openbox config; themes, keybinds, etc.). Possibly also set up `autostart` file to launch a panel like waybar and other needed daemons (compositors like labwc won’t start those by themselves). Labwc reads Openbox-style XML for keybindings and themes, so the LLM must be careful with XML syntax – but it can refer to labwc docs or openbox configs for examples.
     * **Wayfire**: Edit `~/.config/wayfire.ini`. Set `[core]` settings (like `plugins = ...` to include desired plugins), and configure keybindings in the `[bindings]` section. E.g., bind \<super+Enter> to launch a terminal by adding `bind=<super> + Return exec alacritty`. Wayfire has a graphical config tool (wcm) but we prefer text editing for automation.
   * **Enable required services for desktop**: Ensure that required background services are running:

     * For sound, install PipeWire (most of these distros come with PipeWire or PulseAudio by default nowadays). Agent can install `pipewire pipewire-pulse wireplumber pavucontrol`. Enable PipeWire service if needed (on Arch, enable pipewire and pipewire-pulse sockets). On Gentoo, set USE flags and emerge `media-video/pipewire` etc.
     * For networking in GUI, maybe enable a network applet. If using NetworkManager, installing `network-manager-applet` gives a tray icon (Waybar can show it if configured). On Waybar, ensure to add the network module. The agent can edit `~/.config/waybar/config.json` accordingly.
     * For power management on a laptop: install `tlp` or enable `power-profiles-daemon`. Also configure lid close actions via logind (`/etc/systemd/logind.conf`). The agent should set `HandleLidSwitch=suspend` (or ignore if external monitors).
     * GPU power: On hybrid laptop, consider enabling `nvidia-suspend.service` scripts and setting `NVreg_PreserveVideoMemoryAllocations=1` in modprobe config if you want to use system suspend with NVIDIA.
     * Bluetooth (if needed): install `bluez` and `bluez-utils`, enable `bluetooth.service`.
     * MIDI/Music (low priority, but if needed later): ensure `alsa` and maybe `jack2` are installed. This can be done on-demand by the agent if the user asks for audio production setup.

4. **Development Environment Setup**: Install and configure all required programming languages, libraries, and tooling for AI/ML:

   * **Programming Languages & Toolchains**: The agent should install compilers/interpreters for Python, Java, Rust, JavaScript/Node, C/C++ (plus make/cmake), Haskell, Lisp, Lua, Perl, Shell:

     * On binary distros (Arch, Tumbleweed, Manjaro): one command can install multiple, e.g.:
       `pacman -S --noconfirm python3 python-pip openjdk11-openjdk rust rust-analyzer nodejs npm gcc clang make cmake ghc cabal-install sbcl lua perl`
       and so on. (Arch has meta packages or groups for some, e.g., `base-devel` for C/C++ build tools). For Arch, also install `go` (for Go language, since “JS” was mentioned and typically one might also want Go in an ML context, and Elixir if needed by the user’s context of “shell, etc.”).
     * On Gentoo: set appropriate USE flags globally (e.g., `PYTHON_TARGETS` for desired Python versions, `ruby_targets` if Ruby needed, etc.) and then emerge relevant packages: `emerge dev-lang/python dev-python/pip dev-lang/rust dev-util/rust-analyzer dev-lang/go openjdk:11 dev-lang/nodejs dev-vcs/git gcc clang dev-util/cmake dev-haskell/ghc dev-scheme/guile dev-lua/lua dev-lang/lua` (Gentoo will handle dependencies accordingly). This might be heavy, so the agent could parallelize emerges or rely on binary packages for big ones (like Rust may be in binpkg host).
     * On NixOS: either add all to `environment.systemPackages` or have a development shell configured via `nix-shell` with needed compilers. E.g., in configuration.nix:

       ```nix
       environment.systemPackages = with pkgs; [
         python3 python3Packages.pip rustc rust-analyzer stackage ghc lua perl openjdk nodejs npm go sbcl cmake make gcc clang
       ];
       ```

       Nix will ensure all are installed.
     * Verify each language works (e.g., `python3 --version`, `rustc --version`, etc.).
   * **AI/ML Frameworks and Libraries**: This includes things like PyTorch, TensorFlow, transformers, etc., and tools like CUDA, cuDNN (for NVIDIA). Given the laptop has an RTX 3060 (Ampere), we likely want CUDA enabled for ML:

     * **CUDA Toolkit**:

       * Arch: `pacman -S cuda cudnn` (this installs NVIDIA’s CUDA toolkit and cuDNN library).
       * Gentoo: enable `cuda` USE on relevant packages, `emerge dev-util/nvidia-cuda-toolkit sci-libs/cudnn`.
       * openSUSE: `zypper in nvidia-cuda-toolkit cudnn`.
       * NixOS: add `cuda` to packages or use `hardware.nvidia.cudaSupport = true;` (and add cudnn to `environment.systemPackages`).
       * The agent should also consider installing `python-pytorch-cuda` or `tensorflow` from repos if available (Arch has python-tensorflow-cuda, etc. – these save compiling from source). Alternatively, the agent can plan to use pip in a venv to install these.
     * **Python ML packages**: It may be convenient to set up a Python virtual environment (or Conda environment) for AI research, to avoid polluting system Python and to easily manage dependencies. The agent can install `miniconda` or use system pip:

       * For now, perhaps use system pip for a few critical packages: `pip install --upgrade pip` and then `pip install torch torchvision torchaudio tensorflow transformers datasets` (this will fetch wheel packages if available for Linux x86\_64 with CUDA, otherwise pip might compile which we want to avoid – but PyTorch and TF provide prebuilt wheels with CUDA).
       * Alternatively, instruct the agent to install Miniconda: download the installer script and run it non-interactively to set up a conda base environment. Then create an environment with needed packages. This might be something the user does manually later, but an AI agent can handle it if directed (it would have to accept license agreements etc., which might require `-b` batch mode).
     * **MLC frameworks** (like MPI or JAX): If needed, the agent can also install those (e.g., `pacman -S openmpi` for distributed training setups, etc.). Google’s JAX can be installed via pip (with CUDA support).
     * The agent should verify that it can access the GPU from PyTorch: e.g., run a short Python snippet: `import torch; print(torch.cuda.is_available())` – expecting `True`. If false, troubleshoot (maybe missing `export LD_LIBRARY_PATH` for CUDA libs or a driver issue).
     * **MCP and Google’s A2A**: The prompt mentioned “tooling like MCP and Google’s A2A”. These might refer to specific research projects or tools (perhaps “Model-Card-Printer” or something, and Google’s “Attention to Attention”? Not entirely sure). The agent can search pip or research if those are pip-installable packages or GitHub repos. If known, install them (e.g., `pip install MCP` if exists). This might be user-specific, so perhaps skip until the user explicitly asks.
   * **Cloud CLI Tools**: Install official CLI for Google Cloud (gcloud SDK), AWS (awscli), Azure (az CLI):

     * Arch: `pacman -S --noconfirm google-cloud-sdk aws-cli azure-cli`. (These are in the community repo.)
     * Gentoo: `emerge www-client/google-cloud-sdk dev-python/boto3` (for AWS via boto) or use pip for awscli (`pip install awscli`), and Azure CLI might be available as `azure-cli` (if not, use pip for `azure-cli`).
     * openSUSE: `zypper in GoogleCloudSDK aws-cli azure-cli`.
     * NixOS: add `pkgs.google-cloud-sdk pkgs.awscli2 pkgs.azure-cli` to environment.
     * After installation, the agent can configure basic default profiles if credentials are provided (likely not at this stage – user will authenticate interactively later). But having them installed means the environment is ready for cloud interactions (like deploying models or using cloud storage from the laptop).
   * **IDE/Editors and Misc Dev Tools**: Depending on user preference, the agent might install Neovim/VSCode/Emacs for coding:

     * For automation-friendliness, CLI editors like Neovim or micro could be useful. VS Code in GUI could be installed (`code` package on Arch, or `vscode` on others) if the user plans to develop with it – though an LLM can also drive an editor.
     * Perhaps install `neovim` (for terminal editing with LLM plugins) and `code` (for GUI editing). This is optional, but likely desired for a development machine. The agent can do: `pacman -S neovim code` or corresponding commands.
     * Also consider `tmux` (for terminal multiplexing, helpful when agent is running long tasks and user wants to detach).
     * Configure Git (set user name/email as provided by user or leave for user). Possibly install `git-lfs` if working with large files.

5. **Gaming Tools Setup**: Ensure all gaming-related requirements are met:

   * **Steam**:

     * Install Steam client: on Arch/Manjaro, `pacman -S steam` (from multilib). On Gentoo, `emerge games-util/steam-meta` which pulls in Steam and necessary 32-bit libs (Gentoo’s steam-meta ensures `ABI_X86=32` for all dependencies). On openSUSE, `zypper install steam`. On NixOS, enable steam in config:

       ```nix
       services.steam.enable = true;
       hardware.opengl.driSupport32Bit = true;  # already set earlier
       ```

       (This will include Steam and set up steam-run wrappers).
     * After installation, the agent can’t fully setup Steam (as it needs a user to login and such), but it can ensure that the GPU offloading works with Vulkan for Steam. It might install `mesa-utils` and run a test with `vulkaninfo`. It can also pre-install Proton GE if desired: one way is to use the AUR package `proton-ge-custom` on Arch, or simply have the agent download the latest ProtonGE release from GitHub and extract it to `~/.steam/root/compatibilitytools.d/`. This would allow the user to select it in Steam’s interface later. The agent should also install `wine` (for non-Steam games or WINE forks) and tools like `lutris` if the user plans to use them.
   * **Proton/Wine**:

     * Install standard Wine (and winetricks perhaps): e.g., `pacman -S wine winetricks`. On Gentoo, `emerge app-emulation/wine-staging` with 32-bit enabled. On openSUSE, `zypper install wine winetricks`.
     * For **Proton-GE** (GloriousEggroll’s Proton fork): not directly in repos usually. On Arch, AUR has `proton-ge-custom-bin`. The agent on Arch can do: `yay -S proton-ge-custom-bin` (assuming an AUR helper like yay or paru is installed; if not, the agent can git clone the PKGBUILD and makepkg it). Alternatively, as mentioned, download the release tarball and place it appropriately.
     * **DXVK/VKD3D**: These are usually included with Proton, but if playing non-Steam games via Wine, installing `dxvk-bin` and `vkd3d` is helpful (AUR on Arch, or built from source on others). Lutris usually manages those, so installing Lutris covers it.
     * **Lutris**: `pacman -S lutris` or `emerge games-util/lutris`. Lutris helps managing non-Steam games and selecting WINE versions. The agent should include it if gaming beyond Steam is intended.
     * Verify 32-bit OpenGL/Vulkan is working: run `glxinfo32` or `vulkaninfo --32` if possible. The agent can run a test like `winecfg` to see if Wine initializes (though without display, it might need Xwayland – which is installed along with compositors typically). Ensuring Xwayland is working (for games that will run under Xwayland in Wayland session) is also key; test by launching a simple X app like `xeyes` under sway (should appear via Xwayland).
   * **Controllers and MIDI (if any)**: If the user has game controllers, installing `steam-devices` (for udev rules) and enabling the `gamecontrol` USE in Gentoo or similar can help. For MIDI, since it’s low priority, maybe just ensure `alsa`, `pulseaudio-alsa` (or PipeWire equivalents) are installed so MIDI devices can be recognized. If the user specifically needs JACK for low-latency audio/MIDI, the agent can install and configure `jack2` and a GUI patchbay, but that might be overkill unless asked.
   * **Performance Tuning**: The agent can apply some system tweaks for gaming and AI:

     * CPU governor to performance when gaming: e.g., install `cpupower` and set governor to performance, or use TLP’s tuning. The agent could configure a udev rule or simple script to toggle performance governor when certain apps launch (this might be advanced; maybe skip unless user requests).
     * Hugepages for ML (maybe enable transparent hugepages which are usually on by default).
     * VM max\_map\_count for large model allocations (could echo `vm.max_map_count=262144` to /etc/sysctl.d if needed for some ML frameworks).
     * The agent could also install `gamemode` (FDL’s GameMode daemon) and configure WMs to auto-launch it for games. E.g., `pacman -S gamemode lib32-gamemode` and set `exec_always gamemoded -t &` in sway config. This helps with CPU governor and nice-level while gaming.

6. **Final Touches and Verification**:

   * **Verify Wayland Session**: The agent should ensure the Wayland compositor starts on boot/login properly. It can reboot the system (or simply log out/in via automation) to test the autologin+WM start. If autologin was set, the system should boot straight into (for example) a Sway session without intervention. The agent can check this by seeing if the sway IPC socket exists or if processes are running. In a live scenario, an agent might not “see” the GUI, so it should rely on logs. For instance, after boot, use `systemctl status getty@tty1` to ensure it auto-logged in, and maybe `pgrep -x sway` to confirm sway is running. If not, adjust the config (maybe .bash\_profile wasn’t executed – could be that the distribution uses zsh by default; ensure the appropriate shell init file is edited for that user).
   * **Accessibility of CLI in Wayland**: Since the agent might still need to run commands, ensure a terminal is accessible in the Wayland session. For sway, we bound \<Super+Enter> to Alacritty above. The agent can simulate that keypress via swaymsg if it needed to open a term. Alternatively, ensure an SSH server remains active so the agent can continue via SSH even while the GUI is up (ssh will still work in background).
   * **Services enablement**: Double-check that all needed services are enabled to start on boot: `NetworkManager`, `bluetoothd` (if needed), `sshdd`, etc., so that the next reboot everything is up.
   * **System Info & Logs**: The agent can gather some logs and info as a “report” to ensure everything is correct. It might run:

     * `neofetch` or `inxi -F` (if installed) to display summary of system (OS, kernel, drivers loaded, etc.).
     * `nvidia-smi` to show GPU utilization (should display the card and 0% usage if idle – confirming driver OK).
     * `glxinfo -B` and `glxinfo32 -B` (if available) to ensure 32-bit OpenGL contexts work (for Steam/Wine).
     * `systemctl --failed` to ensure no critical services failed.
     * Check Wayland compositor log (\~/.local/share/sway/sway.log or equivalent) for errors (like missing font for waybar etc., fix if needed by installing nerd fonts or so).
   * **Scriptability test**: Maybe perform a small automated action via the WM’s IPC to confirm that the environment indeed can be driven by scripts. E.g., for sway: `swaymsg exec firefox https://example.com` (which should open a browser). For river: use `riverctl` to, say, open a terminal. This confirms that the agent can issue runtime commands to the WM.
   * **Snapshot/Backup Configuration**: Given everything is configured, it’s wise to take a snapshot or backup of the config in case regression occurs. On openSUSE, a Btrfs snapshot would have been automatic if we used Btrfs, but we chose XFS (no snapshot). Instead, the agent could create a manual backup: e.g., tar up `/etc` and the user’s home config dotfiles, or if the user uses Git, initialize a git repo for config (NixOS users often version control `/etc/nixos/configuration.nix`). The LLM agent might not do this unless instructed, but it’s a good practice for an automated setup to be reproducible.

**Conclusion:** At this point, the system should be fully installed and configured: a rolling-release distro with systemd-boot bootloader, running a Wayland window manager (no GNOME/KDE bloat), all needed development and research tools installed, and gaming support enabled. The environment is highly scriptable – from the OS config (especially in NixOS or via Ansible for others) down to the window manager – which is ideal for iterative improvement by an LLM agent. The agent can now continuously adjust configurations (like tweak WM keybinds, install new packages on demand, update dotfiles, etc.) based on the user’s prompts, with a solid base system in place.

Throughout this setup, we cited sources and leveraged known documentation to ensure the steps are accurate and aligned with best practices. The user (or the AI assistant orchestrating the install) can use this plan to confidently provision the laptop for an efficient development, gaming, and AI research experience.

**Sources:**

* Arch vs Gentoo comparison (ArchWiki)
* Gentoo official news about binary packages
* Gentoo vs Arch (ArchWiki: Gentoo can use systemd)
* openSUSE Tumbleweed overview (get.opensuse.org)
* Phoronix news on Tumbleweed systemd-boot support
* LinuxBlog on rolling distro stability (Tumbleweed vs others)
* NixOS unstable (LinuxBlog)
* Linux Magazine on Redcore/Manjaro analogy (for Gentoo)
* LinuxBlog on Manjaro vs Arch rolling updates
* Reddit discussion of Wayland WMs (Sway/Hyprland/DWL)
* ArchWiki on Sway (i3 replacement on Wayland)
* ArchWiki on Hyprland (features and docs)
* ArchWiki on river (dynamic tiling, scriptable via riverctl)
* Labwc README (Openbox-inspired stacking compositor)
* ArchWiki on systemd-boot installation (bootctl)
