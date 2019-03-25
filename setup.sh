#!/bin/bash

# This script must be run first on the intended Ansible control machine.

if [ ${EUID} -ne 0 ]; then
    echo "This script must be run as the root user"
    exit 1
fi

OS_DISTRO=$(lsb_release -i | awk '{ print $3 }' | tr '[:upper:]' '[:lower:]')

if [ ${OS_DISTRO} == 'ubuntu' ]; then
    # Update apt, install prerequisites.  
    # Install ansible ppa and install the ansible package.
    apt update
    apt install software-properties-common
    apt-add-repository --yes --update ppa:ansible/ansible
    apt install -y -f ansible
elif [ ${OS_DISTRO} == 'debian' ]; then
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367
    apt update
    apt install -y -f ansible
fi

ANSIBLE_BIN=$(which ansible)
if [ $? -ne 0 ]; then
    echo "Unable to find Ansible binary, something has gone wrong. Install manually"
fi

# Create Ansible roles and inventory directories
ANSIBLE_SUPPORT_PATHS=("ansible-roles" "ansible-inventory")
for i in ${ANSIBLE_SUPPORT_PATHS[@]}; do
    mkdir -p "../${i}"
done

