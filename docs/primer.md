# Primer

Makrocosm provides Makefile rules to build a Linux kernel, build a
bootloader, export container images from Docker, and convert between
file formats.
Utilities are provided to help combine these components into a disk
image in custom rules.
This framework is especially useful for building customized Linux operating
systems as firmware for embedded devices.

Using Makrocosm involves writing a Makefile with rules that target your
desired build artifacts, creating the required dependency files, and
`make`-ing the targets.

## Makefile rules

Makrocosm uses [Make](https://www.gnu.org/software/make/manual/html_node/index.html)
as a build system, ensuring no final or intermediate artifacts are re-built
unless any of their dependencies have changed.

The Makefile rules pages in the Reference section documents pattern rules
provided by Makrocosm that perform a function without having to write
any recipe script.
These rules are described by the following properties:

 - Target: The name of the build artifact that the rule will create.
   These are usually patterns where the `${var}` part represents an
   arbitrary relative path that must match your project structure.
 - Required dependencies: Names of source files that you must create for
   `make` to build the target with the rule.
   These may also be patterns that must be consistent with the target filename.
 - Optional dependencies: Names of source files that you may create and
   manually add as a prerequisite of the target.
 - Built dependencies: Names of build artifacts that you must ensure are
   able to be created by other rules.
   Rules with targets that are dependencies of other rules are chained
   and built as required.
   These may also be patterns that must be consistent with the target filename.

Makrocosm's Makefile rules are indexed in the following table:

| Target                         | Dependencies                                 | Reference documentation
|--------------------------------|----------------------------------------------|-------------------------
| `build/${path}`                | `${path}.container.cfg` `${path}/Dockerfile` | [Build container image](reference/makefile-rules/container-image.md#build-container-image)
| `build/${path}.tar`            | `${path}.container.cfg` `${path}/Dockerfile` | [Export container image to tar](reference/makefile-rules/container-image.md#export-container-image-to-tar)
| `build/${file}.sqfs`           | `${file}.sqfs.cfg` `build/${file}.tar`       | [Convert tar to Squashfs image](reference/makefile-rules/filesystems.md#convert-tar-to-squashfs-image)
| `build/${file}.ext4`           | `${file}.ext4.cfg` `build/${file}.tar`       | [Convert tar to ext4 image](reference/makefile-rules/filesystems.md#convert-tar-to-ext4-image)
| `build/${file}.fat`            | `${file}.fat.cfg` `build/${file}.tar`        | [Convert tar to FAT image](reference/makefile-rules/filesystems.md#convert-tar-to-fat-image)
| `build/${file}.cpio`           | `${file}.cpio.cfg` `build/${file}.tar`       | [Convert tar to cpio archive](reference/makefile-rules/filesystems.md#convert-tar-to-cpio-archive)
| `build/${path}/linux/install`  | `${path}/linux.cfg` `build/${path}/linux.src` `build/${path}/linux/.config` | [Build Linux kernel and modules](reference/makefile-rules/linux.md#build-linux-kernel-and-modules) 
| `build/${path}/linux/.config`  | `${path}/linux.cfg` `build/${path}/linux.src` `*.kconfig` | [Linux Kconfig build configuration](reference/makefile-rules/linux.md#linux-kconfig-build-configuration) 
| `build/${path}/u-boot/install` | `${path}/u-boot.cfg` `build/${path}/u-boot.src` `build/${path}/u-boot/.config` | [Build u-boot](reference/makefile-rules/u-boot.md#build-u-boot) 
| `build/${path}/u-boot/.config` | `${path}/u-boot.cfg` `build/${path}/u-boot.src` `*.kconfig` | [u-boot Kconfig build configuration](reference/makefile-rules/u-boot.md#u-boot-kconfig-build-configuration) 
| `build/${path}.src`            | `${path}.git.cfg` `*.patch`                  | [Clone Git repository](reference/makefile-rules/file-fetch.md#clone-git-repository)
| `build/${path}.src`            | `${path}.download.cfg` `*.patch`             | [Download file](reference/makefile-rules/file-fetch.md#download-file)
| `build/${file}.qcow2`          | `build/${file}.raw`                          | [Convert raw disk image to QCOW2](reference/makefile-rules/disk-formats.md#convert-raw-disk-image-to-qcow2)
| `build/${file}.xz`             | `build/${file}`                              | [Compress file with xz](reference/makefile-rules/file-compression.md#compress-file-with-xz)
| `build/${file}.gz`             | `build/${file}`                              | [Compress file with gzip](reference/makefile-rules/file-compression.md#compress-file-with-gzip)
| `build/${file}.md5`            | `build/${file}`                              | [Calculate MD5 checksum](reference/makefile-rules/file-metadata.md#calculate-md5-checksum)
| `build/${file}.sha256`         | `build/${file}`                              | [Calculate SHA256 checksum](reference/makefile-rules/file-metadata.md#calculate-sha256-checksum)
| `build/${file}.sha512`         | `build/${file}`                              | [Calculate SHA512 checksum](reference/makefile-rules/file-metadata.md#calculate-sha512-checksum)
| `build/${file}.bmap`           | `build/${file}`                              | [Generate bmap metadata](reference/makefile-rules/file-metadata.md#generate-bmap-metadata)
| `build/${file}.pad`            | `${file}.pad.cfg` `build/${file}`            | [Pad file to size](reference/makefile-rules/misc.md#pad-file-to-size)

Note that the targets all have the `build/` prefix, which creates
the target files in the `build` directory of the project root.
There is a clear distinction between source and build artifacts.

Also note that Make selects rules from candidates using dependencies it can
build in addition to the the dependencies already present -- rules are chained
together, creating intermediate targets to satisfy dependencies.
For example, if you target `build/rootfs.sqfs` and have the file
`rootfs.container.cfg`, then Make will build the intermediate target
`build/rootfs.tar` from the [Export container image to tar](reference/makefile-rules/container-image.md#export-container-image-to-tar)
rule before building the final target with the [Convert tar to Squashfs image](reference/makefile-rules/filesystems.md#convert-tar-to-squashfs-image) 
rule.

To print a trace of the commands that are run, set the `VERBOSE` environment
variable when invoking Make, e.g. `make VERBOSE=1 ...`.

## Configuration files

A number of Makrocosm Makefile rules expect a `.cfg`-suffixed configuration
file to be present as a required dependency.
Configuration files must define options in new line separated key/value pairs,
e.g. `KEY=VALUE`.
Conventional single and double shell quoting rules apply as these files
are evaluated as shell scripts

The options that are required to be set in the configuration files are
described on the relevant Makefile rule's Reference page.

## Disk images

Due to the variation in provisioning memory devices and constructing partition
layouts for different hardware platforms and requirements, Makrocosm does not
provide Makefile rules to automatically prepare disk images.
It does, however, provide the [makrocosm-disk](reference/utilities.md#makrocosm-disk)
utility that can be used in your own rules to construct disk images with GPT
or MBR partiton tables, commonly used with block device storage media like
hard drives and SD cards.

## Workspace

To simplify setup of dependencies on the host system, the dependencies are
installed in a Ubuntu 24.04 container image (default, see 
[available workspaces](https://github.com/makrocosm/makrocosm/tree/main/workspace)).

Each shell command in Makefile recipes is run in a container using the
[makrocosm-workspace](https://github.com/makrocosm/makrocosm/blob/main/bin/makrocosm-workspace)
command, which passes through necessary host system resources such as the
caller's UID/GID, the project root directory, and the Docker Unix domain
socket.

Run `make shell` to start an interactive shell in the workspace. This lets
you experiment in the environment that the Makefile rules' recipes are
executed in.

The workspace container image is built using a [Build container image](reference/makefile-rules/container-image.md#build-container-image)
rule and will be automatically rebuilt when the Dockerfile or any files in
its build context change.

### Custom workspace

A custom container image can be used instead of the default Makrocosm
workspace, allowing any additional packages to be made available in the
build.

The custom container image is built using the [Container images](reference/makefile-rules/container-image.md)
Makefile rule that builds the image into the container image store, and
is rebuilt automatically when the container source changes.

In your Makefile, set the `WORKSPACE` variable to the stem of the
`*.container.cfg` target that to the container source.
For example, for a container image defined by
`custom/workspace-ubuntu-24.04.container.cfg` and built with
`custom/workspace-ubuntu-24.04/Dockerfile`:

```make
WORKSPACE := custom/workspace-ubuntu-24.04

include makrocosm/rules.mk
```
