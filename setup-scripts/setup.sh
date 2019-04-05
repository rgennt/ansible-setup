#!/bin/bash

# This script must be run first on the intended Ansible control machine.

source "setup-scripts/ansible-setup-vars"

if [ ${EUID} -eq 0 ]; then
    echo "
    WARNING: Setting up ACM as root.  
    The Inventory and Roles directories will be owned by root, which may not be intended.
    
"
fi

sudo ./setup-scripts/install-ansible.sh

# Create Ansible roles and inventory directories
ANSIBLE_SUPPORT_PATHS=(${ANSIBLE_ROLES} ${ANSIBLE_INVENTORY_PATH})
for i in ${ANSIBLE_SUPPORT_PATHS[@]}; do
    echo "Creating directory ${i}"
    mkdir -p "${i}"
done

ANSIBLE_CONFIG_FILE="ansible.cfg"

if [ ! -e ${ANSIBLE_CONFIG_FILE} ]; then
    echo "Generating ${PWD}/${ANSIBLE_CONFIG_FILE}"
    
    echo "# generated ansible.cfg
[defaults]

inventory   = ${ANSIBLE_INVENTORY}
roles_path  = ${ANSIBLE_ROLES}

private_key_file = .ssh/ansible_id_ecdsa
" > ansible.cfg

fi

if [ -e ${ANSIBLE_ROLES} ]; then
    setup-scripts/pull-repositories.sh
fi


