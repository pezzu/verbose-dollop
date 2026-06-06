# devtools

Install container runtimes: Docker CE and Podman. Includes language
toolchains: Rustup, Go, and nvm, plus terminal AI coding agents.

## Components

### Docker CE

Installs the official Docker CE packages from the Docker apt repository:

- `docker-ce` — Docker engine
- `docker-ce-cli` — Docker CLI
- `docker-ce-rootless-extras` — rootless mode support
- `containerd.io` — container runtime
- `docker-buildx-plugin` — multi-platform image builder
- `docker-compose-plugin` — Compose V2 CLI plugin

### Podman

Installs [Podman](https://podman.io) from the system apt repository.

When `devtools_podman.docker_bindings: true`, also installs:

- `podman-docker` — drop-in `docker` CLI shim
- `docker-compose` — Compose compatibility layer

### Rustup

Installs [rustup](https://rustup.rs) via Homebrew and initialises the stable
Rust toolchain (`rustup default stable`). The rustup binary is keg-only and
lives at `~/.linuxbrew/opt/rustup/bin/rustup`; add `~/.cargo/bin` to `$PATH`
in dotfiles to use `cargo`, `rustc`, and other Rust toolchain binaries.

### Go

Installs [Go](https://go.dev) via Homebrew (`brew install go`), providing the
latest stable Go toolchain. Add the Homebrew-managed Go binary directory to
`$PATH` in dotfiles to use `go`, `gofmt`, and other Go toolchain binaries.

### nvm

Installs [nvm](https://github.com/nvm-sh/nvm) (Node Version Manager) via the
official install script. The task checks the installed version against the
latest GitHub release tag and re-runs the script only when an upgrade is
available. The install script writes the required sourcing block to `~/.zshrc`
automatically.

### GitHub CLI (gh)

Installs [gh](https://cli.github.com) via Homebrew. 

### OpenCode

Installs [OpenCode](https://opencode.ai) via Homebrew (`brew install opencode`).
OpenCode is an AI coding agent built for the terminal.

### Fabric AI

Installs [Fabric](https://github.com/danielmiessler/fabric) via Homebrew (`brew install fabric-ai`).
Fabric is an open-source framework for augmenting humans using AI. It provides a modular,
prompt-based system for piping text through AI patterns from the command line. The Homebrew
package installs the binary as `fabric-ai`.

### Pi Coding Agent

Installs [Pi Coding Agent](https://pi.dev) via the official installer script
(`curl -fsSL https://pi.dev/install.sh | sh`).

The role ensures Homebrew `node` is installed first so the installer can run
non-interactively.

### uv

Installs [uv](https://docs.astral.sh/uv/) via Homebrew (`brew install uv`).
uv is an extremely fast Python package and project manager, written in Rust.
It provides both the `uv` and `uvx` binaries.

## Role Variables

| Variable | Default | Description |
|---|---|---|
| `devtools_podman.docker_bindings` | `false` | Install Docker-compatible shims for Podman |

## License

MIT

## Author

Peter Sukhenko
