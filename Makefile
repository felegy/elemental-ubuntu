# Directory of Makefile
export ROOT_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

ARCH?=$(shell uname -m)
PLATFORM?=linux/$(ARCH)
TOOLKIT_REPO?=ghcr.io/rancher/elemental-toolkit/elemental-cli
TOOLKIT_VERSION?=v2.2.1

DOCKER?=docker
DOCKER_SOCK?=/var/run/docker.sock
DOCKER_VERSION?=23.0.3

REPO?=ghcr.io/felegy/elemental-ubuntu
FLAVOR?=ubuntu

GIT_COMMIT?=$(shell git rev-parse HEAD)
GIT_COMMIT_SHORT?=$(shell git rev-parse --short HEAD)
GIT_TAG?=$(shell git describe --candidates=50 --abbrev=0 --tags 2>/dev/null || echo "v0.0.1" )
VERSION?=$(GIT_TAG)-g$(GIT_COMMIT_SHORT)

.PHONY: build-os
build-os:
	$(DOCKER) build --platform $(PLATFORM) ${DOCKER_ARGS} \
			--build-arg REPO=$(REPO) \
			--build-arg VERSION=$(VERSION) \
			--build-arg TOOLKIT_REPO=$(TOOLKIT_REPO) \
			--build-arg TOOLKIT_VERSION=$(TOOLKIT_VERSION) \
			--build-arg DEBS="$(DEBS)" \
			--tag $(REPO):$(VERSION) \
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
		-v $(ROOT_DIR)/overlay-iso/iso-config/remote_login.yaml:/overlay-iso/iso-config/remote_login.yaml \
		--entrypoint /usr/bin/elemental $(TOOLKIT_REPO):$(TOOLKIT_VERSION) --debug build-iso \
		-n elemental-$(FLAVOR).$(ARCH) --overlay-iso /overlay-iso \
		--local --platform $(PLATFORM) -o /build $(REPO):$(VERSION)

.PHONY: build-disk
build-disk:
	@echo Building $(ARCH) disk
	mkdir -p $(ROOT_DIR)/build
	$(DOCKER) run --rm -v $(DOCKER_SOCK):$(DOCKER_SOCK) -v $(ROOT_DIR)/build:/build \
		--entrypoint /usr/bin/elemental \
		$(TOOLKIT_REPO):$(TOOLKIT_VERSION) --debug build-disk --platform $(PLATFORM) -n elemental-$(FLAVOR).$(ARCH) --local \
		--config-dir=/build -o /build --system $(REPO):$(VERSION)

.PHONY: clean
clean:
	rm -fv $(ROOT_DIR)/build/elemental-$(FLAVOR).$(ARCH).{raw,img,qcow2,vmdk,iso,iso.sha256}
