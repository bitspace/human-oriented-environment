# Gemini 2.5 Pro (Custom System Prompt) Response via Google Workspace Enterprise Gemini Web UI

Alright, it's good to see someone diving back into Gentoo. Things have certainly evolved in 20 years, but the core principles of control and flexibility remain the same. Since you've got the base system and `systemd` running, we can get straight to tuning Portage and layering in the necessary tools for your workflow.

Here is a task list to get your system configured, secured, and ready for your development, gaming, and audio work before you even think about emerging a desktop environment.

-----

### 1\. Configure Portage for the Testing Branch

First, let's get your system aligned with the testing branch. You'll set this globally in your main configuration file.

  * **Edit `make.conf`**:
    Open `/etc/portage/make.conf` with your preferred editor (e.g., `nano` or `vim`).

  * **Set `ACCEPT_KEYWORDS`**:
    This is the critical step for using the testing branch. Add this line:

    ```ini
    # Accept the amd64 testing branch for all packages
    ACCEPT_KEYWORDS="~amd64"
    ```

    This tells Portage to prefer testing versions (`~amd64`) over stable (`amd64`) for every package. Be prepared for occasional breakage; it's the nature of the beast, but it's usually manageable.

  * **Set Compile Flags and `MAKEOPTS`**:
    While you're in `make.conf`, ensure these are set for optimal performance. `-march=native` will have GCC detect your CPU and optimize for it.

    ```ini
    # Recommended compiler flags
    COMMON_FLAGS="-march=native -O2 -pipe"

    # Set based on your CPU core/thread count
    # Rule of thumb is number of threads + 1
    MAKEOPTS="-j$(nproc)"
    ```

  * **Set Global `USE` Flags**:
    This is where you make broad decisions about your system's capabilities. Based on your needs, a good starting point would be:

    ```ini
    # Global USE flags
    USE="systemd vulkan steam-overlay pipewire X wayland qt5 gtk -pulseaudio"
    ```

      - **`systemd`**: You've already committed to this with your profile choice.
      - **`vulkan`**: Essential for modern gaming via Proton.
      - **`steam-overlay`**: Required for the Steam overlay to function correctly.
      - **`pipewire`**: The modern audio-video server. It handles professional audio and desktop audio well, superseding both JACK and PulseAudio.
      - **`-pulseaudio`**: We explicitly disable the older sound server in favor of PipeWire.
      - **`X wayland`**: Emerge support for both display servers. This gives you flexibility later.
      - **`qt5 gtk`**: Emerge support for the two main graphical toolkits.

  * **Define Video and Input Drivers**:
    Still in `make.conf`, tell Portage which drivers to build. Replace `amdgpu` with `nvidia` or `intel` as appropriate for your hardware.

    ```ini
    # Video and Input drivers
    VIDEO_CARDS="amdgpu"
    INPUT_DEVICES="libinput"
    ```

After saving your changes, run a full world update to align your installed packages with these new settings.

```bash
emerge --ask --update --deep --newuse @world
```

Portage will likely want to rebuild a significant portion of your system. This is expected.

-----

### 2\. Install Essential System and Management Tools

Before we get to the big applications, let's install some core utilities that make managing a Gentoo system easier.

  * **Portage Utilities**:
    `gentoolkit` provides indispensable tools like `equery`. `eix` is a superior search tool for the Portage tree.

    ```bash
    emerge --ask app-portage/gentoolkit app-portage/eix
    ```

    After installing `eix`, run `eix-update` to build its initial cache.

  * **User and Permission Management**:
    You'll need a way to perform administrative tasks without logging in as root. `sudo` is the standard; `doas` is a simpler alternative if you prefer it.

    ```bash
    emerge --ask app-admin/sudo
    ```

    After installation, run `visudo` and add your user account to the `wheel` group with passwordless or password-prompting privileges, as you prefer.

    ```
    # Example: Allow members of group wheel to execute any command
    %wheel ALL=(ALL:ALL) ALL
    ```

  * **Networking and Firewall**:
    `nftables` is the modern kernel packet filtering framework, replacing `iptables`.

    ```bash
    emerge --ask net-firewall/nftables
    ```

    Enable and start the service:

    ```bash
    systemctl enable nftables.service
    systemctl start nftables.service
    ```

    You'll need to create a ruleset in `/etc/nftables.conf`. Start with a simple "deny all incoming, allow all outgoing" configuration for your laptop.

-----

### 3\. Set Up the Development Environment

This will cover your broad needs for software and cloud development.

  * **Core Tools**: `git` is non-negotiable.

    ```bash
    emerge --ask dev-vcs/git dev-util/github-cli
    ```

  * **Programming Languages**: Emerge the primary tools. Other versions can be managed with slotting or language-specific version managers.

    ```bash
    # For Python (pip and venv are included)
    emerge --ask dev-lang/python:3.12

    # For Rust (provides rustc and cargo)
    emerge --ask dev-lang/rust

    # For Java (openjdk-bin is usually fastest)
    emerge --ask dev-java/openjdk-bin:21

    # For Node.js
    emerge --ask net-libs/nodejs
    ```

    For C/C++, your `sys-devel/gcc` toolchain is already installed. You may want `dev-util/cmake` and `dev-lang/clang` as well.

  * **Cloud and Containers**:
    `docker` is essential. You'll also want the Google Cloud SDK.

    ```bash
    emerge --ask app-emulation/docker dev-util/gcloud-sdk
    ```

    Add your user to the `docker` group to manage it without `sudo`.

    ```bash
    gpasswd -a ${USER} docker
    systemctl enable docker.service
    ```

    You will need to log out and back in for the group change to take effect.

-----

### 4\. Prepare for Gaming and Multimedia

This involves WINE, Steam, and the necessary audio infrastructure.

  * **WINE and Steam**:
    I recommend `wine-staging` for a good balance of new features. `steam-launcher` will pull in all necessary dependencies.

    ```bash
    emerge --ask app-emulation/wine-staging app-emulation/steam-launcher games-util/gamemode
    ```

    `gamemode` helps optimize system performance when a game is running.

  * **Pro Audio**:
    PipeWire, which we set as a global `USE` flag, is the key. You should install some control utilities. For your Native Instruments hardware, `alsa-utils` will be helpful for initial device detection.

    ```bash
    emerge --ask media-sound/alsa-utils media-video/pipewire media-sound/qjackctl
    ```

    `qjackctl` can be used to manage the PipeWire graph, much like it was used for JACK. For low-latency audio, you will eventually want to emerge a kernel with the `realtime` patches and configure system limits, but we can defer that until after the GUI is running.

-----

### 5\. Final Pre-GUI Steps

  * **Kernel Firmware**:
    You have a kernel, but modern hardware relies heavily on firmware blobs for Wi-Fi, graphics, and more. It's crucial to have these available.

    ```bash
    emerge --ask sys-kernel/linux-firmware
    ```

  * **Review and Rebuild**:
    Run one final check to ensure your system is consistent.

    ```bash
    emerge --ask --update --deep --newuse @world
    emerge --ask @preserved-rebuild
    emerge --depclean
    ```

You now have a solid, command-line-only system configured for your specific needs. It's fully on the testing branch, secured with a basic firewall, and has the foundational packages for all your major tasks. The next logical step would be configuring your kernel if needed, and then emerging Xorg or a Wayland compositor, a display manager, and your preferred desktop environment or window manager.