#!/bin/bash 

# setup-new-inventory.sh
# Sets up a new inventory structure for ansible-playbooks

source setup-scripts/ansible-setup-vars

ANSIBLE_INVENTORIES=("production" "testing")

for inv in "${ANSIBLE_INVENTORIES[@]}"; do
    echo "Creating inventory dir: ${ANSIBLE_INVENTORY_PATH}/${inv}"
    mkdir -p ${ANSIBLE_INVENTORY_PATH} \
         ${ANSIBLE_INVENTORY_PATH}/${inv} \
         ${ANSIBLE_INVENTORY_PATH}/${inv}/host_vars \
         ${ANSIBLE_INVENTORY_PATH}/${inv}/group_vars
    
    touch ${ANSIBLE_INVENTORY_PATH}/${inv}/hosts
done
