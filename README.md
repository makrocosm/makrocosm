# Makrocosm

Makrocosm is a framework for building customized Linux operating systems.
It defines a Makefile project structure and rules that let you:

  - Build a root filesystem from Docker images that are based on a familiar
    distribution (e.g. Alpine, Ubuntu) for any architecture supported by
    multi-platform Docker builds (e.g. x86-64, aarch64), with your custom
    applications included.
  - Configure and build a Linux kernel and a bootloader.
  - Construct a disk image to boot on real hardware or virtual machines.

The Makrocosm documentation is available at [https://makrocosm.github.io/makrocosm](https://makrocosm.github.io/makrocosm).

Projects using Makrocosm:

  - [Makrocosm example project](https://www.github.com/makrocosm/example-project) - Alpine-based example firmware images with read-only rootfs, A/B partition firmware updating, Grub and u-boot bootloader examples.
    * Generic x86-64
    * Orange Pi One
    * Raspberry Pi 3 and 4
    * BeagleBoard BeaglePlay
