# Directory of Makefile
export ROOT_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

ARCH?=$(shell uname -m)
PLATFORM?=linux/$(ARCH)
TOOLKIT_REPO?=ghcr.io/rancher/elemental-toolkit/elemental-cli
TOOLKIT_VERSION?=v2.1.0-dev-ga2c4f0b3b

DOCKER?=docker
DOCKER_SOCK?=/var/run/docker.sock

REPO?=ghcr.io/felegy/elemental-ubuntu
FLAVOR?=ubuntu

GIT_COMMIT?=$(shell git rev-parse HEAD)
GIT_COMMIT_SHORT?=$(shell git rev-parse --short HEAD)
GIT_TAG?=$(shell git describe --candidates=50 --abbrev=0 --tags 2>/dev/null || echo "v0.0.1" )
VERSION?=$(GIT_TAG)-g$(GIT_COMMIT_SHORT)

.PHONY: build-os
build-os:
	$(DOCKER) build --platform $(PLATFORM) ${DOCKER_ARGS} \
			--build-arg TOOLKIT_REPO=$(TOOLKIT_REPO) \
			--build-arg TOOLKIT_VERSION=$(TOOLKIT_VERSION) \
			--build-arg REPO=$(REPO) -t $(REPO):$(VERSION) \
			--build-arg VERSION=$(VERSION) \
			$(BUILD_OPTS) os/$(FLAVOR)

.PHONY: pull-toolkit
pull-toolkit:
	$(DOCKER) pull $(TOOLKIT_REPO):$(TOOLKIT_VERSION)

.PHONY: push-os
push-os:
	$(DOCKER) push $(REPO):$(VERSION)

.PHONY: pull-os
pull-os:
	$(DOCKER) pull $(REPO):$(VERSION)


.PHONY: build-iso
build-iso:
	@echo Building $(ARCH) ISO
	mkdir -p $(ROOT_DIR)/build
	$(DOCKER) run --rm -v $(DOCKER_SOCK):$(DOCKER_SOCK) -v $(ROOT_DIR)/build:/build \
		--entrypoint /usr/bin/elemental $(TOOLKIT_REPO):$(TOOLKIT_VERSION) --debug build-iso --bootloader-in-rootfs -n elemental-$(FLAVOR).$(ARCH) \
		--local --platform $(PLATFORM) --squash-no-compression --config-dir=/build -o /build $(REPO):$(VERSION)

.PHONY: build-disk
build-disk:
	@echo Building $(ARCH) disk
	mkdir -p $(ROOT_DIR)/build
	$(DOCKER) run --rm -v $(DOCKER_SOCK):$(DOCKER_SOCK) -v $(ROOT_DIR)/build:/build \
		--entrypoint /usr/bin/elemental \
		$(TOOLKIT_REPO):$(TOOLKIT_VERSION) --debug build-disk --platform $(PLATFORM) --expandable -n elemental-$(FLAVOR).$(ARCH) --local \
		--squash-no-compression --config-dir=/build -o /build --system $(REPO):$(VERSION)

.PHONY: clean
clean:
	rm -fv $(ROOT_DIR)/build/elemental-$(FLAVOR).$(ARCH).{raw,img,qcow2,vmdk,iso,iso.sha256}
