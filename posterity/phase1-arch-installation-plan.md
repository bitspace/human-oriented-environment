# Phase 1: Arch Linux Base System Installation Plan

## Pre-Installation Analysis

Based on the current partition layout in `target-system-specifications.md`:
```
Device              Start        End    Sectors  Size Type
/dev/nvme0n1p1       2048    2097151    2095104 1023M EFI System
/dev/nvme0n1p2    2097152 7867355823 7865258672  3.7T Linux filesystem  
/dev/nvme0n1p3 7867355824 8001573518  134217695   64G Linux swap
```

**Important**: The existing partition layout is already perfectly aligned and configured. The EFI partition (1023M), main filesystem (3.7T), and swap (64G) are exactly what we need.

## Step-by-Step Installation Instructions

### 1. Boot from Arch Linux ISO
- Boot from USB/DVD with Arch Linux installation medium
- Select "Arch Linux install medium" from boot menu
- Wait for boot to complete to live environment

### 2. Verify Boot Mode and Network
```bash
# Verify UEFI mode (should show "64")
cat /sys/firmware/efi/fw_platform_size

# Check network connectivity
ping -c 3 archlinux.org

# If WiFi needed, connect:
iwctl
[iwd]# station wlan0 connect "SSID"
```

### 3. Update System Clock
```bash
timedatectl set-ntp true
timedatectl status
```

### 4. Verify Current Partition Layout
```bash
# Confirm the existing partitions are correct
fdisk -l /dev/nvme0n1

# Expected output should match:
# /dev/nvme0n1p1  1023M  EFI System
# /dev/nvme0n1p2  3.7T   Linux filesystem
# /dev/nvme0n1p3  64G    Linux swap
```

### 5. Format Filesystems
```bash
# Format EFI partition (FAT32)
mkfs.fat -F 32 /dev/nvme0n1p1

# Format root partition (XFS with optimizations)
mkfs.xfs -f -L "arch-root" /dev/nvme0n1p2

# Format swap partition
mkswap -L "arch-swap" /dev/nvme0n1p3
```

### 6. Mount Filesystems
```bash
# Mount root partition
mount /dev/nvme0n1p2 /mnt

# Create and mount EFI directory
mount --mkdir /dev/nvme0n1p1 /mnt/boot

# Enable swap
swapon /dev/nvme0n1p3

# Verify mounts
lsblk
```

### 7. Select Mirror Servers (Optional Optimization)
```bash
# Edit mirrorlist for faster downloads (optional)
nano /etc/pacman.d/mirrorlist
# Or use reflector to auto-select fastest mirrors:
# reflector --country US --age 6 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
```

### 8. Install Base System
```bash
# Install base system with essential packages
pacstrap -K /mnt base linux linux-firmware

# Install additional essential packages
pacstrap /mnt \
    base-devel \
    intel-ucode \
    sof-firmware \
    alsa-ucm-conf \
    xfsprogs \
    networkmanager \
    neovim \
    git \
    sudo \
    links \
    gpm \
    tmux \
    openssh \
    gnupg
```

### 9. Generate Filesystem Table
```bash
# Generate fstab using UUIDs
genfstab -U /mnt >> /mnt/etc/fstab

# Verify fstab contents
cat /mnt/etc/fstab
```

### 10. Chroot into New System
```bash
# Enter the new system
arch-chroot /mnt
```

### 11. Configure System (Inside chroot)
```bash
# Set timezone (adjust as needed)
ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime
hwclock --systohc

# Configure locale
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Set hostname (replace 'thinkpad' with desired name)
echo "thinkpad" > /etc/hostname

# Configure hosts file
cat >> /etc/hosts << EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   thinkpad.localdomain thinkpad
EOF
```

### 12. Configure Network and Users
```bash
# Enable NetworkManager, GPM, and SSH
systemctl enable NetworkManager
systemctl enable gpm
systemctl enable sshd

# Set root password
passwd

# Create user account (replace 'username' with your username)
useradd -m -G wheel -s /bin/bash username
passwd username

# Configure sudo access
EDITOR=nvim visudo
# Uncomment: %wheel ALL=(ALL:ALL) ALL
```

### 13. Install and Configure Bootloader (systemd-boot)
```bash
# Install systemd-boot
bootctl install

# Configure loader
cat > /boot/loader/loader.conf << EOF
default  arch.conf
timeout  3
console-mode max
editor   no
EOF

# Create boot entry
cat > /boot/loader/entries/arch.conf << EOF
title   Arch Linux
linux   /vmlinuz-linux
initrd  /intel-ucode.img
initrd  /initramfs-linux.img
options root=PARTUUID=$(blkid -s PARTUUID -o value /dev/nvme0n1p2) rw
EOF
```

### 14. Configure Intel Graphics and Microcode
```bash
# Install Intel graphics drivers
pacman -S mesa vulkan-intel intel-media-driver

# Verify microcode is loaded (intel-ucode already installed)
# This will be verified after reboot
```

### 15. Enable Multilib Repository (for 32-bit gaming support)
```bash
# Edit pacman.conf to enable multilib
sed -i '/\[multilib\]/,/Include.*multilib/ s/^#//' /etc/pacman.conf

# Update package database
pacman -Sy
```

### 16. Final Steps and Reboot
```bash
# Exit chroot
exit

# Unmount filesystems
umount -R /mnt

# Reboot into new system
reboot
```

## Post-Reboot Verification Checklist

After rebooting into the new Arch system:

```bash
# 1. Verify boot and login
# Should boot to TTY login prompt

# 2. Start console mouse support and SSH
sudo systemctl start gpm
sudo systemctl start sshd

# 3. Connect to network
sudo systemctl start NetworkManager
# For WiFi: nmcli device wifi connect "SSID" password "password"

# 4. Verify partition mounts
lsblk
df -h

# 5. Verify swap
swapon --show

# 6. Check filesystem type (should show XFS)
findmnt -D /

# 7. Update system
sudo pacman -Syu

# 8. Verify Intel microcode
dmesg | grep microcode

# 9. Test internet connectivity
ping -c 3 google.com

# 10. Get IP address for SSH access
ip addr show
# Note the IP address for SSH connection

# 11. Test terminal browser (for Claude Code authentication)
links https://www.google.com
# Use arrow keys to navigate, Enter to follow links
# Press 'q' to quit
```

## SSH Authentication Setup

Now you can SSH from your working computer to complete Claude Code authentication:

```bash
# From your working computer, SSH to the Arch system
ssh username@arch-laptop-ip

# You now have full terminal capabilities with copy/paste
# Continue with Phase 2 installation via SSH session
```

## Claude Code Authentication Workflow (via SSH)

When you first run Claude Code and need to authenticate:

```bash
# 1. From your working computer, SSH to the Arch system
ssh username@arch-laptop-ip

# 2. Run Claude Code (will display authentication URL)
claude

# 3. Copy the authentication URL from your SSH terminal
# 4. Open the URL in a browser on your working computer
# 5. Complete the authentication process
# 6. Return to the SSH session and continue

# Claude Code is now authenticated and ready to use
```

**Benefits of SSH approach:**
- Full copy/paste functionality from your working computer
- Normal browser authentication on your working system
- Continue all remaining installation phases via SSH
- No manual URL transcription required

## Key Technical Notes

**Partition Alignment**: The existing partitions are already optimally aligned:
- EFI partition starts at sector 2048 (1MB boundary)
- Root partition starts at sector 2097152 (perfect 1MB alignment)
- Swap partition starts at sector 7867355824 (aligned to previous partition end)

**XFS Optimization**: Using XFS with these mount options in `/etc/fstab`:
```
/dev/nvme0n1p2 / xfs defaults,noatime,inode64 0 1
```

**Memory Considerations**: With 192GB RAM, the system can handle large AI models in memory without heavy swap usage, but the 64GB swap provides hibernation capability.

## Estimated Timeline
- **Preparation and partitioning**: 15 minutes
- **Base system installation**: 10 minutes (depending on internet speed)
- **Configuration**: 15 minutes
- **Total Phase 1 time**: ~40 minutes

## Ready for Phase 2
After successful completion, the system will be ready for immediate AI agent integration and the remaining automated setup phases. The traditional manual installation provides the clean, predictable base that the LLM consensus analysis identified as optimal for AI agent control.