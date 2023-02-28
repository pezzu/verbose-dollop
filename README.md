# verbose-dollop
Ansible script to magically setup new Pop!_OS/Ubuntu machine

[![CI status](https://github.com/pezzu/verbose-dollop/actions/workflows/ci.yml/badge.svg)](https://github.com/pezzu/verbose-dollop/actions/workflows/ci.yml)

## Installation
1. Adjust personal settings in defautls/main.yml
1. Run

```
sh -c "$(curl -fsSl https://raw.githubusercontent.com/pezzu/verbose-dollop/main/install.sh)"
```


## List of packages

 - [ ] [Ansible](roles/ansible/README.md)
 - [ ] [Code](roles/code/README.md)
 - [x] [git](roles/git/README.md)
 - [x] [Podman](roles/podman/README.md)
 - [x] [ZSH](roles/zsh/README.md)