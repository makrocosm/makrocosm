# u-boot bootloader

Compile [u-boot](https://www.u-boot.org/) in the `build/` directory using
the workspace container by defining an appropriate
`${dir}/u-boot.cfg` file and targeting `build/${dir}/u-boot/install`.

## u-boot Kconfig build configuration

The `.config` target is the Kbuild configuration containing options
set for the u-boot build.
This file is generated using `scripts/kconfig/merge_config.sh` from the
u-boot source, which combines the defconfig and `*.kconfig` fragments.

  - Target: `build/${dir}/u-boot/.config`
  - Required dependencies:
    - `${dir}/u-boot.cfg` - See [Configuration file](#configuration-file).
  - Optional dependencies:
    - `*.kconfig` - Fragments of Kconfig configuration that get merged
      into the defconfig, if specified as `DEFCONFIG` in `u-boot.cfg`.
      If no defconfig is specified, the `*.kconfig` fragments are merged
      to create the complete `.config`.
  - Built dependencies:
    - `build/${dir}/u-boot.src` - The sentinel file generated when the u-boot
      source code is downloaded to `build/${dir}/u-boot` using one of the
      [file fetching](file-fetch.md) rules.

## Build u-boot

The `install` target is the destination directory that the bootloader
files are installed to when they are built.
The files generated depend on the target platform and configuration.

  - Target: `build/${dir}/u-boot/install`
  - Required dependencies:
    - `${dir}/u-boot.cfg` - See [Configuration file](#configuration-file).
  - Built dependencies:
    - `build/${dir}/u-boot.src` - The sentinel file generated when the u-boot
      source code is downloaded to `build/${dir}/u-boot` using one of the
      [file fetching](file-fetch.md) rules.
    - `build/${dir}/u-boot/.config` - The target of the
      [u-boot Kconfig build configuration](#u-boot-kconfig-build-configuration) rule.

## Configuration file

The following options are valid in the `${dir}/u-boot.cfg` configuration file.

  - `ARCH` - *Required* - The architecture of the target platform's CPU.
  - `CROSS_COMPILE` - *Required* - The binutils toolchain prefix for selecting the correct
    cross-compiling gcc/ld/etc binaries for the target platform.
    Equivalent to the `CROSS_COMPILE` environment variable when building u-boot manually. 
    Note that the toolchains available to the u-boot build are those in the workspace container.
  - `DEFCONFIG` - *Optional* - The stem of the platform's defconfig file, e.g. `sunxi` for
    the `orangepi_one` available for the ARM architecture.
    Equivalent to `make ${platform}_defconfig` in u-boot's build system.
  - `INSTALL_FILENAMES` - *Optional* - A space-separated list of filenames of
    the build artifacts that will be copied from the build directory
    `build/${dir}/u-boot` to the install target directory
    `build/${dir}/u-boot/install`.
    Default: `u-boot.bin`.

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
