# container-hul-common-lib-amaneq-soft-first-trial

Docker / Apptainer container for the SPADI `hul-common-lib` and `amaneq-soft` software.

The image is based on AlmaLinux 10.1 and targets `linux/amd64/v2` (x86-64-v2).

## Included software

The container builds and installs:

- [`spadi-alliance/hul-common-lib`](https://github.com/spadi-alliance/hul-common-lib)
- [`spadi-alliance/amaneq-soft`](https://github.com/spadi-alliance/amaneq-soft)

They are installed under `/opt/spadi`.

The image also includes common network and system diagnostic tools such as `ip`, `ping`, `ss`, `netstat`, `dig`, `nslookup`, `traceroute`, `tcpdump`, `nc`, `curl`, and `lsof`. Emacs is also included for interactive editing.

## How to use

### Docker

Pull the latest image from GHCR:

```bash
docker pull --platform linux/amd64/v2 \
  ghcr.io/nobukoba/container-hul-common-lib-amaneq-soft-first-trial:latest
```

Run it:

```bash
mkdir -p work

docker run --rm -it \
  --platform linux/amd64/v2 \
  --network host \
  -v "$PWD/work:/work" \
  ghcr.io/nobukoba/container-hul-common-lib-amaneq-soft-first-trial:latest
```

The host directory `./work` is mounted at `/work` in the container.

On Apple Silicon Macs, `--platform linux/amd64/v2` makes Docker Desktop use amd64 emulation. On Linux, `--network host` is useful when communicating directly with HUL/AMANEQ front-end hardware. Docker Desktop on macOS implements host networking through its Linux VM, so its behavior is not identical to native Linux host networking.

### Apptainer / Singularity

Download the latest SIF image:

```bash
curl -L -O \
  https://github.com/nobukoba/container-hul-common-lib-amaneq-soft-first-trial/releases/download/latest/container-hul-common-lib-amaneq-soft-first-trial.sif
```

Run it with Apptainer:

```bash
mkdir -p work

apptainer shell \
  --bind "$PWD/work:/work" \
  container-hul-common-lib-amaneq-soft-first-trial.sif
```

or Singularity:

```bash
singularity shell \
  --bind "$PWD/work:/work" \
  container-hul-common-lib-amaneq-soft-first-trial.sif
```

## Container layout

Important paths inside the container are:

```text
/opt/spadi/bin
/opt/spadi/include
/opt/spadi/lib
/opt/spadi/lib64
/opt/spadi/src
/work
```

`/opt/spadi` contains the installed software. `/work` is the writable area intended for user files and development work.

## For Developers

Development and maintenance information is collected here so that the sections above remain focused on normal container users.

### Clone and helper scripts

```bash
git clone https://github.com/nobukoba/container-hul-common-lib-amaneq-soft-first-trial.git
cd container-hul-common-lib-amaneq-soft-first-trial
```

The repository provides these user/developer helper scripts at the top level:

```text
build-docker-image.sh
run-docker-container.sh
login-docker-container.sh
```

To run the published GHCR image through the helper:

```bash
./run-docker-container.sh
```

It defaults to:

```text
image:    ghcr.io/nobukoba/container-hul-common-lib-amaneq-soft-first-trial:latest
platform: linux/amd64/v2
work:     $PWD/work -> /work
network:  host
```

In another terminal, enter the running container with:

```bash
./login-docker-container.sh
```

The image, platform, and work directory can be overridden when needed:

```bash
IMAGE=container-hul-common-lib-amaneq-soft-first-trial:latest ./run-docker-container.sh
PLATFORM=linux/amd64/v2 ./run-docker-container.sh
WORK_DIR=/path/to/work ./run-docker-container.sh
```

### Build locally

```bash
./build-docker-image.sh
```

The local build explicitly targets `linux/amd64/v2` by default and creates both a UTC timestamped tag and `latest`:

```text
container-hul-common-lib-amaneq-soft-first-trial:YYYYMMDD-HHMMutc
container-hul-common-lib-amaneq-soft-first-trial:latest
```

Build parallelism can be changed with `NPROC`:

```bash
NPROC=8 ./build-docker-image.sh
```

### Published images and tags

GitHub Actions publishes the GHCR image as `linux/amd64/v2` with both:

```text
latest
YYYYMMDD-HHMMutc
```

For example:

```text
ghcr.io/nobukoba/container-hul-common-lib-amaneq-soft-first-trial:latest
ghcr.io/nobukoba/container-hul-common-lib-amaneq-soft-first-trial:20260901-1234utc
```

The workflow also creates:

```text
container-hul-common-lib-amaneq-soft-first-trial.sif
container-hul-common-lib-amaneq-soft-first-trial-YYYYMMDD-HHMMutc.sif
```

The stable SIF is published in the GitHub `latest` release.

### AI-assisted maintenance

For development and maintenance of this container, use **ChatGPT, Codex, or another AI assistant/coding agent** together with [`AGENTS.md`](./AGENTS.md).

Before modifying the container, the AI agent should read `AGENTS.md` and inspect the current repository files. `AGENTS.md` contains the repository-specific build requirements, directory layout, image/tag conventions, diagnostic-tool requirements, and maintenance guidelines.

`CHATGPT_REBUILD_PROMPT.md` is not used in this repository. The repository itself and `AGENTS.md` are the authoritative sources for development and maintenance.
