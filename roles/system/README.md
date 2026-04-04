# system

Baseline system setup: apt packages, shell, editor, fonts, and keyboard configuration.

## Components

### Apt packages

Installs a curated set of packages via apt. Fully configurable via `system_packages`.

Default packages include: `bat`, `build-essential`, `cloc`, `curl`, `entr`, `fd-find`, `ffmpeg`,
`ffmpegthumbnailer`, `file`, `fzf`, `git`, `graphviz`, `imagemagick`, `jq`, `libpoppler-dev`,
`lsd`, `lrzsz`, `procps`, `ripgrep`, `stow`, `tmux`, `unar`, `xclip`, `wrk`, `zoxide`, `zssh`.

Also creates compatibility symlinks for `fd` and `bat` in `~/.local/bin/`.

### zsh + Oh My Zsh

Installs `zsh` via apt, installs [Oh My Zsh](https://ohmyz.sh) if not already present, configures
plugins in `~/.zshrc`, and sets `zsh` as the default shell.

Plugins are configurable via `system_ohmyzsh_plugins` (defaults: `git`, `vi-mode`).

### Neovim

Installs the latest [Neovim](https://neovim.io) AppImage to `~/.local/bin/nvim`. Automatically
checks the GitHub latest release and upgrades if a newer version is available.

### Nerd Fonts

Installs a configurable selection of [Nerd Fonts](https://www.nerdfonts.com) by shallow-cloning
the `ryanoasis/nerd-fonts` repository at the configured version tag and running the upstream
`install.sh` script for each selected font.

Fonts and version are configurable via `system_nerd_fonts`.

### Homebrew

Installs or upgrades [Homebrew](https://brew.sh) by checking the current version against the
latest GitHub release and running the official install script when needed.

### GAH

Installs or upgrades [GAH](https://github.com/get-gah/gah) using the same version-check pattern.

### Keyboard

Swaps CapsLock and Escape keys by updating `/etc/default/keyboard`
(`XKBOPTIONS="caps:swapescape"`).

## Role Variables

| Variable | Default | Description |
|---|---|---|
| `system_local_bin` | `~/.local/bin/` | Directory for local user binaries and symlinks |
| `system_packages` | *(see defaults/main.yml)* | List of apt packages to install |
| `system_ohmyzsh_plugins` | `[git, vi-mode]` | Oh My Zsh plugins to enable in `~/.zshrc` |
| `system_nerd_fonts.version` | `v3.3.0` | Nerd Fonts release tag to install |
| `system_nerd_fonts.fonts` | *(see defaults/main.yml)* | List of font names to install |

## License

MIT

## Author

Peter Sukhenko
