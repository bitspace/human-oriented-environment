# Kernel Configuration Guide for System76 Kudu6

This guide provides the kernel configuration options for optimal security, performance, and hardware support on your System76 Kudu6.

## Prerequisites

```bash
# Install kernel sources
sudo emerge --ask sys-kernel/gentoo-sources

# Set the active kernel
sudo eselect kernel list
sudo eselect kernel set 1  # or appropriate number

# Change to kernel directory
cd /usr/src/linux
```

## Security Hardening Options

Enable these options in `make menuconfig` for enhanced security without performance impact:

### Processor Type and Features
```
[*] Randomize the address of the kernel image (KASLR)
    Processor family (Generic-x86-64) --->
[*] Machine Check Exception
[*] Intel MCE features
[*] AMD MCE features
```

### Security Options
```
[*] Enable different security models
[*] Socket and Networking Security Hooks
[*] NSA SELinux Support (optional)
[*] Simplified Mandatory Access Control
[*] YAMA support
    Default security module (AppArmor) --->
```

### Kernel Hardening Options
```
[*] Hardened usercopy
[*] Harden slab freelist
[*] Enable heap randomization
[*] GCC plugin infrastructure
[*] Randomize layout of sensitive kernel structures
```

### Memory Protection
```
[*] Strict kernel RWX feature
[*] Strict module RWX feature
[*] Restrict /dev/mem access
[*] Restrict /dev/kmem access
```

## Performance Optimization Options

### Preemption Model
For desktop/gaming use with good responsiveness:
```
Preemption Model (Voluntary Kernel Preemption (Desktop)) --->
```

For professional audio (lower latency):
```
Preemption Model (Fully Preemptible Kernel (Real-Time)) --->
```

### Timer Frequency
```
Timer frequency (1000 HZ) --->
```
Higher frequency improves responsiveness for gaming and audio.

### CPU Features
```
[*] Symmetric multi-processing support
[*] Support x2apic
[*] Machine check support
[*] Intel microcode loading support
[*] AMD microcode loading support
```

## Gaming and Graphics

### Graphics Support
```
Device Drivers --->
  Graphics support --->
    [*] /dev/agpgart (AGP Support)
    [*] Direct Rendering Manager (XFree86 4.1.0 and higher DRI support)
    [*] Enable legacy fbdev support for your modesetting driver
    
    # For NVIDIA (if using proprietary drivers)
    < > Nouveau (NVIDIA) cards
    
    # For AMD
    [*] AMD GPU
    [*] Enable amdgpu support for SI parts
    [*] Enable amdgpu support for CIK parts
    [*] Enable AMD powerplay component
    
    # For Intel
    [*] Intel I810
    [*] Intel 8xx/9xx/G3x/G4x/HD Graphics
```

### DRM and KMS
```
[*] Enable modesetting on radeon by default
[*] Enable modesetting on amdgpu by default
```

## Audio Configuration

### Sound Card Support
```
Device Drivers --->
  Sound card support --->
    [*] Sound card support
    [*] Advanced Linux Sound Architecture --->
      [*] PCI sound devices --->
        [*] Intel HD Audio --->
          [*] Build hwdep interface for HD-audio driver
          [*] Build PCM interface for HD-audio driver
          [*] HD Audio input beep support
          [*] Support digital beep via input layer
          [*] HD-audio codec support
          [*] Build Realtek HD-audio codec support
          [*] Build Analog Devices HD-audio codec support
          [*] Build IDT/Sigmaltel HD-audio codec support
          [*] Build VIA HD-audio codec support
          [*] Build HDMI/DisplayPort HD-audio codec support
      [*] USB sound devices --->
        [*] USB Audio/MIDI driver
        [*] USB Mixer/Sound card support
```

### MIDI Support
```
[*] Sequencer support
[*] MIDI interface support
```

## Container and Virtualization Support

### Namespaces
```
General setup --->
  [*] Namespaces support --->
    [*] UTS namespace
    [*] IPC namespace
    [*] User namespace
    [*] PID Namespaces
    [*] Network namespace
```

### Control Groups
```
General setup --->
  [*] Control Group support --->
    [*] Memory controller
    [*] Swap controller
    [*] IO controller
    [*] CPU controller
    [*] PIDs controller
    [*] RDMA controller
    [*] Freezer controller
    [*] HugeTLB controller
    [*] CPU set controller
    [*] Device controller
```

### Container Features
```
[*] Enable seccomp to safely compute untrusted bytecode
[*] Enable BPF SYSCALL
File systems --->
  [*] Overlay filesystem support
  [*] Tmpfs virtual memory filesystem support
```

## Networking for Development

### Network Options
```
Networking support --->
  Networking options --->
    [*] Network packet filtering framework (Netfilter) --->
      [*] Advanced netfilter configuration
      Core Netfilter Configuration --->
        [*] Netfilter connection tracking support
        [*] Netfilter Xtables support
        [*] "state" match support
        [*] "conntrack" connection match support
    [*] Network security hooks
    [*] IP: advanced router
    [*] IP: policy routing
```

### Container Networking
```
[*] 802.1Q/802.1ad VLAN Support
[*] Network interface bonding support
[*] Virtual ethernet pair device
[*] MAC-VLAN support
[*] IP-VLAN support
[*] Virtual ethernet tunnel
```

## System76 Kudu6 Specific Hardware

### Input Devices
```
Device Drivers --->
  Input device support --->
    [*] Keyboards --->
      [*] AT keyboard
    [*] Mice --->
      [*] PS/2 mouse
    [*] Touchpads --->
      [*] Synaptics I2C touchpad support
      [*] Elan I2C touchpad support
```

### Power Management
```
Power management and ACPI options --->
  [*] ACPI (Advanced Configuration and Power Interface) Support --->
    [*] Battery
    [*] AC Adapter
    [*] Thermal Zone
    [*] Power Button
    [*] Video
    [*] Fan
    [*] Processor
    [*] Intel Dynamic Platform and Thermal Framework
  [*] CPU Frequency scaling --->
    [*] CPU frequency scaling
    Default CPUFreq governor (schedutil) --->
    [*] 'performance' governor
    [*] 'powersave' governor
    [*] 'schedutil' cpufreq governor
    x86 CPU frequency scaling drivers --->
      [*] Intel P state control
      [*] ACPI Processor P-States driver
```

## Building and Installing

```bash
# Configure kernel
make menuconfig

# Build kernel (adjust -j to your CPU core count)
make -j8

# Install modules
sudo make modules_install

# Install kernel
sudo make install

# Update bootloader (if using GRUB)
sudo grub-mkconfig -o /boot/grub/grub.cfg

# Update initramfs (if using dracut)
sudo dracut --force
```

## Verification

After reboot, verify security features:

```bash
# Check KASLR
dmesg | grep -i kaslr

# Check hardening features
cat /proc/sys/kernel/kptr_restrict
cat /proc/sys/kernel/dmesg_restrict

# Check namespaces
ls /proc/self/ns/

# Test audio
aplay /usr/share/sounds/alsa/Front_Left.wav

# Test graphics
glxinfo | grep -i renderer
vulkaninfo
```

This configuration provides a secure, high-performance kernel optimized for your development, gaming, audio production, and AI/ML workloads while maintaining System76 Kudu6 hardware compatibility.