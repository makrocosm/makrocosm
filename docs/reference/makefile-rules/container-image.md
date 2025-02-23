# Container image

Build a container image using a Dockerfile.
The container image can be [saved to the local Docker image store](#build-container-image)
by targeting `build/${path}`, or [exported to a tar archive](#export-container-image-to-tar)
by targeting `build/${path}.tar`.

The primary build context is the directory `${path}`, expecting the
[Dockerfile](https://docs.docker.com/build/concepts/dockerfile/)
`${path}/Dockerfile` to be present.
Additional directories can be added with the [`BUILD_CONTEXTS`](#configuration-file) configuration
variable.
The build process generates a `build/${path}.container.d` file containing
the dependencies between the target and the contents of the build contexts
so that any changed file causes the rule's recipe to run.
This shortcuts the Docker build when not required, which further analyses
the build contexts for changed files that are `COPY`ed or `ADD`ed into the
image and invalidates cached layers.
The dependency file is used automatically.

## Build container image

Build a container image and save it to the Docker container image store.
The rule's target is a sentinel file that gets updated when the container image
is updated.
  
  - Target: `build/${path}`
  - Required dependencies:
    - `${file}.container.cfg` -  See [Configuration file](#configuration-file).

The name of the created container image is derived from the target `${path}`,
where path separators `/` are replaced with hyphens `-`.
For example, targeting `build/common/alpine/rootfs` will create the container image
named `base-alpine-rootfs`. The value of the `DOCKER_TAG_PREFIX` configuration option
is prepended to this name.

This container image can be referenced by other Dockerfiles in `FROM` and
`COPY --from` statements, however the dependency on the target sentinel file
must be added explicitly.
For example, for the following Dockerfile:

```Dockerfile title="platform/x64/rootfs/Dockerfile"
FROM base-alpine-rootfs
```

The dependency must be added to the Makefile as below:

```make
# For container image in store
build/platform/x64/rootfs: build/common/alpine/rootfs

# For container image exported to tar
build/platform/x64/rootfs.tar: build/common/alpine/rootfs
```

When using the [containerd image store](https://docs.docker.com/engine/storage/containerd/)
which supports multi-architecture image manifests, the configuration file's
`ARCH` value may be a comma separated list of architecture names.
For example, `ARCH=arm,arm64`.
  
## Export container image to tar

Build a container image and export it to a tar archive.
The tar archive can be easily converted to a [filesystem image](filesystems.md)
using other rules.
  
  - Target: `build/${path}.tar`
  - Required dependencies:
    - `${file}.container.cfg` -  See [Configuration file](#configuration-file).

## Configuration file

The following options are valid in the `${path}.container.cfg` configuration file.

   - `ARCH` - *Optional* - The architecture (for tar export) or comma
     separated list of architectures (for container store) to build the
     container image for.
     See output of `make deps` for supported architectures.
     Default: the host architecture.
   - `BUILD_CONTEXTS` - *Optional* - Space separated list of `NAME=PATH` [build contexts](https://docs.docker.com/reference/cli/docker/buildx/build/#build-context)
      that are made available in the Dockerfile.
   - `BUILD_ARGS` - *Optional* - Space separated list of `KEY=VALUE` [build variables](https://docs.docker.com/reference/cli/docker/buildx/build/#build-arg)
     that are made available in the Dockerfile.
   - `DOCKER_ARGS` - *Optional* - Extra arguments to pass to the
     `docker build` command.
   - `DOCKER_TAG_PREFIX` - *Optional* - Prefix to use on the resulting Docker
     image tag during export to the container store.
