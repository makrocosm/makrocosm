# Overview

Makrocosm is a framework for building customized Linux operating systems.
It defines a Makefile project structure and rules that let you:

  - Build a root filesystem from Docker images that are based on a familiar
    distribution (e.g. Alpine, Ubuntu) for any architecture supported by
    multi-platform Docker builds (e.g. x86-64, aarch64), with your custom
    applications included.
  - Configure and build a Linux kernel and a bootloader.
  - Construct a disk image to boot on real hardware or virtual machines.

Projects using Makrocosm:

  - [Makrocosm example project](https://www.github.com/makrocosm/example-project)
    - Alpine-based example firmware images for x64, Orange Pi One, Raspberry Pi 3 and 4, and the BeagleBoard BeaglePlay.
    - Demonstrates read-only rootfs, A/B partition firmware updating, cross-compiling applications, and u-boot and Grub bootloaders.

## Comparison

Makrocosm has a similar utility for building embedded Linux firmware as
[Buildroot](https://buildroot.org/) or [Yocto](https://www.yoctoproject.org/),
but Makrocosm differs significantly by its ethos of leveraging Docker builds
and compiling the bare minimum.

The most appreciable difference for the developer using Makrocosm is that
the root filesystem is constructed *procedurally* by instructions in a
Dockerfile rather than being *declaratively* defined in configuration files.

### Pros
  
  - Familiar Dockerfile experience.
  - Conventional tools (i.e. make, shell).
  - Faster build times due to use of pre-built packages.
  - Cached base layers can be used by multiple build targets with the same
    architecture.

### Cons

  - Achieving reproducible builds with Docker requires effort.
    Providers of apk/deb/rpm/etc package repositories generally do not retain
    old versions of packages, making package pinning difficult.
  - More effort to apply patches to packages in upstream package repositories.
