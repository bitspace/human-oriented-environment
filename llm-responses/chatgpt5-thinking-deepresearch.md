# High-End Rolling Release Linux Workstation Setup

## Introduction

A **high-end mobile workstation** like the Lenovo ThinkPad P16 Gen2 (Intel i9-13980HX, 192 GB RAM, 4 TB NVMe SSD, Intel UHD iGPU) demands a robust, flexible operating system. We need a Linux distribution that is **rolling-release** (continuously updated) and supports advanced workflows in software development (Python, Java, Rust, C/C++, JavaScript, Haskell, Lisp), AI/ML experimentation (LLMs and related tools), cloud development (AWS, GCP, Azure SDKs/CLI), and even gaming (Steam/Proton and WINE). The ideal setup should emphasize **automation and scriptability** – configuration files easily parseable/editable by AI agents – and use modern tooling like **systemd** init and **Wayland** for display (while allowing X11 apps via Xwayland). Additionally, we want robust **system rollback** capabilities (via Btrfs snapshots, Nix generations, etc.) to recover from bad updates or configuration changes. Security features like secure boot or full disk encryption are not required here, simplifying installation. In summary, we seek a cutting-edge, **CLI-first** Linux platform, with a strong package manager (preference for Portage, Pacman, or Nix-style), that can be extensively automated.

Below, we identify **5 top Linux distributions** meeting these criteria, followed by **5 Wayland-compatible desktop environments/window managers** (excluding GNOME/KDE) known for scriptable, text-based configuration. Finally, we provide a **step-by-step installation and configuration plan** for the chosen distribution and environment, from base install to a tuned user environment ready for coding, AI workloads, cloud tools, and gaming. Official documentation and well-supported community tools are referenced throughout to ensure reliability.

## Top 5 Rolling Release Linux Distributions

The following distributions are well-suited for a high-end rolling-release workstation, each aligning with the criteria:

| **Distro**              | **Release Model**      | **Pkg Manager**     | **Init**                  | **Rollback Support**               | **CLI-Focused?**         | **Highlights**                                                          |
| ----------------------- | ---------------------- | ------------------- | ------------------------- | ---------------------------------- | ------------------------ | ----------------------------------------------------------------------- |
| **Arch Linux**          | Rolling (continuous)   | Pacman (ALPM) + AUR | systemd                   | Btrfs snapshots (via Snapper)\*    | Yes – user-centric CLI   | Latest stable packages; minimal by default; huge community/wiki.        |
| **Gentoo Linux**        | Rolling (source)       | Portage (emerge)    | OpenRC\*/<br>systemd opt. | Btrfs snapshots (manual)           | Yes – fully from source  | Extreme configurability (USE flags, custom compile); any init.          |
| **NixOS (Unstable)**    | Rolling (via channels) | Nix (declarative)   | systemd                   | Atomic rollbacks (Nix generations) | Yes – config as code     | Reproducible builds; config-driven OS; \~120k packages available.       |
| **openSUSE Tumbleweed** | Rolling (tested)       | Zypper (RPM)        | systemd                   | Automatic Btrfs/Snapper snapshots  | Yes – YaST CLI & GUI     | Stable rolling (openQA tested); Btrfs default for easy rollback.        |
| **Manjaro Linux**       | Rolling (curated)      | Pacman + Pamac GUI  | systemd                   | Btrfs snapshots (via Timeshift)\*  | Yes – plus GUI tools     | Arch-based with delayed updates for stability; user-friendly installer. |

<small>\*<i>Note:</i> Arch/Manjaro can use Btrfs with Snapper or Timeshift for snapshots; Gentoo can leverage Btrfs manually. Gentoo’s default init is OpenRC, but official systemd support is available.</small>

### 1. **Arch Linux** – *Minimalist Rolling Release*

**Arch Linux** is a cutting-edge rolling distro that “strives to provide the latest stable versions” of software via a rolling release model. Once installed, you just update regularly – no reinstalls for new versions. Arch uses the simple and fast **pacman** package manager (with the Arch User Repository for community build scripts), allowing one-command full system upgrades. It defaults to **systemd** init and embraces modern features like new kernels and filesystems. Arch is famously minimal and **user-centric**: the base install is just a command-line system you expand as needed. There are no official GUI config tools; instead, Arch encourages editing text configs and using the shell – aligning perfectly with a CLI-first, automation-friendly workflow.

For our purposes, Arch ticks all boxes: rolling updates, **pacman** for scripting (machine-readable outputs and hooks), systemd, and the ability to setup **Btrfs snapshots** (with tools like Snapper and `snap-pac` hooks for pacman – see below). Its community wiki is legendary and covers everything from setting up development environments to GPU drivers and AI frameworks. Arch’s huge repositories (plus the AUR) include virtually all development languages and latest libraries, as well as Steam, Proton, and machine learning packages. This makes Arch excellent for software development and experimentation on a high-end system, provided you are comfortable with manual setup and reading documentation (which we’ll guide in the plan).

### 2. **Gentoo Linux** – *Source-Based Meta Distribution*

**Gentoo** is a rolling-release where all packages are compiled from source with the user’s chosen optimizations. This provides **extreme customization**: you can set CPU-specific compile flags and **USE flags** to enable/disable features in each package. Gentoo’s Portage package manager (invoked via `emerge`) is highly scriptable and powerful. It’s a more complex system than Arch, but rewards expertise with a finely-tuned OS. Gentoo officially supports multiple init systems (OpenRC by default, or systemd if selected) – since our criteria require systemd, you can install Gentoo’s systemd variant or configure that profile. Gentoo meets our needs as a rolling distro (new packages are available shortly after upstream releases) and is very automation-friendly (everything is controlled by text files: e.g. make.conf, package.use, etc.). Configuration is essentially code, which an LLM agent could read/modify if needed.

Using Gentoo on a powerhouse laptop is plausible – the i9-13980HX and ample RAM can handle frequent compilation. The benefit is a system optimized for your hardware and use-cases (e.g. you could enable or disable support for certain features globally via USE flags). Gentoo’s portage supports **binary packages** as well (and as of late 2023 Gentoo even offers an official binary repo for some architectures if you choose). Rollback support isn’t built-in, but you can employ **Btrfs snapshots** similarly by using Snapper or manual snapshot scripts, and Portage’s world state can be backed up in Git. Gentoo is a great choice for those who want **maximal control** and don’t mind a complex setup/maintenance – it will certainly leverage the “LLM-configurable” aspect, since much of Gentoo’s configuration is transparent plain text or scripts.

### 3. **NixOS (Unstable channel)** – *Declarative & Reproducible*

**NixOS** takes a unique approach: the entire system (OS packages, config files, even user applications) is built from a single **declarative specification**. You describe your system in Nix language, and the Nix package manager ensures everything matches that description. This yields *reproducible builds* and **atomic upgrades with rollbacks**: every time you rebuild the system, it creates a new generation. If something goes wrong, you can simply roll back to a previous generation from the boot menu. NixOS uses systemd by default for its init system and meets all of our criteria: it’s effectively rolling (you can track the `unstable` channel for the latest packages, or use stable channels for slower cadence), supports advanced package management (120,000+ packages and the ability to declaratively install even language-specific packages), and is extremely automation-friendly – in fact, automation is the *only* way to configure it (via the Nix config files).

For a high-end workstation, NixOS has appealing benefits:

* **Rollback support** is first-class: you can boot into older “generations” if an update causes issues.
* **LLM-friendly config**: The `configuration.nix` (or Nix flake) is a single source of truth that an AI agent could parse and modify to install packages or change settings. Nix syntax is somewhat complex, but structured.
* **Isolated environments**: Nix’s approach ensures that packages don’t conflict. You can have multiple compiler versions or libraries coexisting, which is great for testing different dev environments or running ML frameworks that need specific versions. Installing or upgrading one package won’t break others due to dependency isolation.
* The trade-off is a learning curve: one must learn the Nix language and concepts like purity and store paths. Also, for some proprietary or cutting-edge tools, writing a Nix package expression might be needed if not already available. But the community is growing, and many configs are shared online.

NixOS would let us declaratively state: “Enable Sway session, install these 50 packages, create these user accounts, set up these services, etc.” and build the system accordingly. For an AI/ML workstation, you might even codify your Python virtual environments or Jupyter kernel setups in Nix. This ensures any change is trackable and revertible. NixOS definitely fulfills the “scriptable and LLM-editable” requirement in spirit – essentially, *infrastructure as code* for your laptop.

### 4. **openSUSE Tumbleweed** – *Stable Rolling with Snapshots*

**openSUSE Tumbleweed** is a **rolling-release** distribution known for its balance of freshness and stability. It continuously delivers new package updates, but *only after automated testing*: Tumbleweed snapshots are built and run through openQA (QA automation) before release, making it one of the most reliable rolling distros. It uses the **Zypper** package manager (RPM-based) which is fully usable from CLI (and also via YaST). Crucially, openSUSE defaults to **Btrfs** for the root filesystem **with Snapper automated snapshots enabled**. Every software update (done via `zypper dup`) creates a pre- and post-snapshot of the system. If an update causes problems, you can reboot and choose a prior snapshot from the GRUB menu, effectively rolling back your system state. This built-in **configuration rollback** is a huge plus for a development machine: feel free to update often or try new software, knowing you can roll back if needed.

Tumbleweed uses systemd and has excellent support for both Wayland and X11 (GNOME and KDE are first-class, but one can install Sway, etc., as well). It satisfies our package manager preference indirectly: while Zypper isn’t pacman or portage, it’s robust and scriptable (supports XML output for queries, etc.). Additionally, SUSE’s focus on automation (AutoYaST, KIWI, etc.) means advanced scripting is well-supported. The distribution is very **power-user friendly**: tools like **YaST** can manage system config via GUI or text mode, but all underlying config files (and the rich SUSE documentation) are accessible for automation. Tumbleweed’s repositories include wide language support (all major compilers, runtimes, container tools) and it’s known to work with NVIDIA and AMD GPUs (for our case, the Intel iGPU is supported out-of-box by Mesa).

For our use-case, openSUSE Tumbleweed offers peace of mind with **automatic Btrfs snapshots and easy rollback**, and a well-tested rolling base. It might not have the AUR’s breadth, but it has the OBS (Open Build Service) where community developers provide many extra packages. Also, Flatpak support is there if needed for things like proprietary IDEs or such. In short, Tumbleweed is a great “it just works” rolling distro for a workstation, with strong scripting (you can even script YaST or use Salt with SUSE) and a focus on stability.

### 5. **Manjaro Linux** – *User-Friendly Arch-Based*

**Manjaro** is an Arch-derived rolling distro that aims to be more user-friendly. It takes Arch Linux’s base (pacman, systemd, rolling updates) and layers on an installer, graphical package tools, and a slight delay on updates to test them. Manjaro uses **pacman** and supports the AUR, but by default it holds new Arch packages for about a week of extra testing in its own repositories. This gives a buffer to catch any show-stopper bugs, making it **more stable than vanilla Arch** at the cost of not always having the absolute latest version of every package. For a workstation, that trade-off can be beneficial if you prefer smoother updates.

Manjaro meets the key criteria: it’s a rolling release (continuous updates), uses systemd, and since it’s Arch-based, you can set up Btrfs and Snapper just as on Arch (Manjaro’s Calamares installer even has an option to use Btrfs with automatic Timeshift snapshots). Its package manager is pacman (with a GUI frontend if desired), so all the scripting benefits of Arch apply. CLI configuration is still fully available (Manjaro adds some GUI settings managers, but you can ignore them if you prefer manual control). Another nice feature is that Manjaro comes with more things working out-of-the-box (e.g. easier hybrid GPU setup, pre-installed codecs in some editions, etc.), which can save initial setup time.

For our high-end system, Manjaro provides an “Arch without the pain” experience. You still have access to the Arch Wiki for guidance. All development and cloud tools available in Arch are usable on Manjaro, and gaming is equally supported (Manjaro even maintains their Hardware Detection utility to easily install GPU drivers and kernels). Since the user is technical (interested in LLM automation), Manjaro simply offers a quicker path to a configured system, while still allowing low-level tweaks. If using Manjaro, one should follow its slightly different update process (using their `pacman -Syu` or GUI which does the equivalent) and be mindful of their forum for any held back updates or manual interventions.

**Summary:** Each of these five distributions can serve as the foundation for our ThinkPad P16 workstation. Arch and Gentoo give ultimate control and community resources; NixOS gives a declarative, rollback-friendly approach; openSUSE Tumbleweed provides a balanced, snapshot-protected rolling system; and Manjaro offers a sane middle-ground with Arch’s benefits and fewer hassles. Next, we’ll consider the desktop environment or window manager layer – focusing on Wayland compositors that are *scriptable and minimal*, consistent with our automation-first goals.

## Top 5 Scriptable Wayland Desktop Environments/Window Managers

To maximize scriptability and configurability, we’ll use a **window manager or lightweight desktop** instead of heavy DEs like GNOME/KDE. Below are five excellent options that run on Wayland (ensuring future-proof display and good HiDPI support for our 3840×2400 screen) and exclude GNOME/KDE as requested. Each of these is highly **configurable via plain text** and popular among power-users – meaning an LLM agent could read or modify their configs (which are usually simple files or code) to automate UI customization.

&#x20;*Example of a Sway tiling Wayland environment with configuration files open. Tiling window managers like Sway allow defining keybindings and layout in plain text (as seen on the left, listing mod-key shortcuts) and status bars (top) and panels via editable config files. This makes them highly scriptable and suitable for automation.*

1. **Sway WM** – Sway is an **i3-compatible tiling compositor** for Wayland. It replicates the behavior and configuration syntax of the popular i3 window manager. You manage windows in a tiling layout (split-screen, no overlapping unless floated) and control everything with keyboard shortcuts. **Why it’s suitable:** Sway’s config lives in `~/.config/sway/config` – a plain text file where you define keybindings (e.g. `$mod+Enter` to open a terminal), window rules, and so on. An excerpt might be: `bindsym $mod+Shift+E exec firefox` to bind a key to launch Firefox. This file is straightforward to parse or generate. Sway even has an IPC socket for advanced scripting (you can query/command it at runtime via `swaymsg`). It uses the **wlroots** library and supports modern Wayland features. In our use, Sway gives a no-frills, **keyboard-driven** environment that can be heavily customized. It’s lightweight (perfect for focusing resources on VMs/compilers) and works well with multi-monitor. Since it’s i3-like, extensive documentation exists and many pre-made configs can be adapted. For Wayland-native apps it’s seamless, and for X11 apps, Xwayland will handle compatibility. Sway’s emphasis on simplicity and text-based config aligns perfectly with an automated setup.

2. **Hyprland** – Hyprland is a **dynamic tiling Wayland compositor** known for eye candy and flexibility. It’s relatively new but rapidly gained a following. Hyprland supports fancy effects (blurs, animations) without sacrificing performance. **Why scriptable:** Hyprland uses a single config file (often `~/.config/hypr/hyprland.conf`) which has an INI-like format. You can define keybindings, window rules, workspace settings, etc. via plaintext. For example:

   ```ini
   bind = $mod,Enter,exec,alacritty
   decoration {
       rounding = 5
       blur = true
   }
   ```

   This format is easy for an LLM to manipulate. Hyprland also supports an **IPC socket** for runtime commands. It’s described as *“a dynamic tiling Wayland compositor that does not sacrifice on its looks.”* – meaning you can have tiling or floating windows as needed, with smooth transitions. It is highly configurable (you can script workspaces, window rules for specific applications, etc.). Hyprland would appeal if we want a modern aesthetic along with our scripting; it can make a slick development environment (imagine terminals sliding in/out with animations). Despite the visuals, core config is still in text, keeping it automation-friendly. Hyprland is under active development, so some stability considerations apply, but it’s quite usable in 2025 and supports our hardware (Intel iGPU with wlroots is fine; if we had NVIDIA we’d use a special build).

3. **Qtile (Wayland)** – Qtile is a **tiling window manager written and configured in Python**. Originally for X11, it now has Wayland support. Qtile is “full-featured, hackable” and because its config file is literally a Python program, you can script your desktop in the Python language (an LLM could generate Python code to adjust Qtile’s behavior). For example, your config.py might define a list of keybindings as Python objects. This is appealing for advanced automation: one could write a Python routine to adjust layout or respond to events. Qtile supports multiple layout algorithms (stack, grid, etc.) and is *extensible* – you can write custom widgets for its bar in Python. It essentially provides an **API for the WM**. For our use, Qtile could unify the development environment with the language – e.g., you could script window arrangements or create custom shortcuts on the fly. The drawback is that being dynamic means a bit more overhead and potential for bugs, especially on Wayland where Qtile’s support is relatively new (it’s being actively improved; as of 2024 there are minor rough edges, but core tiling works). If you enjoy Python, Qtile is perhaps the most *LLM-parsable* (it’s just code). Even without an AI, it’s easy for a human to read and write the config since it’s high-level. This can be a very powerful environment if configured well.

4. **river** – river is a **dynamically tiling Wayland compositor inspired by dwm and bspwm**. It’s a more minimalist choice. Unlike some others, river doesn’t rely on a big config file; instead, you configure it by running commands (via its CLI `riverctl`). This means you often create a small shell script (e.g. `~/.config/river/init.sh`) that calls `riverctl` to set keybindings, etc., when you start the session. For example:

   ```bash
   riverctl map normal $mod J focus-view next
   riverctl set-opacity 1.0
   ```

   This approach is **highly scriptable** by design – the entire config is a series of commands that could be generated or modified via scripts or an AI. River aims to be simple and fast, following the dwm philosophy of “do one thing well.” It lacks some advanced features out of the box (no built-in bars or launchers – you’d use third-party like `waybar` or `wofi` which is common for most WMs here). River is under active development and is appreciated for its clean design. For automation, the benefit is that every setting is exposed as a command; an agent could decide to remap keys or change settings by editing the startup script or even at runtime via executing `riverctl`. This WM would suit users who want to build up exactly what they need – it’s like a construction kit for a desktop environment, with tiling by default.

5. **Wayfire** – Wayfire is a slightly different option: it’s a **3D floating Wayland compositor inspired by Compiz** and uses a **plugin architecture**. While the others are tiling-centric, Wayfire defaults to a classic stacking (floating) window model, but with fancy effects (wobbly windows, cube workspace, etc. if you enable them). It’s included here because it’s **highly customizable via plugins and config**. The config is done in an `.ini` style (similar to Weston’s config). For example, you might have a `[core]` section, `[bindings]` for key shortcuts, etc., in a file like `~/.config/wayfire.ini`. It’s straightforward to parse. Wayfire aims to be **lightweight and extendable without sacrificing appearance** – so you can script its behavior by toggling plugins or adjusting their settings in the config file. It even now has an IPC socket (as of 0.9) for external control. This choice is best if you want a more traditional DE feel (floating windows and panels) but still with a small footprint and scriptable setup. For instance, you could use Wayfire with a panel (like Waybar) and get a slim “desktop environment” that an AI could reconfigure by editing the config or using the plugin API. It’s worth noting that Wayfire can also tile with add-ons, but it’s not a pure tiler like Sway/Hyprland. On our hardware, Wayfire would run smoothly and could show off graphical capabilities (the iGPU can handle compositing at 4K, though heavy effects might tax it slightly – but those can be turned off as needed).

Honorable mentions: **Labwc** (Openbox-like stacking compositor) and **dwl** (another minimal tiler, a Wayland re-implementation of dwm in C) are also options. Labwc uses Openbox’s XML configs (less friendly for LLM parsing) while dwl requires editing C code to configure (very advanced usage, though an AI could theoretically do it, it’s not as straightforward as a runtime config). The five above strike a good balance of *scriptability and community support*.

**Choosing one:** For our setup, we’ll proceed with **Sway** as the window manager in the installation plan. Sway is stable, well-documented, and minimal – a great starting point for a highly automated environment. It will cover our needs (tiling for productivity, easy config for automation). We’ll also integrate supporting tools like **Waybar** (a status bar for Wayland, configurable via JSON), **wofi** or **rofi** (application launcher menus), and other utilities, all of which have text configs. Using Sway doesn’t preclude trying others later – e.g. we could install Hyprland or Wayfire alongside and experiment, since they mostly coexist (just run one at a time). Sway’s similarity to i3 will also help in leveraging existing i3 config knowledge.

Now, with **Arch Linux** as the base OS and **Sway** as the WM (our chosen “setup”), let’s outline the step-by-step installation and configuration plan. We will start from a vanilla installation medium and end with a fully configured development environment ready to harness the power of our ThinkPad.

## Installation and Configuration Plan (Arch Linux + Sway)

In this section, we detail the process of installing Arch Linux on the ThinkPad P16 Gen2 and configuring it to meet all the requirements. We’ll use **Btrfs** for the filesystem (to allow snapshots for rollback) and set up the **Sway** Wayland compositor with a selection of tools to create a productive, scriptable environment. Steps are organized sequentially, from base install to user environment setup. *Note:* If using a different distro from the list, the high-level steps (partitioning, enabling snapshots, installing similar packages, etc.) will apply, but commands and tools will differ (refer to that distro’s documentation in such cases). Here we focus on Arch, leveraging its official docs and community best practices.

### 1. Prepare Installation Media and BIOS

1. **Download Arch ISO & create USB:** Obtain the latest Arch Linux ISO from [archlinux.org](https://archlinux.org/download) and create a bootable USB (e.g. using `dd` or Rufus). Arch’s ISO is small and boots into a live CLI environment.

2. **BIOS settings:** Boot the ThinkPad and press **F1** to enter BIOS. Ensure the system is in **UEFI mode** (Arch supports UEFI well). Since secure boot isn’t required, you may disable it to simplify setup (or leave it and enroll Arch’s keys later, but that’s outside scope). Also, enable **Intel VT-x/VT-d** in BIOS if not on by default (for virtualization support), and ensure the 4TB SSD is recognized. The BIOS should be set to use **Discrete Graphics** only if an NVIDIA GPU was present, but in our case it’s just the integrated Intel UHD, so no special hybrid graphics toggle needed.

3. **Boot from USB:** Select the USB UEFI boot option. At the Arch boot menu, choose the default Arch Linux entry. You’ll get a root shell on the live environment.

### 2. Disk Partitioning and Filesystem Setup

We’ll use GPT partitioning on the 4 TB SSD. Plan a simple scheme: an EFI System Partition (\~300 MB FAT32) for booting, and the rest of the disk as a Btrfs partition for the system (optionally, one could create separate partitions for `/home` or others, but using Btrfs subvolumes is more flexible for snapshots). 192 GB RAM is plenty to avoid swap for most uses (especially as we’re not hibernating given no encryption requirement), so we can skip a swap partition and use a swapfile or zram later if needed.

1. **Partition the disk:** Identify the disk (likely `/dev/nvme0n1`). Use `fdisk` or `parted`. For example, using `parted`:

   * `parted /dev/nvme0n1 -- mklabel gpt`
   * `parted /dev/nvme0n1 -- mkpart ESP fat32 1MiB 301MiB` (EFI partition \~300MiB)
   * `parted /dev/nvme0n1 -- set 1 boot on` (set ESP flag)
   * `parted /dev/nvme0n1 -- mkpart primary btrfs 301MiB 100%` (rest as Btrfs)
     This yields `/dev/nvme0n1p1` (EFI) and `/dev/nvme0n1p2` (Btrfs root).
2. **Format partitions:**

   * Format the EFI partition: `mkfs.fat -F32 /dev/nvme0n1p1`.
   * Format the root partition to Btrfs: `mkfs.btrfs -L "arch_root" /dev/nvme0n1p2`.
3. **Create Btrfs subvolumes:** Mount the Btrfs and set up subvolumes for snapshot support. For example:

   * `mount /dev/nvme0n1p2 /mnt`
   * `btrfs su cr /mnt/@` (this will be the root subvolume)
   * `btrfs su cr /mnt/@home` (home subvolume)
   * `btrfs su cr /mnt/@snapshots` (snapshot storage)
   * Optionally: `btrfs su cr /mnt/@var` etc., but since openSUSE’s scheme excludes many system dirs from snapshots, we might emulate that. Simpler: we’ll snapshot everything except home by having separate @home.
   * Unmount: `umount /mnt`.
4. **Mount subvolumes:**

   * `mount -o compress=zstd,subvol=@ /dev/nvme0n1p2 /mnt` (this mounts the root subvolume at /mnt).
   * `mkdir -p /mnt/{home,.snapshots}`
   * `mount -o compress=zstd,subvol=@home /dev/nvme0n1p2 /mnt/home`
   * `mount -o compress=zstd,subvol=@snapshots /dev/nvme0n1p2 /mnt/.snapshots`
     The compression option is optional but offers better disk utilization with minimal cost on a fast CPU.
   * Create the EFI mount point: `mkdir /mnt/boot` (we’ll mount ESP at /boot for simplicity, since we plan to use systemd-boot which reads EFI directly).
   * `mount /dev/nvme0n1p1 /mnt/boot`.
5. At this point, `/mnt` is our future root, with subvolumes in place. The structure ensures that when we snapshot the `@` subvolume, it won’t include `/home` (so user files aren’t rolled back) – this mirrors openSUSE’s strategy.

### 3. Install Arch Base System

1. **Select mirrors:** Optionally edit `/etc/pacman.d/mirrorlist` on the live system to ensure fast mirrors (the Arch wiki has scripts like `reflector` for that).

2. **Install base packages:** Use `pacstrap` to install the base system into /mnt. For a minimal start:

   ```bash
   pacstrap /mnt base linux linux-firmware base-devel vim
   ```

   * `base` includes core userland.
   * `linux` is the latest Linux kernel, `linux-firmware` provides firmware (important for Wi-Fi, etc., the AX211 Wi-Fi 6E card will need firmware from this).
   * `base-devel` is a group of compilers and tools (GCC, make, etc.) necessary for development and for AUR packages. (We include it now to save effort later).
   * Add `btrfs-progs` to manage Btrfs, and `git` (for future use cloning dotfiles or AUR helpers), e.g.:

   ```bash
   pacstrap /mnt btrfs-progs git
   ```

   * We will also install microcode updates: `intel-ucode` package for Intel CPU. It can be installed now or later; doing now is fine:

   ```bash
   pacstrap /mnt intel-ucode
   ```

3. **Generate fstab:**

   ```bash
   genfstab -U /mnt >> /mnt/etc/fstab
   ```

   Check `/mnt/etc/fstab` to ensure subvol options are present for the Btrfs mounts.

4. **Chroot into the new system:**

   ```bash
   arch-chroot /mnt
   ```

   Now we’re inside the installed system as root.

5. **Basic config:**

   * Set timezone: e.g. `ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime` and run `hwclock --systohc`.
   * Locale: edit `/etc/locale.gen`, uncomment `en_US.UTF-8 UTF-8` (and any others needed), then run `locale-gen`. Create `/etc/locale.conf` with `LANG=en_US.UTF-8`.
   * Network: create `/etc/hostname` (e.g. `echo "thinkpad-p16" > /etc/hostname`) and match it in `/etc/hosts`:

     ```
     127.0.0.1   localhost
     ::1         localhost
     127.0.1.1   thinkpad-p16.localdomain thinkpad-p16
     ```
   * Root password: `passwd` and set a strong password (or leave blank if you plan to use only your user via sudo, but better to set one).

6. **Mkinitcpio hooks:** The default `mkinitcpio.conf` should include `autodetect` and `modconf`; ensure `btrfs` is included in the MODULES or at least in the filesystem hooks (recent Arch kernels include Btrfs support built-in, so it may not need explicit mention). Usually it’s fine out of the box. Run `mkinitcpio -P` to generate the initramfs images for the installed kernel.

7. **Install a bootloader (systemd-boot):** We choose systemd-boot for simplicity with UEFI:

   * `bootctl install` will install systemd-boot to the EFI partition (mounted at /boot). It should create `/boot/EFI/systemd` etc.
   * Create a boot loader entry: `/boot/loader/entries/arch.conf` with:

     ```
     title   Arch Linux
     linux   /vmlinuz-linux
     initrd  /intel-ucode.img
     initrd  /initramfs-linux.img
     options root=PARTUUID=<UUID-of-nvme0n1p2> rw rootflags=subvol=@
     ```

     (Use `blkid` to get the PARTUUID of the root partition). This config tells the kernel to use the Btrfs subvol @ as root.
   * Set default: edit `/boot/loader/loader.conf` to contain:

     ```
     default arch.conf
     timeout 3
     editor no
     ```

   Now our system should boot with systemd-boot. (If instead using GRUB, one would install grub and run `grub-install` and `grub-mkconfig`, but systemd-boot is straightforward and integrates with Snapper via a plugin if needed).

8. **Enable needed services:** For network, we’ll enable systemd-networkd or use NetworkManager. For simplicity, let’s install NetworkManager:

   ```bash
   pacman -S networkmanager
   systemctl enable NetworkManager
   ```

   This will ensure network on first boot (the Intel Wi-Fi AX211 should be supported by `linux-firmware`; you can use nmcli or nmtui to connect, or if using Ethernet it might work via systemd-networkd by default with a simple DHCP config).
   Additionally, enable chrony or systemd-timesyncd for time sync (Arch enables timesyncd by default typically, just ensure /etc/ timesyncd.conf is okay or install chrony if preferred).

9. **Create an admin user:** Add a regular user (we shouldn’t operate long-term as root). For example:

   ```bash
   useradd -m -G wheel,audio,video,libvirt -s /bin/bash argo
   passwd argo
   ```

   (We add `libvirt` group anticipating virtualization usage; we’ll configure libvirt later). Ensure the `wheel` group has sudo privileges: install sudo (`pacman -S sudo`) and edit `/etc/sudoers` to uncomment `%wheel ALL=(ALL) ALL`.

10. **Reboot:** Exit chroot (`exit`), unmount (`umount -R /mnt`), and reboot. Remove the USB so it boots from the SSD. If all went well, systemd-boot shows Arch Linux and then you land on a TTY login.

At this stage, we have a minimal Arch system. Next, we’ll configure **snapshot tools** and then proceed to install the GUI and development tools.

### 4. Enable Btrfs Snapshots & Rollback Tools

To support rollbacks, we’ll set up Snapper to take snapshots of the root filesystem, and integrate it with pacman via the snap-pac hook.

1. **Install Snapper and snap-pac:**

   ```bash
   sudo pacman -S snapper snap-pac grub-btrfs
   ```

   * `snap-pac` provides a Pacman hook that automatically creates snapshots *before and after* each package operation. This is critical for rollback: if an update breaks something, you have a snapshot from right before the update to restore.
   * `grub-btrfs` is a script that can add snapshot menu entries to GRUB. Since we chose systemd-boot, `grub-btrfs` might not be applicable. Instead, we could use the systemd-boot + Btrfs snapshots approach (there’s a tool called `bootable Btrfs snapshots` that integrates with systemd-boot as well, though not as straightforward as grub-btrfs). For simplicity, one option is to later use a live USB to rollback if needed, or switch to GRUB for easy snapshot booting. (Alternatively, one can use Snapper’s rollback feature offline to restore @ from a snapshot).
   * For now, we’ll set up Snapper and know that snapshots exist; we can manually rollback by booting into a snapshot via grub-btrfs or using snapper rollback command.

2. **Configure Snapper for root:**

   ```bash
   sudo snapper -c root create-config /
   ```

   This sets up `/etc/snapper/configs/root` for the root subvolume. It also created a `.snapshots` subvolume (which we already have) and adds an entry in `/etc/conf.d/snapper`. We already have a separate `.snapshots` subvolume mounted, which is ideal to keep snapshots separate from the main volume (as per our fstab). We might need to adjust Snapper’s config to use `.snapshots` – by default it will use the path we gave (which matches what we have).

   * Ensure in `/etc/snapper/configs/root`: `SUBVOLUME="/@"` and `SNAPSHOT_DIRECTORY="/.snapshots"` (should be by default since we created with /). Also set reasonable snapshot cleanup policies (like number cleanup algorithm or timeline). For example, enable timeline snapshots (hourly, daily limits) if desired by setting `TIMELINE_CREATE="yes"` and tweaking `TIMELINE_LIMIT_*` values.
   * Give our user permission to manage snapshots: add `ALLOW_USERS="argo"` in that config (so the user can use snapper without sudo for listing snapshots, etc., if part of the snapper group).
   * Enable the timeline and cleanup timers:

     ```bash
     sudo systemctl enable --now snapper-timeline.timer
     sudo systemctl enable --now snapper-cleanup.timer
     ```

     This ensures snapshots are taken periodically (timeline) and old ones purged to save space.

3. **Verify pacman hook:** The `snap-pac` package places hook files in `/etc/pacman.d/hooks`. Check `/etc/pacman.d/hooks/50-btrfs-snap-pac.hook` (or similar) – it should be configured to call snapper pre/post. For instance, when you later run `sudo pacman -Syu`, you’ll see in the output that it creates a pre snapshot # and a post snapshot # around the transaction. Test it by installing a small package:

   ```bash
   sudo pacman -S asciinema
   ```

   and then `sudo snapper -c root list` to see if new snapshots appeared for that pacman operation (they should, labeled with the pacman command).

4. **(Optional) GRUB for snapshot booting:** Since systemd-boot doesn’t auto-list snapshots, a more straightforward approach for rollback would be to switch to GRUB and use `grub-btrfs`. For completeness:

   * Install GRUB: `pacman -S grub efibootmgr`.
   * Run `grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=ArchGRUB`.
   * Edit `/etc/default/grub` to add `GRUB_BTRFS_SAVE_SNAPSHOT_NAME=true` if using grub-btrfs.
   * Run `grub-mkconfig -o /boot/grub/grub.cfg`.
   * Enable the `grub-btrfs.path` service which monitors for new snapshots and updates grub menu: `systemctl enable --now grub-btrfs.path`.
     Then on boot, the GRUB menu “Arch Linux snapshots” section would list available snapshots and let you boot into them. This greatly simplifies recovery – you can choose a snapshot, boot it, and use Snapper to rollback.
     However, if we prefer systemd-boot, we’ll rely on using a live USB if needed to do `snapper rollback`. For now, we’ll assume our Snapper + snap-pac is set.

Now we have automatic snapshots for every update – a safety net for our rolling system.

### 5. Install Graphics Driver and Wayland Desktop (Sway)

Next, we install the GUI stack: since we’re using Wayland with Sway, we need Mesa drivers and the Sway compositor (plus related tools).

1. **Graphics drivers (Intel):** For Intel integrated GPU:

   ```bash
   sudo pacman -S mesa vulkan-intel lib32-mesa lib32-vulkan-intel
   ```

   * `mesa` provides OpenGL and Vulkan drivers for Intel (and others).
   * `vulkan-intel` is the Vulkan driver (the i9-13980HX has an Xe-LP graphics, supported by this).
   * The `lib32-` packages are 32-bit libs for running 32-bit games/apps under wine/Steam (from the multilib repo). **Enable multilib** if not already: edit `/etc/pacman.conf`, uncomment:

     ```
     [multilib]
     Include = /etc/pacman.d/mirrorlist
     ```

     then run `sudo pacman -Sy` to refresh. After that, install the lib32 packages. (Multilib is required for Steam’s 32-bit games and WINE’s 32-bit support).
   * Additionally, install `xf86-video-intel` (the Xorg driver) in case Xwayland might use it – however, modern wisdom often says to rely on modesetting for Intel. We can skip it; Xwayland will use modesetting driver which is fine.

2. **Wayland and Sway packages:**

   ```bash
   sudo pacman -S sway waybar wofi xorg-server-xwayland alacritty
   ```

   * `sway` pulls in its dependencies (wlroots, etc.).
   * `waybar` is a configurable top/bottom bar (like i3bar replacement). We’ll use it to display status info (battery, CPU, memory, time, etc.). It’s configured via JSON and CSS, which is easily editable.
   * `wofi` is a Wayland native application launcher (like rofi/dmenu for Wayland). We install it to have a nice app menu (as seen in the earlier screenshot where Blender, Firefox, etc., are listed).
   * `xorg-server-xwayland` provides Xwayland support so any X11-only apps can run under Sway. (This might be installed as dependency of sway, but we include explicitly to be safe).
   * A terminal: `alacritty` is a modern GPU-accelerated terminal emulator, we choose it for performance (and it’s Wayland-compatible). Other options: `foot` or `kitty` are also excellent Wayland-friendly terminals.
   * We might also want `swayidle` (for screen locking idling), `swaylock` (lock screen), and maybe `gammastep` (for night light).

     ```bash
     sudo pacman -S swayidle swaylock
     ```
   * Install a notification daemon (since no DE provides one): e.g. `mako` for Wayland notifications.

     ```bash
     sudo pacman -S mako
     ```
   * Bluetooth tool (if you plan to use Bluetooth devices): `blueman` (though for CLI, `bluetoothctl` is fine).
   * **Display manager or autologin:** To log in graphically to Sway, we can:

     * Use **greetd** (a minimal, configurable login manager for Wayland/*tty*). Greetd with a tui or GTK greeter can start Sway. Or,
     * Use no DM: simply log in on TTY and have the shell start Sway if on the console. We can enable autologin for our user on a tty and run Sway via systemd service. Let’s use greetd for a cleaner approach.
   * Install greetd and the **tuigreet** text UI greeter (or `gtkgreet` for a graphical one):

     ```bash
     sudo pacman -S greetd tuigreet
     ```

     Configure greetd: edit `/etc/greetd/config.toml`:

     ```toml
     [terminal]
     vt = 1

     [default_session]
     command = "sway"
     user = "argo"
     ```

     This would have greetd automatically log into sway as user argo when you tap enter at the greet screen (tuigreet just shows a prompt). We can refine this later, but that’s one simple way.
     Enable greetd: `sudo systemctl enable greetd`.

3. **Configure Sway and Wayland apps:**

   * As user `argo`, create Sway config directory: `mkdir -p ~/.config/sway`. Copy the default config: `cp /etc/sway/config ~/.config/sway/config` for reference.
   * Edit `~/.config/sway/config` to our preferences:

     * Set \$mod (modifier) to Super/Win: (in config it’s typically set to Mod1 (Alt) or Mod4 (Super) – we likely want Mod4).
     * Configure outputs: by default, Sway will detect the 3840x2400 display and set scaling. If scaling is off, we can set `output eDP-1 scale 2` (for example to get 200% DPI scaling if needed).
     * Keyboard layout if needed (e.g., add `input "type:keyboard" xkb_layout "us"` or similar).
     * Keybindings: ensure common ones exist (open terminal, launcher, etc.). The default config binds `$mod+Return` to foot terminal; change it to alacritty: `bindsym $mod+Return exec alacritty`.
     * Set up waybar autostart: add `exec waybar` in config (waybar can also be launched via Sway config so it starts with session).
     * Launch mako: add `exec mako` (notification daemon).
     * Idle/lock: for security, add:

       ```
       exec swayidle -w \
         timeout 300 'swaylock -f -c 000000' \
         timeout 600 'systemctl suspend' \
         before-sleep 'swaylock -f -c 000000'
       ```

       This locks screen after 5 min and suspends after 10, etc., using swaylock.
   * **Waybar configuration:** Create `~/.config/waybar/config` and `~/.config/waybar/style.css`. The config is JSON; we can use provided examples from Arch Wiki or Waybar docs. For example, to display workspaces, CPU, memory, battery, clock:

     ```json
     {
       "layer": "top",
       "position": "bottom",
       "modules-left": ["sway/workspaces"],
       "modules-center": ["sway/window"],
       "modules-right": ["idle_inhibitor", "network", "battery", "memory", "cpu", "clock", "tray"],
       "battery": { "format": "{percent}% {icon}" }
     }
     ```

     (This is a simplistic example – Waybar can show a lot. We’ll adjust as needed. The style.css can define colors, spacing.)
   * **Wofi launcher:** Create `~/.config/wofi/config` if needed (or use defaults). We can bind a key to it in Sway config, e.g. `bindsym $mod+d exec wofi --show drun`.
   * **Testing:** At this point, if we reboot, greetd should auto-start Sway. But it might be safer to first test Sway manually:

     * From the text console (TTY1), login as argo and run `sway`. If all is well, Sway should start (you’ll see your empty desktop or perhaps the default wallpaper and a bar at bottom if waybar is running). Open a terminal (\$mod+Return) to ensure alacritty opens, etc. If something misconfigured, check logs (`journalctl --user-unit sway.service` if we ran via systemd, or just read Sway’s output in console).
     * Once satisfied, log out (`swaymsg exit` or kill it with Ctrl+Shift+e by default).
   * **Clipboard persistence:** Install `wl-clipboard` so that copy-paste works between Wayland and Xwayland nicely (optional).
   * **Firefox for Wayland:** Install `firefox` and set `MOZ_ENABLE_WAYLAND=1` in environment to run it in native Wayland (we can put that in `/etc/environment` or in the sway config via `exec export MOZ_ENABLE_WAYLAND=1`).
   * **GNOME disk management for convenience:** Could install `gnome-disk-utility` for GUI disk tasks, it runs fine under Wayland and helps in mounting external drives if needed.

At this juncture, we have a functioning graphical desktop on Wayland. It’s minimalist (a tiling WM with a bar and launcher) but highly customizable via our text configs. We can already see how scriptable it is – e.g., the keybindings in Sway config or the waybar JSON can be easily adjusted by editing files (or by an AI script).

### 6. Development Environment Setup

Now onto installing and configuring the development and cloud tools. This high-end system is meant for heavy development in numerous languages, so we’ll set up compilers, interpreters, and helpful SDKs. Arch’s rolling nature ensures these will be latest versions.

1. **Essential build tools:** We included `base-devel` during install (which gave GCC, Make, etc.). Additionally:

   * Install **LLVM/Clang** (for C/C++ as an alternative to GCC, and for things like Rust which sometimes use Clang for bindgen):

     ```bash
     sudo pacman -S llvm clang
     ```
   * **Git** is installed (we did earlier). Also install **mercurial** and **subversion** if needed for some projects.
   * **Editor/IDE:**

     * If you use Neovim/Vim: `pacman -S neovim` (Neovim 0.9+ is great for LSP support). We can later configure it with plugins for language servers.
     * If VS Code is preferred: `sudo pacman -S code` (or `code-features` variant from AUR for proprietary bits, or `vscodium` open build).
     * Emacs: `pacman -S emacs` if the user is an Emacs enthusiast (with 192GB RAM, maybe running Emacs with all packages is fine!).
     * We assume possibly VSCode or Vim + LSP for coding. In either case, it’s good to have a **terminal multiplexer** like `tmux` installed for terminal workflows: `pacman -S tmux`.

2. **Language runtimes & compilers:**

   * **Python:** Arch’s `python` package gives the latest Python 3.x. It’s installed (base includes it). For managing packages, one can use `pip` in virtual environments. We’ll install some scientific libs:

     ```bash
     sudo pacman -S python-pip ipython python-numpy python-pandas python-scikit-learn jupyterlab
     ```

     (Alternatively, one might use Miniconda, but on Arch it’s often preferable to use pacman or pip in venv). We might also install `python-virtualenv` and `python-poetry` for environment management.
     For ML: **PyTorch** and **TensorFlow** – Arch has `python-pytorch` and `python-tensorflow` (with CUDA variants if NVIDIA GPU was present). Since we have only CPU/GPU integrated, we can use regular pytorch which likely uses CPU (or oneAPI on Intel). Let’s install PyTorch CPU:

     ```bash
     sudo pacman -S python-pytorch python-torchvision
     ```

     (If we needed GPU support and had an NVIDIA, we’d use `python-pytorch-cuda` and install CUDA toolkit. For Intel integrated, oneAPI’s GPU acceleration for TensorFlow/PyTorch is complex, skip for now.)

     * **Jupyter**: We installed jupyterlab, which can be launched in browser for notebooks – good for data science.
     * **pip**: for any other ML libraries like HuggingFace Transformers or LangChain (which we’ll do later in the LLM section), we’ll use pip in a venv. We can also consider using systemd-nspawn for containerizing these, but that’s advanced.
   * **Java:** Install JDK (Java 17 LTS or latest):

     ```bash
     sudo pacman -S jdk-openjdk maven gradle
     ```

     This provides Java compiler and build tools. Set `JAVA_HOME=/usr/lib/jvm/java-17-openjdk` in environment or use archlinux-java to set default.
   * **Rust:** It’s common to use **rustup** to manage Rust toolchains. Arch has `rustup` package which lets the user install stable/beta toolchains easily.

     ```bash
     sudo pacman -S rustup
     rustup default stable
     ```

     This will download the latest stable Rust and its components. Alternatively, Arch’s `rust` package provides stable compiler without rustup’s flexibility, but rustup is recommended for development. Also ensure `cargo` (comes with rustup) is in PATH (it will be).
   * **Node.js & JavaScript:**

     ```bash
     sudo pacman -S nodejs npm yarn
     ```

     This gives Node.js (for any web development, or running some ML tools with node frontends).
   * **Haskell:** The GHC compiler and Cabal:

     ```bash
     sudo pacman -S ghc cabal-install stack
     ```

     This provides GHC (Glasgow Haskell Compiler), Cabal (package manager), and Stack (alternate build tool). Haskell devs might prefer Stack or Nix, but we have them available.
   * **Lisp:** For Common Lisp:

     ```bash
     sudo pacman -S sbcl clojure
     ```

     SBCL is a popular Common Lisp implementation; Clojure (for a Lisp on JVM) also if needed.
     For Emacs Lisp obviously Emacs itself is needed which we included as optional.
     If Scheme is needed: `sudo pacman -S guile` or others.
   * **C/C++:** Already covered by GCC/Clang. If doing low-level development, maybe install tools like `valgrind`, `gdb`:

     ```bash
     sudo pacman -S gdb valgrind lldb
     ```

     Also `cmake` and `ninja` build systems:

     ```bash
     sudo pacman -S cmake ninja
     ```
   * **Go:**

     ```bash
     sudo pacman -S go
     ```
   * **Other languages:** Arch has many. For example, if needed:

     * **PHP**: `pacman -S php`
     * **Ruby**: `pacman -S ruby`
     * **R**: `pacman -S r`
     * We likely won’t pre-install all, only those needed. The ones explicitly asked: Python, Java, Rust, C/C++, JS, Haskell, Lisp – we’ve done those.
   * After installing compilers, you might want to ensure environment variables for JVM or others are set. Arch’s `/etc/profile.d/jdk.sh` sets JAVA\_HOME, etc., automatically when installing openjdk.

3. **Database/Servers (optional):** If developing backends:

   * Install Docker or Podman for containerization:

     ```bash
     sudo pacman -S docker
     sudo systemctl enable --now docker
     ```

     (Add user to `docker` group if needed). Or use Podman (rootless containers):

     ```bash
     sudo pacman -S podman podman-compose
     ```

     It’s nice to have container capability for testing deployments or running databases without installing globally.
   * Databases: PostgreSQL, MySQL if needed (but can also run via Docker). We’ll skip unless needed explicitly.

4. **Cloud CLI Tools:**

   * **AWS CLI:**

     ```bash
     sudo pacman -S aws-cli-v2
     ```

     This provides the `aws` command for AWS services. Configure with `aws configure` later (it will store creds in `~/.aws`).
   * **Google Cloud SDK:** Not in official repo, but AUR has it (`google-cloud-sdk`). Alternatively, install via pip: `pip install google-cloud-cli` – but recommended is AUR. We can do:

     ```bash
     paru -S google-cloud-sdk
     ```

     (This assumes we install an AUR helper like `paru` or `yay` to handle AUR packages. Let’s install `paru` quickly using rust as it’s written in Rust:

     ```bash
     sudo pacman -S --needed base-devel
     git clone https://aur.archlinux.org/paru.git
     cd paru
     makepkg -si
     ```

     Then use `paru`).
   * **Azure CLI:** Also AUR (`azure-cli`). Or pip: `pip install azure-cli`.
   * **Terraform & Infrastructure as Code:**

     ```bash
     sudo pacman -S terraform ansible
     ```

     (Terraform for provisioning, Ansible for config management tasks).
   * **Kubernetes:**

     ```bash
     sudo pacman -S kubectl helm kind
     ```

     (kubectl for K8s control, Helm for charts, kind to spin up local clusters if needed).
   * **OpenStack CLI or others** if relevant can be pip installed. Possibly not needed for our scenario.
   * We group these under a common directory or ensure they are in PATH (they will be in /usr/bin from pacman installs).
   * **VPN/SSH:** ensure `openssh` was installed (it is in base). For VPN like OpenVPN or WireGuard if needed: `pacman -S openvpn wireguard-tools`.

5. **AI/ML Specific:**

   * We have PyTorch and such installed. For large models, consider installing **Jupyter** which we did, and maybe **CUDA** (though on Intel iGPU, CUDA won’t be used; if an eGPU or external card is used in future, could add).
   * **Intel oneAPI**: If leveraging integrated GPU for compute, Intel’s oneAPI toolkit could be installed. This is heavy (\~4GB) and not in main repos. Possibly skip since most frameworks use CPU.
   * Tools like **Jupyter** are installed. Could also install VSCode extensions for Python, etc., or Emacs’s EIN if using Emacs for notebooks.

At this point, all major languages and tools are installed. It’s a good time to update the **shell environment** for convenience:

* The default shell for user is bash. We can configure `~/.bashrc` and `~/.bash_profile` as needed (like adding handy aliases, enabling pyenv or nvm if those were to be used instead).
* If the user prefers `zsh` with oh-my-zsh: `pacman -S zsh` and chsh to zsh. It’s personal preference. For now, bash is fine and widely scriptable.

### 7. Gaming Setup (Steam, Wine, Proton)

The ThinkPad P16 has an Intel GPU, which limits gaming to less demanding titles or older games, but we will set up the environment for Steam/Proton and WINE so that it’s ready for gaming and testing anyway. Perhaps in the future an eGPU or simply for playing indie games or using Steam’s cloud gaming, etc., it’s useful.

1. **Steam:** Ensure multilib is enabled (we did). Install Steam:

   ```bash
   sudo pacman -S steam
   ```

   This brings in necessary 32-bit libs. Since we already installed `mesa` and `vulkan-intel` plus lib32 versions, Steam should find our Vulkan driver (for DXVK etc.).

   * Configure Steam to use Wayland: currently, Steam still runs on Xwayland (that’s fine). It will pop up in Sway via Xwayland. We might set `MOZ_ENABLE_WAYLAND=1` in environment for any embedded browser (like store, but not crucial).
   * Add user to any needed groups (not necessary for GPU since modesetting via KMS doesn’t require it, but historically some added to video group; Arch uses udev rules to allow video).
   * Steam can be launched from application launcher (we should see it in wofi’s list once installed).

2. **Proton and Games:** Steam will handle Proton downloads for Windows games (the official Proton or Proton-GE which some people install manually – we can skip manual since user can add Proton GE if needed by putting files in `~/.steam/root/compatibilitytools.d/`).

   * We should install `wine` and `winetricks` too for non-Steam games:

     ```bash
     sudo pacman -S wine-staging winetricks lutris
     ```

     * `wine-staging` is a version of WINE with extra patches (good for latest game compatibility).
     * `winetricks` helps install things like DirectX runtime, etc., in Wine prefixes.
     * `lutris` is a game manager that can configure WINE prefixes for various games and emulators easily, pulling community scripts.
     * These give the user flexibility to install say GOG games or run productivity Windows apps if needed.
   * **DXVK/VKD3D:** Arch’s wine-staging includes DXVK by default usually. If not, `pacman -S dxvk-bin` can be installed for Vulkan-based D3D. But since we have Intel GPU, Direct3D to Vulkan translation performance is modest, but at least functional.
   * Check that 32-bit Vulkan works: `sudo pacman -S lib32-vulkan-intel` we did; `vulkaninfo` and `vulkaninfo32` should both work.

3. **Controllers/VR (if applicable):** If using Xbox controller, `pacman -S xboxdrv` or just rely on kernel xpad. For VR (rare on iGPU), skip.

4. **Performance tuning:**

   * Since no discrete GPU, nothing to do about NVIDIA drivers. The Intel GPU performance is what it is; we should make sure the CPU can turbo – by default on AC power it will. Could install `thermald` to help with thermal management if hitting thermal limits.
   * For games, consider installing `gamemode`:

     ```bash
     sudo pacman -S gamemode lib32-gamemode
     ```

     Feral’s gamemode can optimize CPU governor while gaming. Lutris and Steam’s proton can auto-invoke it.
   * TLP (power management): if this laptop will be used on battery often, installing `tlp` can help battery life. But it might reduce performance. We can configure it to apply on battery only. Up to user:

     ```bash
     sudo pacman -S tlp
     sudo systemctl enable tlp
     ```

     But possibly skip if performance is priority and battery life is secondary.

5. **Testing Steam:** Launch Steam (it may need Xwayland, which we have). It should update itself and open. Log in, try a small game or a demo to confirm things. Note any missing dependency from console logs.

### 8. LLM Orchestration and AI Tools

With development tools and environment ready, we now set up specific **LLM orchestration tooling**. This involves libraries and frameworks that allow controlling or integrating large language models, possibly across multiple agents or tools. The user’s question references *“LLM orchestration tooling and user environment configuration”* – likely meaning frameworks like LangChain, as well as any infrastructure to run local LLMs.

Steps:

1. **Python environment for AI:** We will create a dedicated Python virtual environment for LLM experiments to avoid cluttering system Python. For example, use `venv`:

   ```bash
   python -m venv ~/envs/llm-orch
   source ~/envs/llm-orch/bin/activate
   ```

   (We can add an alias or use direnv to auto-activate if in a specific project directory).

2. **Install LLM orchestration frameworks:** The major library is **LangChain**, which helps in chaining LLM calls and tools. Also possibly **AutoGPT** or similar multi-agent frameworks. We use pip (since these evolve fast, pip ensures latest release):

   ```bash
   pip install langchain openai transformers huggingface_hub
   ```

   * `langchain` for building agent chains.
   * `openai` for OpenAI API access (if using GPT-4 or others via API).
   * `transformers` and `huggingface_hub` to run local models or download them (like GPT-Neo/X, etc.).
   * Optionally, install **LLAMA.CPP** Python bindings if planning to run local LLaMA models on CPU: `pip install llama-cpp-python`.
   * If using multiple agents frameworks: e.g. **SuperAGI** or **AutoGPT**, these can be installed or cloned. For instance, to get AutoGPT:

     ```bash
     git clone https://github.com/Significant-Gravitas/Auto-GPT.git ~/AutoGPT
     cd ~/AutoGPT
     pip install -r requirements.txt
     ```

     AutoGPT is still experimental, but it’s an example of orchestrating multiple steps autonomously.
   * We also install **Jupyter Lab** (done) to run notebooks for prototyping LLM chains.
   * If using IBM’s orchestration (the IBM references appear in search), perhaps not necessary since we have open tools.

3. **APIs and Keys:** Ensure we manage API keys securely:

   * For OpenAI API, one would put the key in an environment variable `OPENAI_API_KEY` or use a `.env` file that LangChain can read.
   * For HuggingFace Hub (for model downloads), get an auth token and run `huggingface-cli login` to cache it.
   * For cloud-specific AI services (like AWS Sagemaker, etc.), AWS CLI configured earlier can be used with boto3.

4. **LLM runtime (local):** With 192 GB RAM, we can run some smaller models locally if desired (like a 7B or 13B parameter model in 4-bit quantization). Setting that up:

   * Use `transformers` to download e.g. Facebook’s LLaMA 7B (if user has access) or an open model like EleutherAI’s GPT-J-6B. We could use the huggingface\_hub to fetch a model:

     ```python
     from transformers import AutoModelForCausalLM, AutoTokenizer
     model = AutoModelForCausalLM.from_pretrained("EleutherAI/gpt-neo-2.7B")
     ```

     However, these large downloads are lengthy. Possibly user will handle model downloads as needed.
   * For more efficient local inference, consider the `llama.cpp` approach:

     * Install `clang` (done) and compile llama.cpp from source, or use `pip install llama-cpp-python` which includes it.
     * This allows running LLaMA models on CPU with 4-bit quantization. For instance, a 7B parameter model can fit in \~4GB at 4-bit, which is trivial for 192GB RAM.
     * Document how to use it: (e.g. `pip install sentencepiece` needed, etc.). The user can then run `from llama_cpp import Llama` in Python to load a GGML model file.
   * These details depend on how deep the user wants to go with local models vs using cloud APIs. Our setup covers both.

5. **Agent orchestration example:**

   * Provide an example of orchestrating tools with LangChain. Possibly write a small script in `~/projects/agent.py` that uses LangChain’s agents to answer a query by searching documentation or running a tool. We won’t flesh it out fully here, but the environment is ready to support it.
   * We can note: *LangChain allows chaining LLM calls with external tools, enabling complex workflows. For instance, you can set up an agent that given a task can decide to call the AWS CLI (which we installed) to fetch some cloud info, then use an LLM to analyze it.* The combination of all our installed tools plus LLM frameworks means such multi-step tasks can be automated.

6. **Version control and Dotfiles:**

   * It’s wise to keep configuration in version control. We have so many config files (sway, waybar, shell rc, etc.). We recommend initializing a **git repository for dotfiles** in the home directory (or a subset).

     ```bash
     git init --bare $HOME/.cfg
     alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
     config config --local status.showUntrackedFiles no
     ```

     Then `config add` the relevant dotfiles and commit. This way we can easily revert config changes or deploy them to a new machine (this is a common dotfiles management trick).
   * Also keep a list of installed packages (e.g. `pacman -Qqe > pkglist.txt`) so we know what’s installed in case we want to script a fresh install reproducibly.

7. **Security & Backups:**

   * Though not asked, on such a system consider enabling **firewall** (Arch has `ufw` or just use `iptables`/nft). Possibly:

     ```bash
     sudo pacman -S ufw
     sudo ufw default deny incoming
     sudo ufw default allow outgoing
     sudo ufw enable
     ```

     This will protect if the laptop is directly exposed on networks. For development use where we might run local servers, open ports as needed.
   * **Backups:** Using Btrfs snapshots is not a substitute for backups (especially since our snapshots are on the same disk). We should set up an external backup plan:

     * Possibly using `rsync` or `btrfs send` to an external drive regularly. For example, one could use Snapper’s `snapper -c root create` to make a checkpoint, then `btrfs send` that snapshot to a USB disk.
     * Or use tools like `restic` or `borg` to backup important directories (like home, and maybe a snapshot of etc).
     * Setting up a cron or systemd timer for backups would be wise for a workstation with critical projects.

8. **Testing the AI setup:**

   * Run a quick Python test:

     ```bash
     python -c "from langchain.llms import OpenAI; print(OpenAI(model_name='text-curie-001', openai_api_key='sk-...').predict('1+1?'))"
     ```

     This should call OpenAI’s API (assuming a valid key) and output something. If no key, skip actual call, but at least see if the import works.
   * Alternatively, test local transformer:

     ```bash
     python -c "from transformers import pipeline; print(pipeline('text-generation', model='EleutherAI/gpt-neo-125M')('Hello, world!', max_new_tokens=5))"
     ```

     This will download a small model and run a quick generation.

If all these tests pass, our system is fully operational for development, AI, cloud and gaming tasks.

### 9. Final Tweaks and Workflow Optimization

Finally, polish the user experience and ensure the environment is convenient:

* **Shell enhancements:** Possibly install `fzf` (fuzzy finder) for quickly searching command history or files, `pacman -S fzf`. And `ripgrep` for fast code search.
* **Prompt customization:** Use a nice bash prompt with git info (or use starship prompt by `pacman -S starship` and add to bashrc).
* **Clipboard sharing:** Ensure `wl-clipboard` and perhaps `xclip` are installed for CLI copy-paste between X11 and Wayland as needed.
* **HiDPI adjustments:** On our 16" 4K display, scaling might be needed (Sway’s `output ... scale 2`). Also adjust font DPI in any X apps via `.Xresources` if necessary for Xwayland (e.g., `Xft.dpi: 192` for 200%).
* **Laptop function keys:** Bind volume and brightness keys in Sway config using `bindsym XF86AudioRaiseVolume exec pactl set-sink-volume ...` etc., and for brightness use `brightnessctl`:

  ```bash
  sudo pacman -S brightnessctl
  ```

  Then `bindsym XF86MonBrightnessUp exec brightnessctl set +10%`.
* **Sound:** Install `pipewire` (likely already part of base in Arch nowadays) and `pipewire-pulse` for PulseAudio replacement, plus `pavucontrol` for volume GUI.

  ```bash
  sudo pacman -S pipewire pipewire-pulse wireplumber pavucontrol
  ```

  Enable pipewire service if not auto (Arch may do it by default via socket activation).
* **Testing audio and webcam:** Use `arecord`/`aplay` or `pavucontrol` to test audio playback and mic. For webcam, `mpv /dev/video0` or `obs-studio` to ensure it works. The 1080p IR webcam might need `v4l2loopback` if doing pass-through to VMs, etc. IR camera could be used with Howdy for face unlock if desired (not covered here).
* **Virtualization:** We added user to libvirt group earlier. Install QEMU/KVM and Virt-Manager:

  ```bash
  sudo pacman -S qemu-full virt-manager dnsmasq vde2 bridge-utils openbsd-netcat libvirt edk2-ovmf
  sudo systemctl enable --now libvirtd
  ```

  This allows running VMs (with 192GB RAM, one can run many!). The edk2-ovmf provides UEFI for VMs. Virt-manager provides a GUI (X11/GTK, but will run under Xwayland).
* **Check power management:** CPU: the i9-13980HX is power-hungry (55W base). On battery, consider switching CPU governor to power-saver when not needed. Tools like `auto-cpufreq` can do this or just rely on TLP’s auto mode.
* **ThinkPad specific:** Install `tlp` as above, which includes some ThinkPad extras. Also install `acpi_call` DKMS if wanting to toggle discrete GPU power (not applicable here, no discrete GPU).
* **Fingerprint reader:** The P16 Gen2 has an IR camera and fingerprint. Linux support for fingerprint (Validity sensor possibly) might be possible via `fprintd`. Install `fprintd` and `pam_fprintd` and enroll fingers if supported:

  ```bash
  sudo pacman -S fprintd
  fprintd-enroll
  ```

  Then add `auth sufficient pam_fprintd.so` to `/etc/pam.d/system-auth` above password line. This way, fingerprint or face (with Howdy) could be used for login/unlock, aligning with convenience.
* **Face unlock (Howdy):** There’s an AUR package howdy (Python/OpenCV based face auth). We can skip details, but it is something user might do.
* **Updates:** The system should be updated often to stay rolling. We should advise the user to regularly run `sudo pacman -Syu`. Because we have auto-snapshots, it’s relatively safe – if an update breaks something critical, they can reboot and select a pre-update snapshot (if using GRUB) or use a Live USB to rollback. Still, reading Arch news or subscribing to Arch announcements is wise to catch any manual interventions needed.

Finally, we have a **comprehensive, robust system**. It’s essentially a power-user Arch Linux workstation with a tiling Wayland desktop and a plethora of development tools. The entire configuration is stored in simple text files (making it easy to manage via git or to modify using scripts or an AI agent if desired). Snapshots and backups protect against mistakes, and the rolling release ensures we always have up-to-date compilers and libraries (important for staying on the cutting edge in AI).

## Conclusion

We identified five Linux distributions suited to a high-end, automation-focused workflow, and selected **Arch Linux** for the installation. We also surveyed five Wayland-compatible desktop options and built our environment with **Sway** window manager for maximal scriptability. The installation plan covered everything from base OS setup with **Btrfs snapshots** for rollbacks, through configuring a lightweight Wayland desktop, to installing a comprehensive suite of **development tools**, **cloud SDKs**, and **AI/ML frameworks**. We also set up gaming support with Steam/Proton and Wine, demonstrating the versatility of the system for both work and play.

Throughout this process, we prioritized official documentation and well-supported methods:

* We followed Arch Linux’s installation and configuration guidelines to set up a clean rolling-release base with systemd.
* We leveraged openSUSE’s approach to Btrfs snapshotting and Arch’s snapper integration to provide robust rollback capability.
* We used popular, community-trusted packages for our Wayland environment (Sway, Waybar, etc.) and referenced their docs for configuration syntax.
* The development environment covers all languages requested and more, ensuring that whether the task is compiling kernel modules in C or fine-tuning a neural network in Python, the system is prepared.
* For LLM orchestration, we installed state-of-the-art libraries (LangChain, Transformers) that enable constructing complex AI workflows, aligning the system with current AI agent research and allowing an LLM to effectively interact with the system’s tools.

With this setup, the ThinkPad P16 Gen2 becomes an extremely powerful **Linux workstation**: rolling updates to stay current, **scriptable configs** to automate and version-control every aspect of the environment, **Wayland** for modern display capabilities (high DPI, smooth multi-monitor), and the full breadth of development ecosystems at your fingertips. Whether you’re writing code, deploying cloud infrastructure, experimenting with AI models, or relaxing with a game, this configuration has you covered – and if anything ever goes wrong, a snapshot rollback is just a reboot away. Happy coding (and gaming)!

**Sources:**

* Arch Linux Wiki – Arch is a rolling-release distribution with a user-centric, command-line driven philosophy.
* Arch vs. Gentoo – Both are rolling releases; Gentoo offers source-based customization and official systemd support as an option.
* NixOS Documentation – NixOS allows declarative configuration and atomic rollbacks of the entire system, using systemd as its init by default.
* openSUSE Wiki – Tumbleweed is a tested rolling release and uses Btrfs snapshots by default for easy system rollback (via Snapper).
* LinuxBlog – Notes that Manjaro provides a more stable Arch experience by delaying updates for testing.
* Debian Wiki (Sway page) – Describes Sway as a drop-in replacement for the i3 tiling window manager on Wayland.
* ArchWiki (Wayland compositor list) – Hyprland noted as a dynamic tiling compositor not sacrificing looks; River described as dwm/bspwm-inspired tiler; Qtile as a full-featured tiling WM in Python.
* Wayfire site – Wayfire aims to be customizable and extendable while looking good.
* Snapper Documentation – Snap-pac integrates with pacman to create pre/post Btrfs snapshots automatically on updates, enabling system rollback if needed.
