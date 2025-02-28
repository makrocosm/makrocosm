# Filesystems

Filesystem images can be written to a disk image, or mounted to a
loop device.

## Convert tar to Squashfs image

Construct a Squashfs filesystem image with the contents of a tar archive.
  
  - Target: `build/${file}.sqfs`
  - Required dependencies:
    - `${file}.sqfs.cfg` -  See the Squashfs configuration file details below.
  - Built dependencies:
    - `build/${file}.tar` - The tar archive to populate the filesystem image
      with.

### Configuration file

The following options are valid in the `${file}.sqfs.cfg` configuration file.

  - `COMPRESSION` - *Optional* - Compress the filesystem with the nominated
    compressor.
    Available compressors: `gzip`, `lzo`, `lz4`, `xz`, `zstd`, `lzma`.
    Default: `zstd`.

## Convert tar to ext4 image

Construct an ext4 filesystem image with the contents of a tar archive.

  - Target: `build/${file}.ext4`
  - Required dependencies:
    - `${file}.ext4.cfg` - See the ext4 configuration file details below.
  - Built dependencies:
    - `build/${file}.tar` - The tar archive to populate the filesystem image
      with.

### Configuration file

The following options are valid in the `${file}.ext4.cfg` configuration file.

  - `SIZE` - *Required* - The size of the image to create and format with
    the ext4 filesystem. If no units are provided, e.g. `1GB`, then the
    size is interpreted as bytes.
  - `LABEL` - *Optional* - A text label to give to the filesystem.
    If not provided, the label will be derived from the basename of the
    target `${file}` variable.

### Example

This configuration file describes a 2GB ext4 image labelled "data":

```sh title="data.ext4.cfg"
LABEL=data
SIZE=2GB
```

This Makefile rule shows how to define a phony target `build`
that generates the ext4 image file `build/data.ext4` with the contents
of `build/data.tar` which must be generated by other rules (not shown):

```make
.PHONY: build
build: build/data.ext4
```

## Convert tar to FAT image

Construct a FAT filesystem image with the contents of a tar archive.

  - Target: `build/${file}.fat`
  - Required dependencies:
    - `${file}.fat.cfg` -  See the FAT configuration file details below.
  - Built dependencies:
    - `build/${file}.tar` - The tar archive to populate the filesystem image
      with.

### Configuration file

The following options are valid in the `${file}.fat.cfg` configuration file.

  - `SIZE` - *Required* - The size of the image to create and format with
    the FAT filesystem. If no units are provided, e.g. `1GB`, then the
    size is interpreted as bytes.
  - `LABEL` - *Optional* - A text label to give to the filesystem.
    If not provided, the label will be derived from the basename of the
    target `${file}` variable.
  - `TYPE` - *Optional* - Override the auto-selected FAT size of the
    created filesystem.
    Available types: `fat32`, `fat16`, `fat12`.

## Convert tar to cpio archive

Convert a tar archive to a cpio archive.
The cpio archive is constructed with the `newc` format which makes it
usable as a Linux kernel initramfs after being [gzipped](file-compression.md#compress-file-with-gzip)
by targeting the `build/${file}.cpio.gz` build artifact.

  - Target: `build/${file}.cpio`
  - Built dependencies:
    - `build/${file}.tar` - The tar file to convert to cpio.
