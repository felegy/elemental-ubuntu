# elemental-ubuntu

Ubuntu os derivative built via Rancher's [elemental-toolkit](https://github.com/rancher/elemental-toolkit)

## Getting Started

Getting started with Elemental

![alt text](https://docs.google.com/drawings/d/e/2PACX-1vRSuocC4_2rHeJAWW2vqinw_EZeZxTzJFo5ZwnJaL_sdKab_R_OsCTLT_LFh1_L5fUcA_2i9FIe-k69/pub?w=1223&h=691)

### Prerequisite

All dependencies in a DevContainer (`.devcontainer`) for devconatiner needed docker too be installed on system and [vscode](https://code.visualstudio.com/docs/devcontainers/containers) latest or any develper IDE with devcontainers support: <https://www.augmentedmind.de/2022/10/30/container-based-development-envs/>

### Open repo (`[Reopen in Container]`)

Clone this repo end open in vscode.

```console
$ git clone ssh://git@ssh.github.com:443/felegy/elemental-ubuntu.git
Cloning into 'elemental-ubuntu'...
... done.

$ cd elemental-ubuntu
$ code .
```

And now run devcontainer, click on `[Reopen in Container]` button.

### Install Brew dependencies

The repo it contains Brewfile for a better tooling installation.

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

When build succes finished you have an image like this:

```console
$ docker images
REPOSITORY                       TAG                     IMAGE ID       CREATED          SIZE
ghcr.io/felegy/elemental-ubuntu  v0.0.1-gb47b71f         f53d593b2c44   30 seconds ago   2.22GB
```

