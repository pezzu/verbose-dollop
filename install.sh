#!/bin/bash

function ensure_not_root() {
    if [ "$EUID" -eq 0 ]
        then echo "This script cannot be run as root"
        exit 1
    fi
}

function authorize_sudo() {
    sudo -v || exit 1
}

function prepare_machine() {
    echo "Installing required packages"
    sudo -n apt -q -qq update -y
    sudo -n apt -q -qq install -y python3 python3-pip python3-venv

    echo "Installing Ansible"
    sudo -n apt-add-repository --yes --no-update ppa:ansible/ansible
    sudo -n apt -q -qq install -y ansible
}

function install_requirements () {
    echo "Installing requirements"
    ansible-galaxy install -r requirements.yml
}

function run_playbook() {
    echo "Running playbook"
    ansible-playbook ./playbook.yml --extra-vars "@./defaults/main.yml"
}

ensure_not_root
authorize_sudo
prepare_machine
install_requirements
run_playbook
