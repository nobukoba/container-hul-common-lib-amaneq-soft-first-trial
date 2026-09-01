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

This repository provides a Docker / Apptainer environment containing:

- `spadi-alliance/hul-common-lib`
- `spadi-alliance/amaneq-soft`

The image is intended for development, operation, and diagnostic work with HUL/AMANEQ front-end electronics.

## Important build requirements

1. Build the container from AlmaLinux 10.1 unless the repository is intentionally being migrated to another base image. For the x86-64-v2 build, use the AlmaLinux Client Library base image `almalinux/10-base:10.1`, not the Docker Official Library image `almalinux:10.1`. AlmaLinux 10 uses x86-64-v3 binaries by default, while the Client Library publishes a dedicated `linux/amd64/v2` variant.

2. Target and publish the Docker image explicitly as `linux/amd64/v2` (x86-64-v2). Keep `linux/amd64/v2` explicit in GitHub Actions, local build helpers, Docker pull/run examples, and runtime helpers. Apple Silicon Macs should run this image through Docker Desktop's amd64 emulation with `--platform linux/amd64/v2`; do not silently change the target to plain `linux/amd64` merely because the host is arm64.

3. Build `hul-common-lib` before `amaneq-soft`.

4. Install both packages under `/opt/spadi`.

5. `amaneq-soft` must find the installed `HulCore` package through `/opt/spadi`, normally using `-DCMAKE_PREFIX_PATH=/opt/spadi`.

6. Keep the upstream repositories unmodified unless there is a clear reason to patch them. Prefer container-side build fixes when possible.

7. Do not add ROOT, NestDAQ, ARTEMIS, or unrelated DAQ software to this image unless explicitly requested.

## Container layout

Use `/opt/spadi` as the image-provided software area.

Important directories are:

```text
/opt/spadi/bin
/opt/spadi/include
/opt/spadi/lib
/opt/spadi/lib64
/opt/spadi/src
```

Use `/work` as the persistent writable user/development area.

The Docker run helper should bind a host work directory to `/work`. By default:

```text
host:      $PWD/work
container: /work
```

`run-docker-container.sh` should create the host work directory automatically if it does not exist and allow another directory to be selected with the `WORK_DIR` environment variable.

The run helper should default to the published GHCR image and to `PLATFORM=linux/amd64/v2`, while allowing both to be overridden through environment variables.

## Diagnostic and interactive tools

This image is also used when diagnosing communication with DAQ/front-end hardware. Do not remove network and system diagnostic tools merely to minimize the image size.

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

Keep Emacs available in the image for interactive editing. A terminal-oriented Emacs package such as `emacs-nox` is acceptable as long as the `emacs` command is available.

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

Keep the README synchronized with actual image names, paths, tags, helper scripts, platform requirements, and download commands.

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
- read the upstream `hul-common-lib` and `amaneq-soft` build configuration when dependency behavior matters;
- explain the specific cause of a build/runtime problem before making broad changes when possible;
- prefer targeted fixes over global compiler or dependency changes;
- preserve working behavior unrelated to the requested change;
- show concrete shell commands for testing;
- after changing the repository, report exactly which files changed and what should be tested;
- never claim to have inspected, built, tested, or modified something that was not actually accessible or executed.

When asked to rebuild or reproduce the image, first inspect the current repository and summarize the build flow and runtime flow before changing anything.

## AI assistants

These instructions are intended for ChatGPT, Codex, and other AI assistants/coding agents. They are not specific to one AI product.

`CHATGPT_REBUILD_PROMPT.md` is intentionally not used in this repository. The repository itself and this `AGENTS.md` file are the authoritative sources for development and maintenance.
