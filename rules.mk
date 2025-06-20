#? Makrocosm targets
#? -----------------
#?

# Path variables
export MAKEFILE_ROOT = $(dir $(abspath $(firstword $(MAKEFILE_LIST))))
export MKDISTRO_ROOT := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
ifeq ($(MKDISTRO_ROOT),$(MAKEFILE_ROOT))
	MKDISTRO_ROOT := .
else
	MKDISTRO_ROOT := $(MKDISTRO_ROOT:$(MAKEFILE_ROOT)%/=%)
endif

#? Run with "make VERBOSE=1 ..." to see make and tool trace
#?
export VERBOSE ?=
ifeq ($(VERBOSE),1)
	AT =
else
	AT = @ 
endif

# Always clean up partially constructed recipe targets
.DELETE_ON_ERROR:

# Comment hint for "make help"
HELP_COMMENT ?= '\#!'

###############################################################################
## Workspace
###############################################################################

# The directory target of the workspace container to use for building.
# Override if a custom workspace is required.
# Clear to build in the host environment.
ifeq ($(MKDISTRO_ROOT),.)
	WORKSPACE ?= workspace/ubuntu-24.04
else
	WORKSPACE ?= $(MKDISTRO_ROOT)/workspace/ubuntu-24.04
endif

ifneq ($(WORKSPACE),)
# Make sure the workspace image is up to date. This runs before all targets.
_ := $(shell make --quiet WORKSPACE= build/$(WORKSPACE) >&2)

# Run recipe commands in the workspace container shell, but falls back
# to the host environment if the workspace image is not available.
SHELL = $(MKDISTRO_ROOT)/bin/makrocosm-workspace $(WORKSPACE) /bin/sh

endif

###############################################################################
## File fetch
###############################################################################

.PRECIOUS: build/%.src
build/%.src: %.git.cfg
	@echo "---------------------------------------------------- -----"
	@. "./$*.git.cfg" && echo "Checking out $$URL @ $$REFNAME"
	@echo "----------------------------------------------------------"
	$(AT)$(MKDISTRO_ROOT)/tools/git-clone "build/$*" "./$*.git.cfg" $(filter %.patch,$^)

.PRECIOUS: build/%.src
build/%.src: %.download.cfg
	@echo "---------------------------------------------------- -----"
	@. "./$*.download.cfg" && echo "Downloading $$URL"
	@echo "----------------------------------------------------------"
	$(AT)$(MKDISTRO_ROOT)/tools/download "build/$*" "./$*.download.cfg" $(filter %.patch,$^)


###############################################################################
## Container images
###############################################################################

.PRECIOUS: build/% build/%.d
build/% build/%.d: %.container.cfg
	@echo "----------------------------------------------------------"
	@echo "[$*] Building container image"
	@echo "----------------------------------------------------------"
	$(AT)$(MKDISTRO_ROOT)/tools/docker-build store "./$*.container.cfg" "$*" "$@"

.PRECIOUS: build/%.tar build/%.tar.d
build/%.tar build/%.tar.d: %.container.cfg
	@echo "----------------------------------------------------------"
	@echo "[$*] Building container image to tar export"
	@echo "----------------------------------------------------------"
	$(AT)$(MKDISTRO_ROOT)/tools/docker-build tar "./$*.container.cfg" "$*" "$@"

-include $(shell find -type f -iname '*.container.d')

###############################################################################
## Linux kernel
###############################################################################

.PRECIOUS: build/%/linux/install
build/%/linux/install: %/linux.cfg build/%/linux.src build/%/linux/.config
	$(AT)rm -rf "$@"
	$(AT). "./$*/linux.cfg" \
		&& make -j 4 -C "build/$*/linux" \
			ARCH=$${ARCH} \
			CROSS_COMPILE=$${CROSS_COMPILE} \
			olddefconfig \
			all
	$(AT)mkdir -p "$@/boot"
	$(AT). "./$*/linux.cfg" \
		&& make -j 4 -C "build/$*/linux" \
			ARCH=$${ARCH} \
			CROSS_COMPILE=$${CROSS_COMPILE} \
			INSTALL_PATH="/workspace/build/$*/linux/install/boot" \
			INSTALL_MOD_PATH="/workspace/build/$*/linux/install" \
			$${INSTALL_TARGET:-install} \
			modules_install \
		&& for f in $${DTB}; do \
			cp -rfL build/$*/linux/arch/$${ARCH}/boot/dts/$$f build/$*/linux/install/boot/ ; \
		done
	$(AT)rm -f build/$*/linux/install/lib/modules/*/build
	$(AT)touch "$@"

.PRECIOUS: build/%/linux/.config
build/%/linux/.config: %/linux.cfg build/%/linux.src
	$(AT). "./$*/linux.cfg" \
		&& build/$*/linux/scripts/kconfig/merge_config.sh -m -n -r -y -O "$(dir $@)" \
			$${DEFCONFIG:+build/$*/linux/arch/$${ARCH}/configs/$${DEFCONFIG}_defconfig} \
			$(filter %.kconfig,$^)

###############################################################################
## u-boot bootloader
###############################################################################

.PRECIOUS: build/%/u-boot/install
build/%/u-boot/install: %/u-boot.cfg build/%/u-boot.src build/%/u-boot/.config
	$(AT)rm -rf "$@"
	$(AT)mkdir -p "$@"
	$(AT). "./$*/u-boot.cfg" \
		&& make -j 4 -C "build/$*/u-boot" \
			ARCH=$${ARCH} \
			CROSS_COMPILE=$${CROSS_COMPILE} \
			olddefconfig \
			all \
		&& for f in $${INSTALL_FILENAMES:-u-boot.bin}; do \
			cp -rfL build/$*/u-boot/$$f build/$*/u-boot/install ; \
		done

.PRECIOUS: build/%/u-boot/.config
build/%/u-boot/.config: %/u-boot.cfg build/%/u-boot.src
	$(AT). "./$*/u-boot.cfg" \
	  && build/$*/u-boot/scripts/kconfig/merge_config.sh -m -n -r -O "$(dir $@)" \
	  	$${DEFCONFIG:+build/$*/u-boot/configs/$${DEFCONFIG}_defconfig} \
	  	$(filter %.kconfig,$^)


###############################################################################
## Arbitrary scripting
###############################################################################

.PRECIOUS: build/%.exec
build/%.exec: %.sh build/%.src
	$(AT) DIR="$$(pwd)" \
		&& cd "build/$*" \
		&& sh "$$DIR/$<" \
		&& touch "$$DIR/$@"


###############################################################################
## Filesystems
###############################################################################

.PRECIOUS: build/%.sqfs
build/%.sqfs: %.sqfs.cfg build/%.tar
	@echo "----------------------------------------------------------"
	@echo "[$*] Converting tar to squashfs image"
	@echo "----------------------------------------------------------"
	$(AT)$(MKDISTRO_ROOT)/tools/tar2sqfs "./$*.sqfs.cfg" "build/$*.tar" "$@"

.PRECIOUS: build/%.ext4
build/%.ext4: %.ext4.cfg build/%.tar
	@echo "----------------------------------------------------------"
	@echo "[$*] Converting tar to ext4 image"
	@echo "----------------------------------------------------------"
	$(AT)$(MKDISTRO_ROOT)/tools/tar2ext4 "./$*.ext4.cfg" "build/$*.tar" "$@"

.PRECIOUS: build/%.fat
build/%.fat: %.fat.cfg build/%.tar
	@echo "----------------------------------------------------------"
	@echo "[$*] Converting tar to FAT image"
	@echo "----------------------------------------------------------"
	$(AT)$(MKDISTRO_ROOT)/tools/tar2fat "./$*.fat.cfg" "build/$*.tar" "$@"
		
.PRECIOUS: build/%.cpio
build/%.cpio: build/%.tar
	@echo "---------------------------------------------------- -----"
	@echo "[$*] Converting tar to cpio archive"
	@echo "----------------------------------------------------------"
	$(AT)$(MKDISTRO_ROOT)/tools/tar2cpio "$<" "$@"


###############################################################################
## Disk image conversions
###############################################################################

.PRECIOUS: build/%.qcow2
build/%.qcow2: build/%.img
	@echo "----------------------------------------------------------"
	@echo "[$*] Converting raw disk image to qcow2"
	@echo "----------------------------------------------------------"
	$(AT)qemu-img convert -f raw -O qcow2 "$<" "$@"


###############################################################################
## File compression
###############################################################################

.PRECIOUS: build/%.xz
build/%.xz: build/%
	@echo "----------------------------------------------------------"
	@echo "[$*] Compressing with xz"
	@echo "----------------------------------------------------------"
	$(AT)xz --stdout --compress -v "$<" > "$@"

.PRECIOUS: build/%.gz
build/%.gz: build/%
	@echo "----------------------------------------------------------"
	@echo "[$*] Compressing with gzip"
	@echo "----------------------------------------------------------"
	$(AT)gzip -9 -n < "$<" > "$@"


###############################################################################
## File metadata
###############################################################################

.PRECIOUS: build/%.md5
build/%.md5: build/%
	@echo "----------------------------------------------------------"
	@echo "[$*] Generating MD5 checksum"
	@echo "----------------------------------------------------------"
	$(AT)cd $(dir $@) && md5sum $(notdir $<) > $(notdir $@)

.PRECIOUS: build/%.sha256
build/%.sha256: build/%
	@echo "----------------------------------------------------------"
	@echo "[$*] Generating SHA256 checksum"
	@echo "----------------------------------------------------------"
	$(AT)cd $(dir $@) && sha256sum $(notdir $<) > $(notdir $@)

.PRECIOUS: build/%.sha512
build/%.sha512: build/%
	@echo "----------------------------------------------------------"
	@echo "[$*] Generating SHA512 checksum"
	@echo "----------------------------------------------------------"
	$(AT)cd $(dir $@) && sha512sum $(notdir $<) > $(notdir $@)

.PRECIOUS: build/%.bmap
build/%.bmap: build/%
	@echo "----------------------------------------------------------"
	@echo "[$*] Generating bmap"
	@echo "----------------------------------------------------------"
	$(AT)bmaptool create "$<" > "$@"


###############################################################################
## File manipulation
###############################################################################

.PRECIOUS: build/%.pad
build/%.pad: %.pad.cfg build/%
	@echo "----------------------------------------------------------"
	@echo "[$*] Padding file"
	@echo "----------------------------------------------------------"
	$(AT)$(MKDISTRO_ROOT)/tools/pad "./$*.pad.cfg" "build/$*" "$@"


###############################################################################
## Misc
###############################################################################

.PHONY: help
help: #? Display this help
	@sed -rn -e 's/^#\?$$//p' -e 's/^#\? (.*)/\1/p' -e 's/(.+: ).*#\? (.*)/  \1\2/p' $(MAKEFILE_LIST)

.PHONY: deps
deps: #? Install dependencies
	@echo "Checking for cross-platform image store capability..."
	$(AT)[ "$$(docker info -f '{{ .DriverStatus }}')" = '[[driver-type io.containerd.snapshotter.v1]]' ] \
			|| (echo "containerd image store required"; false)
	@echo "Reinstalling cross-platform emulators..."
	$(AT)docker run --rm --privileged tonistiigi/binfmt --uninstall '*'
	$(AT)docker run --rm --privileged tonistiigi/binfmt --install all

.PHONY: tftpboot
tftpboot: SHELL = /bin/sh
tftpboot: #? Run a tftp server providing files from the build directory
	@echo "Serving build directory over TFTP on port 69"
	@docker run --rm \
		-p=69:1069/udp \
		--env=TFTPD_BIND_ADDRESS=0.0.0.0:1069 \
		--env=TFTPD_EXTRA_ARGS='--blocksize 1468' \
		--cap-drop=all --cap-add=SETUID --cap-add=SETGID --cap-add=SYS_CHROOT \
		--volume=./build:/tftpboot \
		docker.io/kalaksi/tftpd

.PHONY:
shell: #? Enter a shell in the workspace container
ifeq ($(CMD),)
	$(AT)/bin/sh
else
	$(AT)/bin/sh -c "$(CMD)"
endif

.PHONY: clean
clean: #? Remove built artifacts from the build directory
	rm -rf $(filter-out build/git,$(wildcard build/*))

.PHONY: distclean
distclean: #? Remove the build directory
	rm -rf build

#?
