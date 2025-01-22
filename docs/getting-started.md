# Getting started

This page shows how to set up a new project that uses Makrocosm.
The [Makrocosm example project](https://www.github.com/makrocosm/example-project)
is also available as a reference.

## Prerequisites

Using Makrocosm requires the following packages to be installed:

  - git
  - make (likely requires GNU make)
  - Docker Engine (tested with 27.3.1)

!!! tip "Important"

    The version of Docker that might be available from your host distribution's
    package repository might be outdated.
    Follow [these instructions to install Docker Engine](https://docs.docker.com/engine/install/),
    then [give your user permission to use Docker](https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user),
    and critically, [enable the containerd image store](https://docs.docker.com/engine/storage/containerd/)
    to allow multi-architecture images to be built and saved in the local image store.

Other packages required by Makrocosm are built into the [Workspace](primer.md#workspace) container.

Building with Makrocosm has been tested on these operating systems:

  - Ubuntu 22.04

## Project layout

[Makrocosm](https://www.github.com/makrocosm/makrocosm) is designed to be
used as a submodule in your own git repository, making it simple to update.

For example:

```shell-session
$ mkdir proj
$ cd proj
$ git init
$ git submodule add https://www.github.com/makrocosm/makrocosm.git
```

See the [Git book's Submodules chapter](https://git-scm.com/book/en/v2/Git-Tools-Submodules)
for details on how to work with cloning, comitting, and updating submodules.

If you do not use Git, you can instead copy the contents of the Makrocosm
git repository into your project.

## Makefile

The top-level makefile in your project directory is the entrypoint into
the build system.
Open the file `Makefile` and include Makrocosm.

```make title="Makefile"
include makrocosm/rules.mk
```

Run `make deps` to build the [workspace container image](primer.md#workspace),
check the containerd image store has been enabled, and install the emulators
required for building multi-architecture Docker images.

Run `make help` to print the command help.

```shell-session
$ make help
Makrocosm targets
-----------------

Run with "make VERBOSE=1 ..." to see make and tool trace

  help: Display this help
  deps: Install dependencies
  shell: Enter a shell in the workspace container
  clean: Remove built artifacts from the build directory
  distclean: Remove the build directory

```

Your project is ready to start developing firmware and disk images.
See the [Makrocosm Primer](primer.md) for next steps.
