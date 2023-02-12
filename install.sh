#!/bin/bash

function check_root() {
    if [ "$EUID" -ne 0 ]
        then echo "Please run as root"
        exit
    fi
}

function prep_machine() {
    echo "Installing required packages"
    apt update -y
    apt install -y python3 python3-pip python3-venv

    echo "Installing Ansible"
    apt-add-repository --yes --update ppa:ansible/ansible
    apt install ansible -y
}

function run_playbook() {
    # echo "Installing requirements"
    # ansible-galaxy install -r requirements.yml

    echo "Running playbook"
    ansible-playbook ./playbook.yml
}

check_root
prep_machine
run_playbook
