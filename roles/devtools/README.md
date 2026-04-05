# devtools

Install container runtimes: Docker CE and Podman.

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

## Role Variables

| Variable | Default | Description |
|---|---|---|
| `devtools_podman.docker_bindings` | `false` | Install Docker-compatible shims for Podman |

## License

MIT

## Author

Peter Sukhenko
