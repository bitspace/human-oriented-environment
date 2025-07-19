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

# Create package.accept_keywords directory if it doesn't exist
sudo mkdir -p /etc/portage/package.accept_keywords
sudo mkdir -p /etc/portage/package.use

echo "Step 3: Setting up bleeding-edge keywords..."
sudo tee /etc/portage/package.accept_keywords/bleeding-edge <<EOF
# Core system on testing for latest features
sys-kernel/gentoo-sources ~amd64
media-video/pipewire ~amd64
gui-wm/sway ~amd64

# Development tools on testing
dev-lang/python ~amd64
dev-lang/rust ~amd64
dev-java/openjdk ~amd64
net-libs/nodejs ~amd64

# Gaming on testing for latest features
games-util/steam-launcher ~amd64
app-emulation/wine-staging ~amd64
app-emulation/lutris ~amd64

# AI/ML libraries
sci-libs/pytorch ~amd64
sci-libs/tensorflow ~amd64
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
dev-util/cmake ninja
app-editors/neovim lua
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

# Enable nftables service
sudo systemctl enable nftables
echo "✓ nftables service enabled"

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