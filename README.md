# container-hul-common-lib-amaneq-soft-first-trial

Docker / Apptainer container for the SPADI `hul-common-lib` and `amaneq-soft` software.

The image is based on AlmaLinux 10.1 and includes command-line tools useful for development and network diagnostics.

## How to use

### Docker: pull from GHCR

The published Docker image targets `linux/amd64/v2` (x86-64-v2). On Apple Silicon Macs, specify the platform explicitly so Docker Desktop uses amd64 emulation.

```bash
docker pull --platform linux/amd64/v2 \
  ghcr.io/nobukoba/container-hul-common-lib-amaneq-soft-first-trial:latest
```

Run it directly:

```bash
docker run --rm -it \
  --platform linux/amd64/v2 \
  --network host \
  -v "$PWD/work:/work" \
  ghcr.io/nobukoba/container-hul-common-lib-amaneq-soft-first-trial:latest
```

Or clone this repository and use the helper script:

```bash
git clone https://github.com/nobukoba/container-hul-common-lib-amaneq-soft-first-trial.git
cd container-hul-common-lib-amaneq-soft-first-trial
./run-docker-container.sh
```

`run-docker-container.sh` defaults to the published GHCR `latest` image and explicitly uses `linux/amd64/v2`, so a separate `docker pull` is normally not required. Docker will pull the image automatically if it is not already present locally.

The host directory `./work` is mounted at `/work` in the container.

You can override the image or platform when deliberately needed:

```bash
IMAGE=container-hul-common-lib-amaneq-soft-first-trial:latest ./run-docker-container.sh
PLATFORM=linux/amd64/v2 ./run-docker-container.sh
```

The helper also uses `--network host`. This is especially useful on Linux hosts when communicating directly with HUL/AMANEQ front-end hardware. Docker Desktop on macOS implements host networking through its Linux VM, so its behavior is not identical to native Linux host networking.

### Apptainer / Singularity

The latest SIF image is published in the GitHub `latest` release.

```bash
curl -L -O \
  https://github.com/nobukoba/container-hul-common-lib-amaneq-soft-first-trial/releases/download/latest/container-hul-common-lib-amaneq-soft-first-trial.sif
```

Run it with:

```bash
apptainer shell \
  --bind "$PWD/work:/work" \
  container-hul-common-lib-amaneq-soft-first-trial.sif
```

For Singularity:

```bash
singularity shell \
  --bind "$PWD/work:/work" \
  container-hul-common-lib-amaneq-soft-first-trial.sif
```

## Image tags

GitHub Actions publishes two Docker tags for each successful build:

```text
latest
YYYYMMDD-HHMMutc
```

For example:

```text
ghcr.io/nobukoba/container-hul-common-lib-amaneq-soft-first-trial:latest
ghcr.io/nobukoba/container-hul-common-lib-amaneq-soft-first-trial:20260901-1234utc
```

The workflow also creates both:

```text
container-hul-common-lib-amaneq-soft-first-trial.sif
container-hul-common-lib-amaneq-soft-first-trial-YYYYMMDD-HHMMutc.sif
```

## Included software

The container builds and installs:

- `spadi-alliance/hul-common-lib`
- `spadi-alliance/amaneq-soft`

They are installed under `/opt/spadi`.

Important paths are:

```text
/opt/spadi/bin
/opt/spadi/include
/opt/spadi/lib
/opt/spadi/lib64
/opt/spadi/src
/work
```

`/opt/spadi` is the image-provided software area. `/work` is intended for user files and development work.

The image also includes common network and system diagnostic commands such as `ip`, `ping`, `ss`, `netstat`, `dig`, `nslookup`, `traceroute`, `tcpdump`, `nc`, `curl`, `lsof`, `ps`, and related utilities. Emacs is also included for interactive editing.

## Build locally

```bash
git clone https://github.com/nobukoba/container-hul-common-lib-amaneq-soft-first-trial.git
cd container-hul-common-lib-amaneq-soft-first-trial
./build-docker-image.sh
```

The local build explicitly targets `linux/amd64/v2` by default and creates both a UTC timestamped tag and `latest`:

```text
container-hul-common-lib-amaneq-soft-first-trial:YYYYMMDD-HHMMutc
container-hul-common-lib-amaneq-soft-first-trial:latest
```

You can override the build parallelism, for example:

```bash
NPROC=8 ./build-docker-image.sh
```

The default platform is:

```bash
PLATFORM=linux/amd64/v2 ./build-docker-image.sh
```

## Container helper scripts

The repository-level helper scripts are kept at the top level so that the common operations are easy to find:

```text
build-docker-image.sh
run-docker-container.sh
login-docker-container.sh
```

Use `run-docker-container.sh` to start a named interactive container. In another terminal, use `login-docker-container.sh` to enter the running container.

## For Developers

For development and maintenance of this container, please use **ChatGPT, Codex, or another AI assistant/coding agent** together with the instructions in [`AGENTS.md`](./AGENTS.md).

Before modifying the container, ask the AI agent to read `AGENTS.md` and inspect the current repository files. `AGENTS.md` contains the repository-specific build requirements, directory layout, image/tag conventions, diagnostic-tool requirements, and maintenance guidelines.

`CHATGPT_REBUILD_PROMPT.md` is not used in this repository. The repository itself and `AGENTS.md` are the authoritative sources for development and maintenance.
