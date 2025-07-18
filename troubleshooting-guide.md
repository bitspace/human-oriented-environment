# Troubleshooting Guide for Gentoo Kudu6 Build

## Common Issues and Solutions

### Phase 1 Issues

#### make.conf Configuration

**Problem**: Compilation failures with aggressive optimization flags
```
Solution: Start with conservative flags and gradually optimize
- Change CFLAGS from "-O3" to "-O2"
- Remove LTO flags temporarily if builds fail
- Use "-march=native" only after confirming CPU detection
```

**Problem**: Parallel build failures
```
Solution: Reduce MAKEOPTS value
- Start with "-j4" regardless of CPU cores
- Increase gradually after stable builds
- Monitor memory usage during compilation
```

#### Package Dependencies

**Problem**: Circular dependencies when updating @world
```bash
# Solution: Break circular deps
emerge --ask --oneshot <conflicting-package>
emerge --ask --update --deep --newuse @world
```

**Problem**: USE flag conflicts
```bash
# Check USE flag conflicts
emerge --ask --pretend --verbose <package>

# Resolve in package.use
echo "category/package -conflicting-flag" >> /etc/portage/package.use/fixes
```

### Phase 2 Issues

#### Python Environment

**Problem**: Python module import errors
```bash
# Solution: Rebuild Python packages
emerge --ask --oneshot dev-lang/python:3.12
emerge --ask @preserved-rebuild

# Rebuild Python modules
python-updater
```

**Problem**: pip install failures in virtual environments
```bash
# Solution: Ensure development headers
emerge --ask sys-devel/gcc dev-util/pkgconf

# Recreate virtual environment
rm -rf ~/.venv/problematic-env
python3.12 -m venv ~/.venv/problematic-env
```

#### Git Configuration

**Problem**: SSL certificate errors
```bash
# Solution: Update certificates
emerge --ask app-misc/ca-certificates
update-ca-certificates
```

#### Node.js Issues

**Problem**: npm permission errors
```bash
# Solution: Fix npm global directory
mkdir ~/.npm-global
npm config set prefix '~/.npm-global'
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc
```

### Phase 3 Issues

#### Gaming Problems

**Problem**: Steam fails to start
```bash
# Solution: Check 32-bit libraries
emerge --ask --oneshot games-util/steam-launcher
ldconfig

# Verify multilib
grep -i abi_x86 /etc/portage/make.conf
```

**Problem**: Vulkan not detected
```bash
# Solution: Install and test Vulkan
emerge --ask media-libs/vulkan-loader media-libs/vulkan-tools
vulkaninfo

# For NVIDIA
emerge --ask x11-drivers/nvidia-drivers
nvidia-smi
```

**Problem**: Wine applications crash
```bash
# Solution: Install Wine dependencies
emerge --ask app-emulation/winetricks
winetricks corefonts vcrun2019

# Set Wine Windows version
winecfg
```

#### Audio Issues

**Problem**: No audio output
```bash
# Solution: Check PipeWire status
systemctl --user status pipewire
systemctl --user restart pipewire

# Check audio devices
pactl list sinks
```

**Problem**: High audio latency for music production
```bash
# Solution: Configure real-time kernel and privileges
# Add to /etc/security/limits.d/audio.conf:
@audio - rtprio 95
@audio - memlock unlimited

# Reboot and test
ulimit -r
```

**Problem**: JACK conflicts with PipeWire
```bash
# Solution: Use PipeWire's JACK compatibility
systemctl --user stop jack
systemctl --user disable jack
systemctl --user enable --now pipewire-jack
```

#### AI/ML Issues

**Problem**: CUDA not detected
```bash
# Solution: Verify NVIDIA drivers and CUDA
nvidia-smi
nvcc --version

# Test PyTorch CUDA
python -c "import torch; print(torch.cuda.is_available())"
```

**Problem**: Out of memory during model training
```bash
# Solution: Monitor GPU memory
nvidia-smi

# Reduce batch size in training scripts
# Use gradient accumulation for effective large batches
```

**Problem**: TensorFlow installation failures
```bash
# Solution: Use virtual environment with specific versions
source ~/.venv/ai-ml/bin/activate
pip install --upgrade pip setuptools wheel
pip install tensorflow==2.15.0  # Use specific version
```

#### Cloud Development Issues

**Problem**: Docker permission denied
```bash
# Solution: Add user to docker group and restart
sudo usermod -a -G docker $USER
# Logout and login again, or:
newgrp docker
```

**Problem**: Docker build failures
```bash
# Solution: Check disk space and clean up
df -h
docker system prune -a

# Increase Docker build memory
# Edit /etc/docker/daemon.json:
{
  "default-ulimits": {
    "memlock": {
      "Hard": -1,
      "Name": "memlock",
      "Soft": -1
    }
  }
}
```

### Kernel Issues

#### Boot Problems

**Problem**: Kernel panic on boot
```
Solution: Boot with older kernel and check config
1. Select older kernel in GRUB
2. Check dmesg for error details
3. Rebuild kernel with working config
4. Gradually add new features
```

**Problem**: Graphics not working after kernel update
```bash
# Solution: Rebuild graphics drivers
emerge --ask @module-rebuild

# For NVIDIA
emerge --ask x11-drivers/nvidia-drivers

# Update initramfs
dracut --force
```

#### Hardware Detection

**Problem**: Wireless not working
```bash
# Solution: Check firmware and drivers
lspci | grep -i network
dmesg | grep firmware

# Install firmware
emerge --ask sys-kernel/linux-firmware

# Load module manually
modprobe iwlwifi  # or appropriate driver
```

### System Maintenance Issues

#### Update Problems

**Problem**: emerge @world fails with conflicts
```bash
# Solution: Update in stages
emerge --ask --oneshot portage
emerge --ask --update --deep sys-devel/gcc
emerge --ask --update --deep @system
emerge --ask --update --deep @world
```

**Problem**: Config file conflicts
```bash
# Solution: Use dispatch-conf safely
dispatch-conf
# Review each change carefully
# Keep your customizations
```

#### Performance Issues

**Problem**: Slow compilation times
```bash
# Solution: Optimize build settings
# Enable ccache
emerge --ask dev-util/ccache
echo 'FEATURES="ccache"' >> /etc/portage/make.conf

# Use tmpfs for compilation
echo 'PORTAGE_TMPDIR="/tmp"' >> /etc/portage/make.conf
# Add to /etc/fstab:
tmpfs /tmp tmpfs defaults,noatime,mode=1777 0 0
```

**Problem**: System responsiveness during compilation
```bash
# Solution: Limit resource usage
# Reduce MAKEOPTS during large builds
MAKEOPTS="-j2" emerge --ask large-package

# Use ionice for emerge
echo 'PORTAGE_IONICE_COMMAND="ionice -c 3 -p \${PID}"' >> /etc/portage/make.conf
```

### Security Issues

#### SSH Access

**Problem**: Locked out after SSH hardening
```bash
# Solution: Use local console access
# Reset SSH config to defaults
sudo cp /etc/ssh/sshd_config.backup /etc/ssh/sshd_config
sudo systemctl restart sshd

# Test SSH access before applying hardening
```

#### Firewall Issues

**Problem**: Network services blocked by nftables
```bash
# Solution: Adjust firewall rules
sudo nft list ruleset
sudo nft add rule inet filter input tcp dport <port> accept
sudo nft list ruleset > /etc/nftables.conf
```

### Emergency Recovery

#### System Won't Boot

1. **Boot from Gentoo install media**
2. **Mount and chroot into system**
```bash
mount /dev/sdXY /mnt/gentoo
mount /dev/sdXZ /mnt/gentoo/boot
mount -t proc proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
chroot /mnt/gentoo /bin/bash
source /etc/profile
```

3. **Fix the issue**
```bash
# Rebuild kernel
cd /usr/src/linux
make && make modules_install && make install

# Update bootloader
grub-mkconfig -o /boot/grub/grub.cfg

# Fix broken packages
emerge --ask --oneshot problematic-package
```

#### Broken System

**Last resort**: Reinstall affected packages
```bash
# Rebuild entire system (NUCLEAR option)
emerge --ask --emptytree @world

# Less nuclear: rebuild system packages only
emerge --ask --emptytree @system
```

## Getting Help

### Gentoo Resources
- **Gentoo Wiki**: https://wiki.gentoo.org/
- **Gentoo Forums**: https://forums.gentoo.org/
- **Gentoo Handbook**: https://wiki.gentoo.org/wiki/Handbook:AMD64
- **#gentoo on libera.chat**: IRC support

### Useful Commands for Debugging

```bash
# Check package information
equery uses package-name
equery depends package-name
equery files package-name

# Check system integrity
emerge --ask --depclean --pretend
revdep-rebuild --pretend

# Monitor builds
tail -f /var/log/portage/elog/summary.log

# Check for news
eselect news list
eselect news read

# System information
emerge --info
lspci -v
lsusb -v
dmesg | tail -20
```

Remember: Gentoo's strength is its flexibility, but this requires patience and understanding. When in doubt, consult the official documentation and community resources!