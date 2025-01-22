# Disk formats

Convert disk images to different formats.
See the [Primer's disk images section](../../primer.md#disk-images) for
information on how to combine filesystem images into a raw disk image.

## Convert raw disk image to QCOW2

Convert a raw disk image to the QEMU Copy On Write image format.
QCOW2 images are sparse and support snapshotting, and work well with QEMU
virtual machines.

  - Target: `build/${file}.qcow2`
  - Built dependencies:
    - `build/${file}.raw` - The raw disk image that will be converted to
      QCOW2 format.
