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

# Gaming on testing for latest features
games-util/steam-launcher ~amd64
app-emulation/wine-staging ~amd64
app-emulation/lutris ~amd64

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