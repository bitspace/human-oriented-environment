# Gimli System Specifications

## Hardware

### Manufacturer and Model

- System76 Kudu (kudu6)

### CPU

- AMD Ryzen 9 5900HX with Radeon Graphics

### BIOS

- Programmed with System76 firmware (non-open)

### Graphics

- **Dedicated GPU**: NVidia GeForce RTX 3060

- **Integrated GPU**: AMD Radeon RX Vega 8

### Memory

- 64 GiB 3200MHz

### Networking

- Ethernet: Realtek RTL8125 2.5GbE Controller (rev 05)
- WiFi: M.2 PCIe/CNVi WiFi/Bluetooth
  - Intel Wi-Fi 6 AX200 (rev 1a)

## Software

### Operating System

Gentoo Linux installed from desktop profile/systemd stage 3

### Disk Partitions and Filesystem

- 2 TiB NVMe SSD
  - `/dev/nvme0n1p1` 1GiB EFI System mounted on `/efi`
  - `/dev/nvme0n1p2` 16GiB swap
  - `/dev/nvme0n1p3` 1.8TiB xfs mounted on `/`

### Bootloader

- `systemd-boot`

### init system

- systemd
