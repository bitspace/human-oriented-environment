#!/bin/bash
# Phase 1: Core System Hardening Implementation
# For System76 Kudu6 Gentoo Build

set -e

echo "=== Phase 1: Core System Hardening ==="
echo "This script will configure your Gentoo system for bleeding-edge, secure operation"
echo

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   echo "This script should NOT be run as root. Run as regular user with sudo access."
   exit 1
fi

echo "Step 1: Backup current configuration..."
sudo cp /etc/portage/make.conf /etc/portage/make.conf.backup.$(date +%Y%m%d)
echo "✓ Backed up make.conf"

echo
echo "Step 2: Updating Portage configuration..."

# Create portage configuration directories if they don't exist
sudo mkdir -p /etc/portage/package.accept_keywords
sudo mkdir -p /etc/portage/package.use
sudo mkdir -p /etc/portage/package.mask

echo "Step 3: Setting up bleeding-edge keywords..."
sudo tee /etc/portage/package.accept_keywords/bleeding-edge <<EOF
# Core system on testing for latest features
sys-kernel/gentoo-sources ~amd64
media-video/pipewire ~amd64
gui-wm/sway ~amd64

# Development tools on testing (excluding Python due to beta instability)
dev-lang/rust ~amd64
dev-java/openjdk ~amd64
net-libs/nodejs ~amd64

# Python development tools on testing
dev-python/pipx ~amd64
dev-python/userpath ~amd64
dev-python/pypresence ~amd64
dev-python/moddb ~amd64

# Gaming on testing for latest features
games-util/steam-launcher ~amd64
app-emulation/wine-staging ~amd64
games-util/lutris ~amd64
games-util/gamemode ~amd64

# AI/ML libraries
sci-libs/pytorch ~amd64
sci-libs/tensorflow ~amd64
EOF

# Mask unstable Python versions to prevent beta issues
sudo tee /etc/portage/package.mask/python-beta <<EOF
# Mask Python beta/alpha versions to avoid dependency conflicts
>=dev-lang/python-3.14.0_alpha
>=dev-lang/python-3.14.0_beta
>=dev-lang/python-3.15.0_alpha
EOF

echo "✓ Configured bleeding-edge package keywords"

echo
echo "Step 4: Configuring package-specific USE flags..."

# Development USE flags
sudo tee /etc/portage/package.use/development <<EOF
# Development environment optimizations
dev-lang/python sqlite ssl
dev-lang/rust clippy rustfmt
dev-java/openjdk headless-awt
sys-devel/gcc fortran lto pgo
dev-build/cmake ninja
app-editors/neovim lua

# Python development tools
>=dev-python/qtpy-2.4.3 printsupport
EOF

# Gaming USE flags
sudo tee /etc/portage/package.use/gaming <<EOF
# Gaming infrastructure with 32-bit support
games-util/steam-launcher abi_x86_32
app-emulation/wine abi_x86_32 vulkan fontconfig gstreamer mono gecko
app-emulation/wine-staging abi_x86_32 vulkan fontconfig gstreamer mono gecko
media-libs/mesa vulkan abi_x86_32
media-libs/vulkan-loader abi_x86_32
EOF

# 32-bit ABI support for system libraries (required for gaming)
sudo tee /etc/portage/package.use/multilib <<EOF
# Core system libraries with 32-bit ABI support
>=dev-libs/expat-2.7.1 abi_x86_32
>=dev-util/spirv-tools-1.4.313.0 abi_x86_32
>=media-libs/libglvnd-1.7.0 abi_x86_32
>=sys-libs/zlib-1.3.1-r1 abi_x86_32
>=llvm-core/llvm-20.1.7 abi_x86_32
>=dev-libs/wayland-1.23.1 abi_x86_32
>=x11-libs/libdrm-2.4.125 abi_x86_32
>=x11-libs/libX11-1.8.12 abi_x86_32
>=x11-libs/libxshmfence-1.3.3 abi_x86_32
>=x11-libs/libXext-1.3.6 abi_x86_32
>=x11-libs/libXxf86vm-1.1.6 abi_x86_32
>=x11-libs/libxcb-1.17.0 abi_x86_32
>=x11-libs/libXfixes-6.0.1 abi_x86_32
>=x11-libs/xcb-util-keysyms-0.4.1 abi_x86_32
>=app-arch/zstd-1.5.7-r1 abi_x86_32
>=x11-libs/libXrandr-1.5.4 abi_x86_32
>=x11-libs/libXrender-0.9.12 abi_x86_32
>=x11-libs/libXau-1.0.12 abi_x86_32
>=x11-libs/libXdmcp-1.1.5 abi_x86_32
>=x11-libs/libpciaccess-0.18.1 abi_x86_32
>=dev-libs/libffi-3.5.1 abi_x86_32
>=dev-libs/libxml2-2.13.8 abi_x86_32
>=dev-libs/icu-77.1 abi_x86_32

# Additional libraries requiring 32-bit ABI support
>=virtual/libelf-3-r1 abi_x86_32
>=dev-libs/elfutils-0.193 abi_x86_32
>=app-arch/bzip2-1.0.8-r5 abi_x86_32
>=app-arch/xz-utils-5.8.1-r1 abi_x86_32

# Wine/Gaming extensive multilib support
>=x11-libs/libXcursor-1.2.3 abi_x86_32
>=x11-libs/libXi-1.8.2 abi_x86_32
>=x11-libs/libXcomposite-0.4.6 abi_x86_32
>=net-print/cups-2.4.12 abi_x86_32
>=sys-apps/dbus-1.16.2 abi_x86_32
>=media-libs/fontconfig-2.16.2-r1 abi_x86_32
>=media-libs/libsdl2-2.32.6 abi_x86_32
>=net-libs/gnutls-3.8.9-r1 abi_x86_32
>=media-libs/freetype-2.13.3 abi_x86_32
>=media-libs/alsa-lib-1.2.14 abi_x86_32
>=dev-libs/glib-2.84.3 abi_x86_32
>=media-libs/gst-plugins-base-1.24.11-r1 abi_x86_32
>=media-libs/gstreamer-1.24.11 abi_x86_32
>=sys-libs/libunwind-1.8.2 abi_x86_32
>=dev-libs/libusb-1.0.28 abi_x86_32
>=x11-libs/libxkbcommon-1.10.0 abi_x86_32
>=media-plugins/gst-plugins-meta-1.24.11 abi_x86_32
>=media-libs/gst-plugins-good-1.24.11 abi_x86_32
>=media-plugins/gst-plugins-a52dec-1.24.11 abi_x86_32
>=media-plugins/gst-plugins-faad-1.24.11 abi_x86_32
>=media-plugins/gst-plugins-dts-1.24.11 abi_x86_32
>=media-libs/gst-plugins-ugly-1.24.11 abi_x86_32
>=media-plugins/gst-plugins-dvdread-1.24.11 abi_x86_32
>=media-plugins/gst-plugins-mpeg2dec-1.24.11 abi_x86_32
>=media-plugins/gst-plugins-resindvd-1.24.11 abi_x86_32
>=media-plugins/gst-plugins-flac-1.24.11 abi_x86_32
>=media-plugins/gst-plugins-mpg123-1.24.11 abi_x86_32
>=media-plugins/gst-plugins-x264-1.24.11 abi_x86_32
>=media-libs/x264-0.0.20240513 abi_x86_32
>=media-sound/mpg123-base-1.32.10-r2 abi_x86_32
>=media-libs/flac-1.5.0 abi_x86_32
>=media-libs/libogg-1.3.5-r2 abi_x86_32
>=media-libs/libdvdnav-6.1.1 abi_x86_32
>=media-libs/libdvdread-6.1.3 abi_x86_32
>=media-libs/gst-plugins-bad-1.24.11 abi_x86_32
>=dev-lang/orc-0.4.41 abi_x86_32
>=media-libs/libdvdcss-1.4.3 abi_x86_32
>=media-libs/libmpeg2-0.5.1-r3 abi_x86_32
>=media-libs/libdca-0.0.7 abi_x86_32
>=media-libs/faad2-2.11.1 abi_x86_32
>=media-libs/a52dec-0.7.4-r9 abi_x86_32
>=sys-libs/libcap-2.76 abi_x86_32
>=sys-libs/pam-1.7.1 abi_x86_32
>=sys-libs/gdbm-1.25 abi_x86_32
>=sys-libs/readline-8.2_p13-r1 abi_x86_32
>=sys-libs/ncurses-6.5_p20250329 abi_x86_32
>=sys-libs/gpm-1.20.7-r6 abi_x86_32
>=x11-libs/pango-1.56.3 abi_x86_32
>=media-libs/libvorbis-1.3.7-r2 abi_x86_32
>=x11-libs/libXv-1.0.13 abi_x86_32
>=media-libs/graphene-1.10.8-r1 abi_x86_32
>=media-libs/libpng-1.6.47 abi_x86_32
>=media-libs/libjpeg-turbo-3.1.0 abi_x86_32
>=dev-libs/fribidi-1.0.16 abi_x86_32
>=media-libs/harfbuzz-11.2.1 abi_x86_32
>=x11-libs/cairo-1.18.4-r1 abi_x86_32
>=x11-libs/libXft-2.3.9 abi_x86_32
>=x11-libs/pixman-0.46.0 abi_x86_32
>=media-gfx/graphite2-1.3.14_p20210810-r3 abi_x86_32
>=dev-libs/libpcre2-10.45 abi_x86_32
>=sys-apps/util-linux-2.41.1 abi_x86_32
>=dev-libs/libtasn1-4.20.0 abi_x86_32
>=dev-libs/libunistring-1.3 abi_x86_32
>=dev-libs/nettle-3.10.1 abi_x86_32
>=dev-libs/gmp-6.3.0-r1 abi_x86_32
>=net-dns/libidn2-2.3.8 abi_x86_32
>=gui-libs/libdecor-0.2.2-r1 abi_x86_32
>=virtual/libintl-0-r2 abi_x86_32
>=virtual/libiconv-0-r2 abi_x86_32
>=virtual/opengl-8 abi_x86_32
>=virtual/glu-9.0-r2 abi_x86_32
>=virtual/libudev-251-r2 abi_x86_32
>=sys-apps/systemd-257.6 abi_x86_32
>=dev-libs/libgcrypt-1.11.1 abi_x86_32
>=app-arch/lz4-1.10.0-r1 abi_x86_32
>=dev-libs/libgpg-error-1.55 abi_x86_32
>=media-libs/glu-9.0.3 abi_x86_32
>=media-plugins/gst-plugins-cdparanoia-1.24.11 abi_x86_32
>=media-sound/cdparanoia-3.10.2-r8 abi_x86_32

# GTK and desktop libraries with 32-bit support
>=x11-libs/gtk+-3.24.49-r1 abi_x86_32
>=app-accessibility/at-spi2-core-2.54.1-r1 abi_x86_32
>=media-libs/libepoxy-1.5.10-r3 abi_x86_32
>=x11-libs/gdk-pixbuf-2.42.12 abi_x86_32
>=x11-libs/libXdamage-1.1.6 abi_x86_32
>=gnome-base/librsvg-2.58.5-r1 abi_x86_32
>=media-libs/tiff-4.7.0-r1 abi_x86_32
>=x11-libs/libXtst-1.2.5 abi_x86_32
>=dev-lang/rust-bin-1.87.0 abi_x86_32

# Temporary fix for circular dependency
sys-libs/ncurses -gpm
EOF

# Audio USE flags
sudo tee /etc/portage/package.use/audio <<EOF
# Professional audio with PipeWire
media-video/pipewire bluetooth alsa jack pulseaudio
media-sound/ardour jack lv2 vst
media-sound/jack dbus
EOF

# AI/ML USE flags
sudo tee /etc/portage/package.use/ai-ml <<EOF
# AI/ML with GPU acceleration
sci-libs/tensorflow cuda
sci-libs/pytorch cuda
dev-python/numpy lapack
dev-python/scipy lapack
EOF

echo "✓ Configured package-specific USE flags"

echo
echo "Step 5: Syncing Portage tree..."
sudo emerge --sync

echo
echo "Step 6: Installing core security tools..."
sudo emerge --ask --verbose app-admin/sudo net-misc/openssh net-firewall/nftables

echo
echo "Step 7: Basic SSH hardening..."
if [ ! -f /etc/ssh/sshd_config.backup ]; then
    sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup
fi

sudo tee -a /etc/ssh/sshd_config.hardened <<EOF

# Security hardening additions
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
ChallengeResponseAuthentication no
UsePAM yes
X11Forwarding no
PrintMotd no
ClientAliveInterval 300
ClientAliveCountMax 2
EOF

echo "✓ SSH hardening configuration created (review /etc/ssh/sshd_config.hardened)"
echo "  Note: Merge these settings into your sshd_config after setting up SSH keys"

echo
echo "Step 8: Basic firewall setup..."
sudo tee /etc/nftables.conf <<EOF
#!/usr/sbin/nft -f

flush ruleset

table inet filter {
    chain input {
        type filter hook input priority 0; policy drop;
        
        # Allow loopback
        iif lo accept
        
        # Allow established/related connections
        ct state established,related accept
        
        # Allow SSH (adjust port if needed)
        tcp dport 22 ct state new accept
        
        # Allow ping
        icmp type echo-request accept
        icmpv6 type echo-request accept
        
        # Log and drop everything else
        log prefix "nftables-drop: " drop
    }
    
    chain forward {
        type filter hook forward priority 0; policy drop;
    }
    
    chain output {
        type filter hook output priority 0; policy accept;
    }
}
EOF

echo "✓ Basic nftables configuration created"

# Enable nftables service (updated for nftables-1.1.1-r1+)
sudo systemctl enable nftables-load.service
echo "✓ nftables-load.service enabled for startup rule loading"

# Optionally enable nftables-store.service for automatic rule saving at shutdown
echo "Note: To automatically save nftables rules at shutdown, run:"
echo "sudo systemctl enable nftables-store.service"

echo
echo "=== Phase 1 Complete! ==="
echo
echo "Next steps:"
echo "1. Review and customize /etc/portage/make.conf with your optimized settings"
echo "2. Reboot to ensure all services start correctly"
echo "3. Run phase2-development.sh for development environment setup"
echo
echo "Important: Before enabling SSH hardening:"
echo "- Set up SSH key authentication"
echo "- Test SSH access with keys"
echo "- Then merge /etc/ssh/sshd_config.hardened into /etc/ssh/sshd_config"