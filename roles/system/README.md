# system

Baseline system setup: apt packages, shell, editor, fonts, and keyboard configuration.

## Components

### Apt packages

Installs a curated set of packages via apt. Fully configurable via `system_packages`.

Default packages include: `bat`, `build-essential`, `cloc`, `curl`, `entr`, `fd-find`, `ffmpeg`,
`ffmpegthumbnailer`, `file`, `git`, `graphviz`, `imagemagick`, `jq`, `libpoppler-dev`,
`lsd`, `lrzsz`, `procps`, `ripgrep`, `stow`, `unar`, `xclip`, `wrk`, `zoxide`, `zssh`.

Also creates compatibility symlinks for `fd` and `bat` in `~/.local/bin/`.

### zsh + Oh My Zsh

Installs `zsh` via apt, installs [Oh My Zsh](https://ohmyz.sh) if not already present, and sets
`zsh` as the default shell.

### Neovim

Installs [Neovim](https://neovim.io) via Homebrew (`neovim` formula).

### Nerd Fonts

Installs a configurable selection of [Nerd Fonts](https://www.nerdfonts.com) by shallow-cloning
the `ryanoasis/nerd-fonts` repository at the configured version tag and running the upstream
`install.sh` script for each selected font.

Fonts and version are configurable via `system_nerd_fonts`.

### Homebrew

Installs or upgrades [Homebrew](https://brew.sh) by checking the current version against the
latest GitHub release and running the official install script when needed.

### tmux

Installs [tmux](https://github.com/tmux/tmux/wiki) via Homebrew (`tmux` formula).

### GAH

Installs or upgrades [GAH](https://github.com/get-gah/gah) using the same version-check pattern.

### Yazi

Installs [Yazi](https://github.com/sxyazi/yazi) via Homebrew. A blazing fast terminal file
manager written in Rust, based on async I/O.

### Mosh

Installs [Mosh](https://mosh.org) via Homebrew (`mosh` formula). Mobile Shell
provides a roaming-friendly remote terminal session that survives intermittent
connectivity and IP changes.

### direnv

Installs [direnv](https://direnv.net) via Homebrew. Automatically loads and unloads environment
variables depending on the current directory, enabling per-project environment configuration.

### fzf

Installs [fzf](https://github.com/junegunn/fzf) via Homebrew (`fzf` formula). A command-line
fuzzy finder for interactive filtering of any list.

### herdr

Installs [herdr](https://github.com/ogulcancelik/herdr) via Homebrew (`herdr` formula). An
agent multiplexer that lives in your terminal.

### Keyboard

Swaps CapsLock and Escape keys by updating `/etc/default/keyboard`
(`XKBOPTIONS="caps:swapescape"`).

## Role Variables

| Variable | Default | Description |
|---|---|---|
| `system_local_bin` | `~/.local/bin/` | Directory for local user binaries and symlinks |
| `system_packages` | *(see defaults/main.yml)* | List of apt packages to install |
| `system_nerd_fonts.version` | `v3.3.0` | Nerd Fonts release tag to install |
| `system_nerd_fonts.fonts` | *(see defaults/main.yml)* | List of font names to install |

## License

MIT

## Author

Peter Sukhenko
