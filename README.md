# elemental-ubuntu

Ubuntu os derivative build via Rancher's [elemental-toolkit](https://github.com/rancher/elemental-toolkit)

## Getting Started

Getting started with Elemental

![](https://github.com/felegy/elemental-ubuntu/assets/1136546/fe41e79c-d69b-4844-aaae-6ec39a9db43c)


### Prerequisite

All dependencies in a DevContainer (`.devcontainer`) for devconatiner needed docker too be installed on system and [vscode](https://code.visualstudio.com/docs/devcontainers/containers) latest or any develper IDE with devcontainers support: <https://www.augmentedmind.de/2022/10/30/container-based-development-envs/>

### Open repo (`[Reopen in Container]`)

Clone this repo and open in vscode.

```console
$ git clone ssh://git@ssh.github.com:443/felegy/elemental-ubuntu.git
Cloning into 'elemental-ubuntu'...
... done.

$ cd elemental-ubuntu
$ code .
```

And now run devcontainer, click on `[Reopen in Container]` button.

### Install Brew dependencies

The repo contains a Brewfile for easier tooling installation.

```console
$ brew bundle install
==> Auto-updating Homebrew...
Adjust how often this is run with HOMEBREW_AUTO_UPDATE_SECS or disable with
HOMEBREW_NO_AUTO_UPDATE. Hide these hints with HOMEBREW_NO_ENV_HINTS (see `man brew`).
Installing from the API is now the default behaviour!
You can save space and time by running:
  brew untap homebrew/core
Using homebrew/bundle
Using editorconfig-checker
Using shellcheck
Using direnv
Using yq
Using jq
Using Command is only available in WSL or inside a Visual Studio Code terminal.
Homebrew Bundle complete! 7 Brewfile dependencies now installed.
```
### Build OS image

OS Image build is a simple docker build via make, dockerfile: (`os/ubuntu/Dockerfile`)

```console
$ make build-os  
docker build --platform linux/x86_64  \
                --build-arg TOOLKIT_REPO=ghcr.io/rancher/elemental-toolkit/elemental-cli \
                --build-arg VERSION=v2.1.0-dev-ga2c4f0b3b \
                --build-arg REPO=ghcr.io/felegy/elemental-ubuntu \
                  -t ghcr.io/felegy/elemental-ubuntu:v0.0.1-gb47b71f \
                 os/ubuntu
[+] Building 170.4s (21/21) FINISHED                              docker:default
 => [internal] load build definition from Dockerfile              0.1s
 => => transferring dockerfile: 2.82kB                            0.0s
 => [internal] load .dockerignore                                 0.1s
 => => transferring context: 2B                                   0.0s
 => [internal] load metadata for docker.io/library/ubuntu:23.04
 ...
```

When a successful build has finished, you have a docker image like this:

```console
$ docker images
REPOSITORY                       TAG                     IMAGE ID       CREATED          SIZE
ghcr.io/felegy/elemental-ubuntu  v0.0.1-gb47b71f         f53d593b2c44   30 seconds ago   2.22GB
```

### ISO build

```console
$ make build-iso 
Building x86_64 ISO
mkdir -p /workspaces/elemental-ubuntu/build
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v /workspaces/elemental-ubuntu/build:/build \
        --entrypoint /usr/bin/elemental ghcr.io/rancher/elemental-toolkit/elemental-cli:v2.1.0-dev-ga2c4f0b3b --debug build-iso --bootloader-in-rootfs -n elemental-ubuntu.x86_64 \
        --local --platform linux/x86_64 --squash-no-compression --config-dir=/build -o /build ghcr.io/felegy/elemental-ubuntu:v0.0.1-gb47b71f
DEBU[2024-03-18T16:56:41Z] Starting elemental version v2.1.0-dev on commit a2c4f0b3b0950d559a8fcaaa14972de6d9c68f1a 
INFO[2024-03-18T16:56:41Z] Reading configuration from '/build'

...

INFO[2024-03-18T16:56:41Z] Preparing squashfs root (1 source)...        
INFO[2024-03-18T16:56:41Z] Copying ghcr.io/felegy/elemental-ubuntu:v0.0.1-gb47b71f source... 

...

INFO[2024-03-18T16:58:00Z] Preparing ISO image root tree... 

...

INFO[2024-03-18T16:58:00Z] Creating squashfs...

...

Drive current: -outdev '/build/elemental-ubuntu.x86_64.iso'
Media current: stdio file, overwriteable
Media status : is blank
Media summary: 0 sessions, 0 data blocks, 0 data,  947g free
xorriso : UPDATE : 16 files added in 1 seconds
Added to ISO image: directory '/'='/tmp/elemental-iso242682882/iso'
xorriso : UPDATE : Writing:      10917s    2.3%   fifo   0%  buf  50%
xorriso : UPDATE : Writing:     122880s   25.5%   fifo  12%  buf  50%  165.3xD 
xorriso : UPDATE : Writing:     248470s   51.5%   fifo   6%  buf  50%  185.4xD 
xorriso : UPDATE : Writing:     356103s   73.8%   fifo   0%  buf  50%  158.9xD 
ISO image produced: 482497 sectors
Written to medium : 482512 sectors at LBA 48
Writing to '/build/elemental-ubuntu.x86_64.iso' completed successfully.
```
When a successful ISO build has finished, you have a bootable iso like this:

```console
ls -lh build 
total 943M
-rw-r--r-- 1 root   root   943M Mar 18 16:59 elemental-ubuntu.x86_64.iso
-rw-r--r-- 1 root   root     93 Mar 18 16:59 elemental-ubuntu.x86_64.iso.sha256
-rw-r--r-- 1 vscode vscode  101 Mar 18 15:03 manifest.yaml
```

### Booting ISO

In the step above, your ISO file is a bootable UEFI iso image, ideal for a virtual machine (or any) installation scenarios.

Grub:

![](https://github.com/felegy/elemental-ubuntu/assets/1136546/28e2a66f-8687-45ea-a6c3-99e53290ede9)

When Live OS has been booted login via `root` and `cos` as password, and now install the system:

```console
Welcome to Ubuntu 23.04 (GNU/Linux 6.2.0-39-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

This system has been minimized by removing packages and content that are
not required on a system that users do not log into.

To restore this content, you can run the 'unminimize' command.

The programs included with the Ubuntu system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.

$ elemental install /dev/sda
WARN[0000] Could not read state file /run/initramfs/elemental-state/state.yaml
INFO[2024-03-18T17:21:10Z] Starting elemental version v2.1.0-dev
INFO[2024-03-18T17:21:10Z] Reading configuration from '/etc/elemental'
INFO[2024-03-18T17:21:10Z] Install called
INFO[2024-03-18T17:21:10Z] Partitioning device...
INFO[2024-03-18T17:21:12Z] Mounting disk partitions
INFO[2024-03-18T17:21:13Z] Initiating a LoopDevice snapshotter at /run/elemental/state
INFO[2024-03-18T17:21:13Z] Running before-install hook
INFO[2024-03-18T17:21:13Z] Starting snapshotter transaction
INFO[2024-03-18T17:21:13Z] Starting a snapshotter transaction
INFO[2024-03-18T17:21:13Z] path /run/elemental/state/.snapshots/active does not exist
INFO[2024-03-18T17:21:13Z] Transaction for snapshot 1 successfully started
INFO[2024-03-18T17:21:13Z] Copying /run/rootfsbase source...
INFO[2024-03-18T17:21:13Z] Starting rsync...
INFO[2024-03-18T17:21:46Z] Finished syncing
INFO[2024-03-18T17:21:46Z] Finished copying /run/rootfsbase into /run/elemental/state/.snapshots/1/snapshot.workDir
INFO[2024-03-18T17:21:46Z] Fine tune the dumped root tree
INFO[2024-03-18T17:21:47Z] Entry created for elemental-shim in the EFI boot manager
INFO[2024-03-18T17:21:47Z] Using grub config file /run/elemental/state/.snapshots/1/snapshot.workDir/etc/elemental/grub.cfg
INFO[2024-03-18T17:21:47Z] Copying grub config file from /run/elemental/state/.snapshots/1/snapshot.workDir/etc/elemental/grub.cfg to /run/elemental/efi/EFI/BOOT/grub.cfg
INFO[2024-03-18T17:21:47Z] Using grub config file /run/elemental/state/.snapshots/1/snapshot.workDir/etc/elemental/grub.cfg
INFO[2024-03-18T17:21:47Z] Copying grub config file from /run/elemental/state/.snapshots/1/snapshot.workDir/etc/elemental/grub.cfg to /run/elemental/efi/EFI/ELEMENTAL/grub.cfg
INFO[2024-03-18T17:21:49Z] Running after-install-chroot hook
INFO[2024-03-18T17:21:49Z] Running after-install hook
INFO[2024-03-18T17:21:50Z] Setting default grub entry to Elemental
INFO[2024-03-18T17:21:50Z] Closing snapshotter transaction
INFO[2024-03-18T17:21:50Z] Closing transaction for snapshot 1 workdir
INFO[2024-03-18T17:21:50Z] Creating image /run/elemental/state/.snapshots/1/snapshot.img from rootDir /run/elemental/state/.snapshots/1/snapshot.workDir
INFO[2024-03-18T17:21:51Z] Sync /run/elemental/state/.snapshots/1/snapshot.workDir to /run/elemental/workingtree
INFO[2024-03-18T17:21:51Z] Starting rsync...
INFO[2024-03-18T17:22:20Z] Finished syncing
INFO[2024-03-18T17:22:24Z] Cleaning old passive snapshots
INFO[2024-03-18T17:22:24Z] Setting bootloader with current passive snapshots
INFO[2024-03-18T17:22:25Z] Deploying recovery system
INFO[2024-03-18T17:22:25Z] Deploying image: /run/elemental/recovery/recovery.img
INFO[2024-03-18T17:22:25Z] Creating image /run/elemental/recovery/recovery.img from rootDir /run/elemental/recovery/recovery.imgTree
INFO[2024-03-18T17:22:29Z] Sync /run/elemental/recovery/recovery.imgTree to /run/elemental/transition
INFO[2024-03-18T17:22:29Z] Starting rsync...
INFO[2024-03-18T17:23:22Z] Finished syncing
INFO[2024-03-18T17:23:24Z] Running post-install hook
INFO[2024-03-18T17:23:24Z] Creating installation state files
INFO[2024-03-18T17:23:24Z] Unmounting disk partitions

$ reboot
```

Install finished and the first boot:

![image](https://github.com/felegy/elemental-ubuntu/assets/1136546/c0a37445-1cd9-4f9e-bc8f-9e7811211427)

