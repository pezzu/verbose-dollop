# verbose-dollop

Ansible playbook to provision a development environment on a Debian-based system.

[![Checks](https://github.com/pezzu/verbose-dollop/actions/workflows/checks.yml/badge.svg)](https://github.com/pezzu/verbose-dollop/actions/workflows/checks.yml)

## Installation

```sh
./install.sh
```

## Roles

### System

Baseline system configuration and developer tooling. See [`roles/system`](roles/system/README.md).

- [x] apt packages: `bat`, `build-essential`, `cloc`, `curl`, `entr`, `fd-find`, `ffmpeg`, `fzf`, `git`,
  `graphviz`, `imagemagick`, `jq`, `lsd`, `ripgrep`, `stow`, `tmux`, `xclip`, `zoxide`, and more
- [x] zsh + [Oh My Zsh](https://ohmyz.sh) (configurable plugins)
- [x] [Neovim](https://neovim.io) — installed via Homebrew
- [x] [Nerd Fonts](https://www.nerdfonts.com) (configurable selection)
- [x] [Homebrew](https://brew.sh)
- [x] [GAH](https://github.com/get-gah/gah)
- [x] [Yazi](https://github.com/sxyazi/yazi) — terminal file manager
- [x] Keyboard: CapsLock ↔ Escape swap

### DevTools

Container runtimes and build tooling. See [`roles/devtools`](roles/devtools/README.md).

- [ ] Compilers / language runtimes
  - [x] gleam
  - [x] python
  - [x] [Go](https://go.dev) — Go programming language toolchain
  - [ ] nvm / Node.js
  - [x] [rustup](https://rustup.rs) — Rust toolchain installer
- [x] [Docker CE](https://docs.docker.com/engine/install/debian/) (engine, buildx, compose plugin)
- [x] [Podman](https://podman.io) (optional Docker-compatible bindings)
- [ ] GitHub tooling
  - [ ] [gh](https://cli.github.com) — GitHub CLI
  - [ ] [act](https://github.com/nektos/act) — run GitHub Actions locally

### DevOps

Infrastructure, cloud, and Kubernetes tooling. See [`roles/devops`](roles/devops/README.md).

- [x] Kubernetes
  - [x] [kubectl](https://kubernetes.io/docs/reference/kubectl/)
  - [x] [minikube](https://minikube.sigs.k8s.io)
  - [x] [helm](https://helm.sh)
- [x] HashiCorp
  - [x] [tfenv](https://github.com/tfutils/tfenv) (Terraform version manager)
  - [x] [consul](https://www.consul.io)
  - [x] [nomad](https://www.nomadproject.io)
  - [x] [packer](https://www.packer.io)
  - [x] [vagrant](https://www.vagrantup.com)
- [x] Cloud CLIs
  - [x] [AWS CLI](https://aws.amazon.com/cli/)
  - [x] [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/)
  - [x] [OCI CLI](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/cliconcepts.htm)
- [x] Tools
  - [x] [hey](https://github.com/rakyll/hey) — HTTP load generator
  - [x] [dive](https://github.com/wagoodman/dive) — Docker image inspector
  - [x] [mintoolkit](https://github.com/mintoolkit/mint) — container image minifier
