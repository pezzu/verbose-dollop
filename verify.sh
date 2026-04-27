#!/usr/bin/env bash

set -euo pipefail

export PATH="$HOME/.local/bin:/home/linuxbrew/.linuxbrew/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"

# ---------------------------------------------------------------------------
# system role — apt packages
# ---------------------------------------------------------------------------

echo "==> git"
git --version

echo "==> curl"
curl --version

echo "==> jq"
jq --version

echo "==> fzf"
fzf --version

echo "==> ripgrep"
rg --version

echo "==> tmux"
tmux -V

echo "==> stow"
stow --version

echo "==> zoxide"
zoxide --version

echo "==> cloc"
cloc --version

echo "==> lsd"
lsd --version

echo "==> ffmpeg"
ffmpeg -version

echo "==> graphviz"
dot -V

echo "==> imagemagick"
convert --version

echo "==> procps"
ps --version

echo "==> unzip"
unzip -v

echo "==> entr"
command -v entr

echo "==> lrzsz"
command -v rz

echo "==> zssh"
command -v zssh

echo "==> xclip"
command -v xclip

echo "==> wrk"
command -v wrk

echo "==> ffmpegthumbnailer"
command -v ffmpegthumbnailer

echo "==> unar"
command -v unar

echo "==> build-essential (gcc)"
gcc --version

# ---------------------------------------------------------------------------
# system role — fd and bat compatibility symlinks
# ---------------------------------------------------------------------------

echo "==> fd symlink"
fd --version

echo "==> bat symlink"
bat --version

# ---------------------------------------------------------------------------
# system role — Homebrew
# ---------------------------------------------------------------------------

echo "==> brew"
brew --version

# ---------------------------------------------------------------------------
# system role — gah
# ---------------------------------------------------------------------------

echo "==> gah"
gah version

# ---------------------------------------------------------------------------
# system role — neovim
# ---------------------------------------------------------------------------

echo "==> nvim"
nvim --version

# ---------------------------------------------------------------------------
# system role — yazi
# ---------------------------------------------------------------------------

echo "==> yazi"
yazi --version

# ---------------------------------------------------------------------------
# system role — zsh / Oh My Zsh
# ---------------------------------------------------------------------------

echo "==> zsh"
zsh --version

echo "==> oh-my-zsh directory"
test -d ~/.oh-my-zsh

# ---------------------------------------------------------------------------
# devtools role — Docker
# ---------------------------------------------------------------------------

echo "==> docker"
docker --version

# ---------------------------------------------------------------------------
# devtools role — Podman
# ---------------------------------------------------------------------------

echo "==> podman"
podman --version

# ---------------------------------------------------------------------------
# devtools role — Rust
# ---------------------------------------------------------------------------

echo "==> rustup"
rustup --version

# ---------------------------------------------------------------------------
# devtools role — Go
# ---------------------------------------------------------------------------

echo "==> go"
go version

# ---------------------------------------------------------------------------
# devtools role — nvm
# ---------------------------------------------------------------------------

echo "==> nvm"
# shellcheck source=/dev/null
source ~/.nvm/nvm.sh && nvm --version

# ---------------------------------------------------------------------------
# devtools role — GitHub CLI
# ---------------------------------------------------------------------------

echo "==> gh"
gh --version

# ---------------------------------------------------------------------------
# devtools role — opencode
# ---------------------------------------------------------------------------

echo "==> opencode"
opencode --version

# ---------------------------------------------------------------------------
# devtools role — uv / uvx
# ---------------------------------------------------------------------------

echo "==> uv"
uv --version

echo "==> uvx"
uvx --version

# ---------------------------------------------------------------------------
# devops role — Kubernetes tooling
# ---------------------------------------------------------------------------

echo "==> kubectl"
kubectl version --client

echo "==> minikube"
minikube version

echo "==> helm"
helm version

echo "==> kubectx"
kubectx --version

echo "==> kubens"
kubens --version

echo "==> k9s"
k9s version

echo "==> lfk"
lfk --version

# ---------------------------------------------------------------------------
# devops role — HashiCorp tooling
# ---------------------------------------------------------------------------

echo "==> tfenv"
tfenv --version

echo "==> consul"
consul --version

echo "==> nomad"
nomad --version

echo "==> packer"
packer --version

echo "==> vagrant"
vagrant --version

# ---------------------------------------------------------------------------
# devops role — cloud CLIs
# ---------------------------------------------------------------------------

echo "==> aws"
aws --version

echo "==> az"
az --version

echo "==> oci"
oci --version

# ---------------------------------------------------------------------------
# devops role — additional tools
# ---------------------------------------------------------------------------

echo "==> dive"
dive --version

echo "==> docker-slim"
docker-slim --version

echo "==> hey"
command -v hey

echo ""
echo "All checks passed."
