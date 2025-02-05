FROM ubuntu:24.04

RUN --mount=target=/var/lib/apt/lists,type=cache,sharing=locked \
    --mount=target=/var/cache/apt,type=cache,sharing=locked \
    rm -f /etc/apt/apt.conf.d/docker-clean \
    && apt-get update \
    && apt-get -y --no-install-recommends install \
      sudo \
      # kernel and u-boot cross compile \
      gcc-x86-64-linux-gnux32 gcc-arm-linux-gnueabi gcc-aarch64-linux-gnu \
      build-essential flex bison bc libelf-dev libssl-dev kmod \
      python3 python3-dev python3-pip python3-setuptools swig \
      libgnutls28-dev \
      # download \
      ca-certificates curl \
      # tar2fat \
      dosfstools mtools \
      # tar2sqfs \
      squashfs-tools \
      # tar2cpio \
      cpio fakeroot \
      # tar2ext4 \
      libarchive-dev \
      # disk \
      parted fdisk file \
      # qcow2 \
      qemu-utils \
      # bmaptool \
      bmap-tools \
      # misc \
      units qemu-system


RUN pip install --break-system-packages mkdocs mkdocs-material

# e2fsprogs v1.47.1 or later is required for tar input support
RUN mkdir -p /tmp/e2fsprogs \
  && cd /tmp/e2fsprogs \
  && curl -fsSLo ./src.tar.gz https://github.com/tytso/e2fsprogs/archive/refs/tags/v1.47.1.tar.gz \
  && tar zxf src.tar.gz --strip-components=1 \
  && ./configure \
  && make -j && make install \
  && rm -rf /tmp/e2fsprogs

#ARG DOCKER_GID
#RUN groupadd -o -g $DOCKER_GID docker
RUN curl -fsSL https://get.docker.com  | sudo /bin/sh

COPY installkernel /sbin/installkernel
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

RUN chown -R ubuntu /home
USER ubuntu

WORKDIR /workspace

CMD [ "/bin/bash" ]
