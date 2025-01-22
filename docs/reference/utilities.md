# Utilities

## makrocosm-disk

```
makrocosm-disk
--------------

Create and populate raw disk images with an MBR or GPT partition table

usage: makrocosm-disk DISK_IMAGE COMMAND [ARGS...]

Commands:

makrocosm-disk DISK_IMAGE create SIZE
  Create empty file DISK_IMAGE with the given SIZE (e.g. '1GB')

makrocosm-disk DISK_IMAGE table TABLE_TYPE
  Write partition table of type 'msdos' (MBR) or 'gpt' (GPT) to the disk image

makrocosm-disk DISK_IMAGE partition LABEL PARTITION_IMAGE
  Append partition PARTITION_IMAGE to the disk image, with LABEL (GPT only)

makrocosm-disk DISK_IMAGE write FILE OFFSET
  Write FILE into the disk image at at position OFFSET (e.g. '8MiB')

makrocosm-disk DISK_IMAGE info
  Print the partition layout of the disk image

Example:

makrocosm-disk build/disk.img create 1GB
makrocosm-disk build/disk.img table gpt
makrocosm-disk build/disk.img partition image1 build/rootfs.sqfs
```
