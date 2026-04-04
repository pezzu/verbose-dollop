#!/usr/bin/env bash

set -euo pipefail

function is_interactive() {
    [[ -t 0 && -t 1 ]]
}

function ensure_not_root() {
    if [ "$EUID" -eq 0 ]
    then echo "This script cannot be run as root"
        exit 1
    fi
}

function authorize_sudo() {
    if sudo -n -v 2>/dev/null
    then
        return
    fi

    if is_interactive
    then
        sudo -v
        return
    fi

    echo "Sudo credentials are required for the package installation step."
    echo "Run './install.sh' in an interactive terminal, or pre-authorize sudo in the same session."
    exit 1
}

function prepare_machine() {
    echo "Installing required packages"
    sudo -n apt -q -qq update -y
    sudo -n apt -q -qq install -y python3 python3-pip

    echo "Installing ansible"
    sudo -n apt-add-repository --yes --no-update ppa:ansible/ansible
    sudo -n apt -q -qq install -y ansible
}

function install_requirements () {
    echo "Installing requirements"
    ansible-galaxy install -r requirements.yml
}

function run_playbook() {
    local -a playbook_args=("./playbook.yml")

    echo "Running playbook"

    if ! ansible localhost -i localhost, -c local -m ansible.builtin.command -a true -b >/dev/null 2>&1
    then
        if is_interactive
        then
            playbook_args+=(--ask-become-pass)
        else
            echo "Ansible could not reuse sudo credentials for become in this non-interactive session."
            echo "Run './install.sh' in an interactive terminal, or configure passwordless sudo for Ansible tasks."
            exit 1
        fi
    fi

    ansible-playbook "${playbook_args[@]}"
}

ensure_not_root
authorize_sudo
prepare_machine
install_requirements
run_playbook
