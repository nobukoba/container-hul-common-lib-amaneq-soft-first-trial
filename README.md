# container-hul-common-lib-amaneq-soft-first-trial

Docker / Apptainer container for SPADI HUL/AMANEQ software, FPGA programming, and SiTCP configuration utilities.

The image is based on AlmaLinux 9 and targets standard `linux/amd64`.

## Included software

The container builds and installs:

- [`spadi-alliance/hul-common-lib`](https://github.com/spadi-alliance/hul-common-lib)
- [`spadi-alliance/amaneq-soft`](https://github.com/spadi-alliance/amaneq-soft)
- [`trabucayre/openFPGALoader`](https://github.com/trabucayre/openFPGALoader)
- [`nobukoba/sitcp-sitcpxg-mpc-mpcx-ip-utility-first-trial`](https://github.com/nobukoba/sitcp-sitcpxg-mpc-mpcx-ip-utility-first-trial)

They are installed under `/opt/spadi`.

The image also includes common network and system diagnostic tools such as `ip`, `ping`, `ss`, `netstat`, `dig`, `nslookup`, `traceroute`, `tcpdump`, `nc`, `curl`, and `lsof`. Emacs is also included for interactive editing.

Important installed commands include:

```text
openFPGALoader
mpc-mpcx-ip-writer
mpc-mpcx-ip-reader
mpc-mpcx-ip-command
sitcp-sitcpxg-ip-writer
sitcp-sitcpxg-ip-reader
```

## How to use

### Docker

#### Linux / macOS

Pull the latest image from GHCR:

```bash
docker pull --platform linux/amd64 \
  ghcr.io/nobukoba/container-hul-common-lib-amaneq-soft-first-trial:latest
```

Run the container from the directory you want to use as your workspace:

```bash
docker run --rm -it \
  --platform linux/amd64 \
  --network host \
  -v "$PWD:/workspace" \
  ghcr.io/nobukoba/container-hul-common-lib-amaneq-soft-first-trial:latest
```

The current host directory (`$PWD`) is mounted at `/workspace` in the container, and the container starts in `/workspace`.

On Apple Silicon Macs, `--platform linux/amd64` makes Docker Desktop use amd64 emulation.

For direct USB/JTAG access with `openFPGALoader`, the USB device must also be exposed to the container. On native Linux, for example, a development/test run can use:

```bash
docker run --rm -it \
  --platform linux/amd64 \
  --network host \
  --privileged \
  -v /dev/bus/usb:/dev/bus/usb \
  -v "$PWD:/workspace" \
  ghcr.io/nobukoba/container-hul-common-lib-amaneq-soft-first-trial:latest
```

`--privileged` is convenient for hardware testing but grants broad device access. Use a narrower device mapping when the required USB device node is known.

#### Windows

Install Docker Desktop for Windows and use Linux containers. Docker Desktop uses the WSL 2 backend by default for most Windows users.

WSL 2 must be enabled on Windows before Docker Desktop can use the WSL 2 backend. If WSL is not installed, open PowerShell as Administrator and run:

```powershell
wsl --install
```

Restart Windows if requested. New WSL installations created with `wsl --install` use WSL 2 by default.

You can check the installed WSL version with:

```powershell
wsl --version
```

Then open PowerShell in the directory you want to use as your workspace.

Pull the latest image:

```powershell
docker pull --platform linux/amd64 ghcr.io/nobukoba/container-hul-common-lib-amaneq-soft-first-trial:latest
```

Run the container:

```powershell
docker run --rm -it --platform linux/amd64 --network host -v "${PWD}:/workspace" ghcr.io/nobukoba/container-hul-common-lib-amaneq-soft-first-trial:latest
```

The current PowerShell directory is mounted at `/workspace` in the container, and the container starts in `/workspace`.

On Windows, `--network host` requires host networking to be enabled in Docker Desktop. Its behavior differs from native Linux host networking. USB/JTAG passthrough also requires additional host-side setup, so native Linux is recommended for direct HUL/AMANEQ and FPGA-programmer access.

### Apptainer / Singularity

Download the latest SIF image:

```bash
curl -L -O \
  https://github.com/nobukoba/container-hul-common-lib-amaneq-soft-first-trial/releases/download/latest/container-hul-common-lib-amaneq-soft-first-trial.sif
```

Run it from the directory you want to use as your workspace:

```bash
apptainer shell \
  --bind "$PWD:/workspace" \
  container-hul-common-lib-amaneq-soft-first-trial.sif
```

or Singularity:

```bash
singularity shell \
  --bind "$PWD:/workspace" \
  container-hul-common-lib-amaneq-soft-first-trial.sif
```

The current host directory (`$PWD`) is mounted at `/workspace`.

## Quick command checks

Inside the container:

```bash
openFPGALoader --version
mpc-mpcx-ip-reader --help
sitcp-sitcpxg-ip-reader --help
```

For example, to inspect a SiTCP device:

```bash
mpc-mpcx-ip-reader 192.168.2.161
```

The SiTCP utilities use RBCP UDP port `4660` and a default timeout of `3` seconds unless overridden by command-line options.

## Container layout

Important paths inside the container are:

```text
/opt/spadi/bin
/opt/spadi/include
/opt/spadi/lib
/opt/spadi/lib64
/opt/spadi/share
/opt/spadi/src
/workspace
```

`/opt/spadi` contains the installed software. `/workspace` is the user workspace and is normally bound to the current host directory (`$PWD`).

Source trees are retained under `/opt/spadi/src`, including `hul-common-lib`, `amaneq-soft`, `openFPGALoader`, and `sitcp-sitcpxg-mpc-mpcx-ip-utility-first-trial`.

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
image:     ghcr.io/nobukoba/container-hul-common-lib-amaneq-soft-first-trial:latest
platform:  linux/amd64
workspace: $PWD -> /workspace
network:   host
```

In another terminal, enter the running container with:

```bash
./login-docker-container.sh
```

The image, platform, and workspace directory can be overridden when needed:

```bash
IMAGE=container-hul-common-lib-amaneq-soft-first-trial:latest ./run-docker-container.sh
PLATFORM=linux/amd64 ./run-docker-container.sh
WORKSPACE_DIR=/path/to/project ./run-docker-container.sh
```

### Build locally

```bash
./build-docker-image.sh
```

The local build targets `linux/amd64` by default and creates both a UTC timestamped tag and `latest`:

```text
container-hul-common-lib-amaneq-soft-first-trial:YYYYMMDD-HHMMutc
container-hul-common-lib-amaneq-soft-first-trial:latest
```

Build parallelism can be changed with `NPROC`:

```bash
NPROC=8 ./build-docker-image.sh
```

The Dockerfile exposes source-ref build arguments for all source-built packages:

```text
HUL_COMMON_LIB_REF
AMANEQ_SOFT_REF
OPENFPGALOADER_REF
SITCP_IP_UTILITY_REF
```

Their defaults are the upstream development branches currently specified in the Dockerfile.

### Published images and tags

GitHub Actions publishes the GHCR image as `linux/amd64` with both:

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
