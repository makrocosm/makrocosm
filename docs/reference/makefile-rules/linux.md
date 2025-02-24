# Linux kernel

Compile the Linux kernel in the `build/` directory using the workspace
container by defining an appropriate `${dir}/linux.cfg` file and targeting
`build/${dir}/linux/install`.

## Linux Kconfig build configuration

The `.config` target is the Kbuild configuration containing options
set for the kernel build.
This file is generated using `scripts/kconfig/merge_config.sh` from the
kernel source, which combines the defconfig and `*.kconfig` fragments.

  - Target: `build/${dir}/linux/.config`
  - Required dependencies:
    - `${dir}/linux.cfg` - See [Configuration file](#configuration-file).
  - Optional dependencies:
    - `*.kconfig` - Fragments of Kconfig configuration that get merged
      into the defconfig, if specified as `DEFCONFIG` in `linux.cfg`.
      If no defconfig is specified, the `*.kconfig` fragments are merged
      to create the complete `.config`.
  - Built dependencies:
    - `build/${dir}/linux.src` - The sentinel file generated when the Linux
      source code is downloaded to `build/${dir}/linux` using one of the
      [file fetching](file-fetch.md) rules.

## Build Linux kernel and modules

The `install` target is the destination directory that the kernel
and modules will be installed to when they are built.
The directory follows the conventional `boot/` for kernel image and device
tree, and `lib/modules/` for kernel modules.

  - Target: `build/${dir}/linux/install`
  - Required dependencies:
    - `${dir}/linux.cfg` - See [Configuration file](#configuration-file).
  - Built dependencies:
    - `build/${dir}/linux.src` - The sentinel file generated when the Linux
      source code is downloaded to `build/${dir}/linux` using one of the
      [file fetching](file-fetch.md) rules.
    - `build/${dir}/linux/.config` - The target of the
      [Linux Kconfig build configuration](#linux-kconfig-build-configuration) rule.

## Configuration file

The following options are valid in the `${dir}/linux.cfg` configuration file.

  - `ARCH` - *Required* - The architecture of the target platform's CPU.
    Equivalent to the `ARCH` environment variable when building Linux manually
    (See [Kbuild ARCH documentation](https://github.com/torvalds/linux/blob/master/Documentation/kbuild/kbuild.rst#arch)).
  - `CROSS_COMPILE` - *Required* - The binutils toolchain prefix for selecting the correct
    cross-compiling gcc/ld/etc binaries for the target platform.
    Equivalent to the `CROSS_COMPILE` environment variable when building Linux manually. 
    Note that the toolchains available to the kernel build are those in the workspace container.
  - `DEFCONFIG` - *Optional* - The stem of the platform's defconfig file, e.g. `sunxi` for
    the `sunxi_defconfig` available for the ARM architecture.
    Equivalent to `make ${platform}_defconfig` in Linux's build system.
  - `INSTALL_TARGET` - *Optional* - Architecture-specific install
    target used when building Linux manually, determines the type of the
    kernel binary copied to the `linux/install` directory when built.
    E.g. ARM's `zinstall` for compressed image or `uinstall` for u-boot
    wrapped image. Default: `install`
  - `DTB` - *Optional* - The name of a device tree binary to be copied to
    the `linux/install` directory when built.
    Specify relative to the platform architecture's `dts` directory e.g.
    `allwinner/sun8i-h3-orangepi-one.dtb` found in `arch/arm/boot/dts/`.

!!! note
    The interactive workspace shell can used to discover the available
    toolchains to use for the `CROSS_COMPILE` prefix.
    For example:

    ```shell-sesion
    $ make shell CMD=bash
    /workspace$ compgen -c | grep '\-gcc$' | sort | uniq
    aarch64-linux-gnu-gcc
    arm-linux-gnueabi-gcc
    c89-gcc
    c99-gcc
    x86_64-linux-gnu-gcc
    x86_64-linux-gnux32-gcc
    ```

## Example

This example shows configuration for the kernel built for the
[Makrocosm Example Project's Alpine Orange Pi One image](https://github.com/makrocosm/example-project/tree/main/platform/opi1).

The `linux.cfg` configuration sets the cross-compilation options for ARM,
the kernel configuration for the Orange Pi One's CPU family (`sunxi`) and
device tree for the Orange Pi One platform.

```sh title="platform/opi1/linux.cfg"
ARCH=arm
CROSS_COMPILE=arm-linux-gnueabi-
DEFCONFIG=sunxi
INSTALL_TARGET=zinstall
DTB=allwinner/sun8i-h3-orangepi-one.dtb
```

The `linux.git.cfg` configuration defines the Git repository where the kernel
source tree can be cloned from, and the version tag to use
(See the [Clone Git repository](file-fetch.md#clone-git-repository) Makefile rule).

```sh title="platform/opi1/linux.git.cfg"
URL=git@github.com:torvalds/linux.git
REFNAME=v6.10
```

The Makefile fragment adds a `filesystem.kconfig` dependency to the
`.config` target in the Linux build directory, instructing the build to merge
extra SquashFS and OverlayFS options into the nominated defconfig to create
the `.config`.

```make title="platform/opi1/build.mk"
...

build/platform/opi1/linux/.config: common/alpine/linux/filesystems.kconfig

...
```

```sh title="common/alpine/linux/filesystems.kconfig"
CONFIG_SQUASHFS=y
CONFIG_SQUASHFS_XZ=y
CONFIG_SQUASHFS_ZSTD=y
CONFIG_OVERLAY_FS=m
```

The `.config` is a dependency of the `linux/install` target.
Running the command `make build/platform/opi1/linux/install` selectively
builds the kernel installs it to that directory:

``` title="build/platform/opi1/linux/install"
├── boot
│   ├── sun8i-h3-orangepi-one.dtb
│   └── zImage
└── lib
    └── modules
        └── 6.10.0
            ├── kernel
            │   └── fs
            │       └── overlayfs
            │           └── overlay.ko
            ├── modules.alias
            ├── modules.alias.bin
            ├── modules.builtin
            ├── modules.builtin.alias.bin
            ├── modules.builtin.bin
            ├── modules.builtin.modinfo
            ├── modules.dep
            ├── modules.dep.bin
            ├── modules.devname
            ├── modules.order
            ├── modules.softdep
            ├── modules.symbols
            └── modules.symbols.bin
```

The `linux/install` target is used by the Alpine Orange Pi example build to
include the kernel and kernel modules in the root filesystem.
