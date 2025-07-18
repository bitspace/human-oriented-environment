# Gentoo on my System76 Kudu

## Things to remember

- `emerge` only removes kernel build directory, not kernel modules or installed kernel image. For complete clean-up of old kernels, install and use `app-admin/eclean-kernel`.
- `NetworkManager` is able to use `D-Bus` to start the iwd service when needed; therefore, once ``NetworkManager` and `D-Bus` are installed and operational, the `iwd` service does not need to be enabled explicitly.

## some packages

```text
dev-lang/rust
```

```text
I would like to dive into the kernel configuration a bit. It has been many years since I've hand-configured and compiled a Linux kernel, and a lot has changed. The hardware I am installing this on is a System76 Kudu laptop, which has an AMD CPU and integrated GPU as well as an Nvidia 3060 mobile discrete GPU. It has intel AX bluetooth/wifi
```
