# Optimized Gentoo Build Plan for System76 Kudu6

## Executive Summary

**Key Decisions Made:**

- **Profile**: systemd desktop profile (already selected) ✓
- **Display Server**: Wayland with XWayland fallback (future-focused, bleeding-edge choice)
- **Desktop Environment**: i3/sway hybrid approach - start with sway for Wayland-native tiling WM
- **Audio**: PipeWire with JACK compatibility layer for professional audio
- **Security**: Hardened kernel configuration with performance-preserving optimizations
- **Package Strategy**: Testing branch (~amd64) for latest packages with selective stable fallbacks

**Rationale**: This configuration maximizes performance for gaming/AI while embracing bleeding-edge technology (Wayland, PipeWire) and maintaining professional audio capabilities. Security hardening focuses on kernel-level protections that don't impact runtime performance.

## Hardware-Specific Configuration

### System76 Kudu6 Specifications

- Intel or AMD CPU (check with `lscpu`)
- NVIDIA/AMD discrete graphics
- High-resolution display
- Professional audio I/O requirements

### Kernel Configuration

**Base**: `sys-kernel/gentoo-sources` with bleeding-edge optimizations

**Critical Security Options** [Suggested by: Gemini, Perplexity]:

```
CONFIG_STRICT_DEVMEM=y
CONFIG_STRICT_KERNEL_RWX=y
CONFIG_HARDENED_USERCOPY=y
CONFIG_SLAB_FREELIST_HARDENED=y
CONFIG_STACKPROTECTOR_STRONG=y
CONFIG_RANDOMIZE_BASE=y (KASLR)
CONFIG_SECURITY_YAMA=y
CONFIG_BPF_SYSCALL=y
```

**Performance Options** [Suggested by: ChatGPT, Gemini]:

```
CONFIG_PREEMPT_VOLUNTARY=y (good compromise for desktop/gaming)
CONFIG_HZ_1000=y (better for audio/gaming responsiveness)
CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS=y
```

**Gaming/Graphics Options**:

```
CONFIG_DRM=y
CONFIG_DRM_AMDGPU=y (or CONFIG_DRM_I915=y for Intel)
CONFIG_FB_EFI=y
```

**Audio Options** [Suggested by: All models]:

```
CONFIG_SND_TIMER=y
CONFIG_SND_PCM=y
CONFIG_SND_HWDEP=y
CONFIG_SND_RAWMIDI=y
CONFIG_SND_SEQUENCER=y
```

### Driver Requirements

- **GPU**: Latest proprietary drivers for NVIDIA (`nvidia-drivers`) or open-source for AMD (`amdgpu`)
- **Audio**: Built-in kernel drivers + PipeWire userspace
- **Network**: iwlwifi for Intel wireless (typical in System76 laptops)

## USE Flags Strategy

### Global USE Flags (`/etc/portage/make.conf`)

```bash
# Bleeding-edge choices with performance focus
USE="systemd wayland pipewire vulkan opengl X \
     abi_x86_32 multilib \
     threads lto pgo \
     alsa jack \
     bluetooth udev dbus \
     ssl zstd \
     python rust java nodejs go \
     cuda rocm \
     git vim-syntax bash-completion"

# Security without performance impact
USE="${USE} pie ssp hardened"

# Exclude unnecessary features
USE="${USE} -pulseaudio -gnome -kde -qt4"
```

### Per-Package USE Flags (`/etc/portage/package.use/`)

**Development Tools**:

```
# /etc/portage/package.use/development
dev-lang/python sqlite ssl
dev-lang/rust clippy rustfmt
dev-java/openjdk headless-awt
sys-devel/gcc fortran
dev-util/cmake ninja
```

**Gaming Infrastructure** [Suggested by: ChatGPT, Gemini]:

```
# /etc/portage/package.use/gaming
games-util/steam-launcher abi_x86_32
app-emulation/wine abi_x86_32 vulkan fontconfig gstreamer mono gecko
media-libs/mesa vulkan abi_x86_32
media-libs/vulkan-loader abi_x86_32
```

**AI/ML Stack** [Suggested by: Gemini, Claude]:

```
# /etc/portage/package.use/ai-ml
sci-libs/tensorflow cuda
sci-libs/pytorch cuda
dev-python/numpy lapack
```

**Audio Production** [Suggested by: All models]:

```
# /etc/portage/package.use/audio
media-video/pipewire bluetooth alsa jack pulseaudio
media-sound/ardour jack lv2 vst
media-sound/jack dbus
```

## Package Categories

### Gaming Infrastructure

**Essential Packages** [Suggested by: ChatGPT, Gemini, Perplexity]:

- `games-util/steam-launcher` - Steam client with Proton
- `app-emulation/wine-staging` - Latest Wine with gaming patches
- `app-emulation/lutris` - Game launcher and manager
- `games-util/gamemode` - Runtime optimization daemon
- `media-libs/dxvk` - DirectX to Vulkan translation
- `media-libs/vkd3d-proton` - Direct3D 12 to Vulkan

**Graphics Optimization**:

- `media-libs/mesa` with `vulkan abi_x86_32` USE flags
- `media-libs/vulkan-loader` with 32-bit support
- Latest GPU drivers (nvidia-drivers or amdgpu)

### Development Environment

**Core Toolchains** [Suggested by: All models]:

- `sys-devel/gcc` with `fortran lto pgo` flags
- `sys-devel/clang` - Alternative compiler
- `dev-lang/python:3.12` - Latest Python
- `dev-lang/rust` - Rust toolchain
- `dev-java/openjdk:21` - Latest LTS Java
- `net-libs/nodejs` - Node.js/JavaScript
- `dev-lang/go` - Go language
- `dev-lang/perl`, `dev-lang/lua` - Scripting languages

**IDEs and Editors** [Suggested by: Claude, ChatGPT]:

- `app-editors/neovim` - Modern Vim
- Post-GUI: VSCode and JetBrains IDEs via overlays

**Build Tools**:

- `dev-util/cmake`, `dev-util/ninja`, `dev-util/meson`
- `dev-vcs/git` with latest features

### AI/ML Stack

**Frameworks** [Suggested by: Gemini, Claude]:

- `sci-libs/pytorch` with CUDA support
- `sci-libs/tensorflow` with CUDA support
- Python packages via pip in virtual environments:
  - `torch`, `transformers`, `huggingface-hub`
  - `openai`, `google-generativeai`

**Development Tools**:

- `dev-python/jupyterlab` - Interactive development
- `dev-python/numpy`, `dev-python/scipy` with optimized BLAS

### Cloud Development

**CLI Tools** [Suggested by: All models]:

- `app-admin/awscli` - AWS CLI
- `app-admin/google-cloud-sdk` - GCP SDK
- `net-misc/azure-cli` - Azure CLI
- `app-containers/docker` - Container platform
- `app-containers/podman` - Rootless containers
- `sys-cluster/kubectl` - Kubernetes CLI

### Security Hardening

**Network Security** [Suggested by: Perplexity, Gemini]:

- `net-firewall/nftables` - Modern firewall
- `net-analyzer/fail2ban` - Intrusion prevention
- `net-misc/openssh` with hardened config

**System Security**:

- `app-admin/sudo` with restricted configuration
- `sys-apps/audit` - System call auditing
- `app-admin/logcheck` - Log monitoring

**Monitoring Tools** [Suggested by: ChatGPT, Claude]:

- `sys-process/htop` - Process monitoring
- `app-admin/sysstat` - System statistics
- `sys-apps/lm-sensors` - Hardware monitoring

## Build Order and Dependencies

### Phase 1: Core System Hardening

1. **Update kernel configuration** with security and performance options
2. **Configure make.conf** with bleeding-edge flags
3. **Set up package.accept_keywords** for testing packages
4. **Install core security tools**: sudo, openssh, nftables

### Phase 2: Development Foundation

1. **Install core toolchains**: gcc, clang, python, rust, java, nodejs
2. **Set up overlays** for bleeding-edge packages
3. **Configure git and development environment**

### Phase 3: Specialized Workloads

1. **Gaming setup**: Steam, Wine, GPU drivers with Vulkan
2. **Audio system**: PipeWire, JACK, professional audio tools
3. **AI/ML stack**: CUDA drivers, Python ML libraries
4. **Cloud tools**: CLI tools and container platforms

### Phase 4: Desktop Environment

1. **Wayland compositor**: sway window manager
2. **Essential GUI applications**
3. **IDE installation and configuration**

## Wayland vs X11 Decision

**Recommendation: Wayland with sway** [Suggested by: Gemini]

**Rationale**:

- **Future-focused**: Aligns with bleeding-edge preference
- **Security**: Better isolation and modern security model
- **Performance**: Eliminates X11 overhead, better for gaming
- **Compatibility**: XWayland provides fallback for legacy applications

**Implementation Strategy**:

1. Start with `gui-wm/sway` (Wayland-native tiling WM)
2. Install `gui-apps/waybar` for status bar
3. Configure XWayland for compatibility
4. Gaming: Steam and most games work well with XWayland

## Security vs Performance Trade-offs

**Adopted Security Measures**:

- Kernel hardening options that don't impact runtime performance
- Network firewall with optimized rules
- SSH key-only authentication
- System call auditing

**Avoided Security Measures** (performance impact):

- SELinux/AppArmor (complexity overhead for single-user system)
- Grsecurity patches (can impact gaming performance)
- Excessive process isolation (impacts development workflow)

## Bleeding-Edge Package Strategy

### Testing Branch Configuration

```bash
# /etc/portage/package.accept_keywords
# Global testing for core system
sys-kernel/gentoo-sources ~amd64
media-video/pipewire ~amd64
gui-wm/sway ~amd64

# Development tools on testing
dev-lang/python ~amd64
dev-lang/rust ~amd64
dev-java/openjdk ~amd64

# Gaming on testing for latest features
games-util/steam-launcher ~amd64
app-emulation/wine-staging ~amd64
```

### Update Strategy

1. **Daily sync**: `emerge --sync`
2. **Weekly updates**: `emerge -avuDN @world`
3. **Monitor**: Keep watch on Gentoo forums for breaking changes
4. **Backup**: Regular system snapshots before major updates

## Maintenance Strategy

### Automated Tasks

- **Daily**: Sync Portage tree
- **Weekly**: World updates with careful review
- **Monthly**: Kernel updates and security audits

### Performance Monitoring

- **Gaming**: Track FPS and frame timing
- **Audio**: Monitor JACK/PipeWire latency
- **Development**: Build time optimization with ccache
- **AI/ML**: GPU utilization and memory usage

### Backup Strategy

- **System**: Regular filesystem snapshots
- **Configuration**: Git repository for /etc/portage
- **Development**: Cloud-based repositories

This plan synthesizes the best recommendations from all models while prioritizing your bleeding-edge preferences, gaming performance, and professional development needs. The security hardening focuses on measures that don't compromise performance, making it ideal for your multi-faceted workflow.
