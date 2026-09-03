# Repository instructions for AI agents

This file contains the instructions and design constraints that AI assistants and coding agents should read before rebuilding or modifying this repository.

The repository itself is the authoritative source for the current package versions, scripts, build options, and runtime configuration. Before making changes, inspect the current repository, especially:

- `Dockerfile`
- `README.md`
- `.github/workflows/docker.yml`
- `build-docker-image.sh`
- `run-docker-container.sh`
- `login-docker-container.sh`

Do not recreate the environment only from this document. Preserve the current repository behavior unless a change is necessary.

## Purpose

This repository provides a Docker / Apptainer runtime environment containing:

- `spadi-alliance/hul-common-lib`
- `spadi-alliance/amaneq-soft`
- `trabucayre/openFPGALoader`
- `nobukoba/sitcp-sitcpxg-mpc-mpcx-ip-utility-first-trial`

The published image is intended primarily for operation, network diagnostics, FPGA programming, and SiTCP configuration with HUL/AMANEQ front-end electronics. It is not intended to be a general development image.

## Important build requirements

1. Build the container from AlmaLinux 9 unless the repository is intentionally being migrated to another base image. Use the standard `almalinux:9` image.

2. Target and publish the Docker image as standard `linux/amd64`. Keep `linux/amd64` explicit in GitHub Actions, local build helpers, Docker pull/run examples, and runtime helpers. Apple Silicon Macs should run the image through Docker Desktop's amd64 emulation with `--platform linux/amd64`.

3. Use a multi-stage Docker build. Compilers, CMake, Make, Git, source trees, `*-devel` packages, and other build-only dependencies belong in the builder stage and must not be retained in the final runtime image.

4. Build `hul-common-lib` before `amaneq-soft`.

5. Install image-provided software under `/opt/spadi`. This includes `hul-common-lib`, `amaneq-soft`, `openFPGALoader`, and the SiTCP/SiTCP-XG MPC/MPCX/IP utilities.

6. `amaneq-soft` must find the installed `HulCore` package through `/opt/spadi`, normally using `-DCMAKE_PREFIX_PATH=/opt/spadi`.

7. Build `openFPGALoader` from the upstream `trabucayre/openFPGALoader` source tree with CMake and install it under `/opt/spadi`. Keep required Linux USB/JTAG build dependencies in the builder stage and corresponding runtime libraries in the final stage.

8. Build `nobukoba/sitcp-sitcpxg-mpc-mpcx-ip-utility-first-trial` from source and install it with `make PREFIX=/opt/spadi install`. Keep its public commands in `/opt/spadi/bin`.

9. Keep source-ref build arguments available for source-built components. At minimum preserve `HUL_COMMON_LIB_REF`, `AMANEQ_SOFT_REF`, `OPENFPGALOADER_REF`, and `SITCP_IP_UTILITY_REF` unless the versioning policy is intentionally changed.

10. Keep the upstream repositories unmodified unless there is a clear reason to patch them. Prefer container-side build fixes when possible.

11. Do not add ROOT, NestDAQ, ARTEMIS, or unrelated DAQ software to this image unless explicitly requested.

## Runtime image policy

The final published image should be kept focused on operation and diagnostics.

Do not keep the following in the final stage unless explicitly requested:

```text
gcc
gcc-c++
make
cmake
git
emacs
*-devel packages
upstream source trees
```

Build-only content should live in the Docker builder stage. The runtime image should contain only installed programs, required runtime libraries, practical shell/file utilities, and the diagnostic tools described below.

## Container layout

Use `/opt/spadi` as the image-provided software area.

Important runtime directories are:

```text
/opt/spadi/bin
/opt/spadi/include
/opt/spadi/lib
/opt/spadi/lib64
/opt/spadi/share
/workspace
```

Upstream sources should be checked out in a temporary build-stage location such as `/tmp/spadi-src`; do not retain `/opt/spadi/src` source trees in the final runtime image.

Use `/workspace` as the user/runtime workspace.

The Docker run helper should bind the current host directory to `/workspace` by default:

```text
host:      $PWD
container: /workspace
```

The container should start in `/workspace`. `run-docker-container.sh` should allow another host directory to be selected with the `WORKSPACE_DIR` environment variable.

The run helper should default to the published GHCR image and to `PLATFORM=linux/amd64`, while allowing both to be overridden through environment variables.

## FPGA and SiTCP hardware access

`openFPGALoader` needs access to the host USB/JTAG programmer. Installing the program in the image does not by itself expose USB devices to Docker. Keep README instructions describing the additional USB device passthrough needed on native Linux. A privileged `/dev/bus/usb` mapping is acceptable as a simple development example, but document that narrower device access is preferable where practical.

The SiTCP utilities communicate over RBCP/UDP and therefore depend on host/container networking reaching the front-end network. Preserve `--network host` in the primary native-Linux Docker usage unless there is an intentional networking redesign.

Important public commands currently include:

```text
openFPGALoader
mpc-mpcx-ip-writer
mpc-mpcx-ip-reader
mpc-mpcx-ip-command
sitcp-sitcpxg-ip-writer
sitcp-sitcpxg-ip-reader
```

## Diagnostic tools

This image is used when diagnosing communication with DAQ/front-end hardware. Do not remove network and system diagnostic tools merely to minimize the image size.

Keep a practical diagnostic set installed, including commands provided by packages such as:

```text
iproute
iputils
net-tools
bind-utils
traceroute
tcpdump
nmap-ncat
curl
wget
procps-ng
psmisc
lsof
which
```

The resulting image should provide commonly used commands such as:

```text
ip
ping
ss
netstat
dig
nslookup
traceroute
tcpdump
nc
curl
lsof
ps
```

A lightweight editor such as `vim-minimal` may remain available, but Emacs should not be included in the final runtime image unless explicitly requested.

## GitHub Actions and images

GitHub Actions should build and publish the Docker image to:

```text
ghcr.io/nobukoba/container-hul-common-lib-amaneq-soft-first-trial
```

For each successful build, publish both:

```text
latest
YYYYMMDD-HHMMutc
```

Generate the timestamp with UTC time using:

```bash
date -u +%Y%m%d-%H%Mutc
```

GitHub Actions should also create an Apptainer/Singularity SIF image from the timestamped Docker image and publish both:

```text
container-hul-common-lib-amaneq-soft-first-trial.sif
container-hul-common-lib-amaneq-soft-first-trial-YYYYMMDD-HHMMutc.sif
```

Publish the SIF files as workflow artifacts and in the `latest` GitHub release so that the stable SIF download URL documented in the README remains usable.

Keep the README synchronized with actual included software, commands, image names, paths, tags, helper scripts, platform requirements, hardware-access requirements, runtime/build-stage separation, and download commands.

## Repository-level helper scripts

Keep the main user-facing helper scripts at the repository top level:

```text
build-docker-image.sh
run-docker-container.sh
login-docker-container.sh
```

These scripts are entry points for repository-wide operations and should remain easy to discover. Put internal implementation helpers under `scripts/` only when such helpers are actually needed.

## How AI agents should work on this repository

When working on this repository:

- inspect the current GitHub/repository state before editing;
- read the upstream build configuration when dependency behavior matters;
- explain the specific cause of a build/runtime problem before making broad changes when possible;
- prefer targeted fixes over global compiler or dependency changes;
- preserve working behavior unrelated to the requested change;
- preserve the network-diagnostic environment in the final image;
- keep build tools and source trees out of the final image;
- show concrete shell commands for testing;
- after changing the repository, report exactly which files changed and what should be tested;
- never claim to have inspected, built, tested, or modified something that was not actually accessible or executed.

When asked to rebuild or reproduce the image, first inspect the current repository and summarize the build flow and runtime flow before changing anything.

## AI assistants

These instructions are intended for ChatGPT, Codex, and other AI assistants/coding agents. They are not specific to one AI product.

`CHATGPT_REBUILD_PROMPT.md` is intentionally not used in this repository. The repository itself and this `AGENTS.md` file are the authoritative sources for development and maintenance.
