#!/bin/bash 

# setup-new-inventory.sh
# Sets up a new inventory structure for ansible-playbooks

source setup-scripts/ansible-setup-vars

ANSIBLE_INVENTORIES=("production" "testing")

for inv in "${ANSIBLE_INVENTORIES[@]}"; do
    if [ -d ${ANSIBLE_INVENTORY_PATH}/${inv} ]; then
        echo "Skipping, '${inv}' inventory dir already exists"
    else
        echo "Creating inventory dir: ${ANSIBLE_INVENTORY_PATH}/${inv}"
        mkdir -p ${ANSIBLE_INVENTORY_PATH} \
             ${ANSIBLE_INVENTORY_PATH}/${inv} \
             ${ANSIBLE_INVENTORY_PATH}/${inv}/host_vars \
             ${ANSIBLE_INVENTORY_PATH}/${inv}/group_vars \
             ${ANSIBLE_INVENTORY_PATH}/${inv}/host_vars/localhost
        
        touch ${ANSIBLE_INVENTORY_PATH}/${inv}/hosts.yaml \
              ${ANSIBLE_INVENTORY_PATH}/${inv}/host_vars/localhost/vars
        
        echo "ansible_connection: local" >> ${ANSIBLE_INVENTORY_PATH}/${inv}/host_vars/localhost/vars
        echo "setup_user: $(whoami)" >> ${ANSIBLE_INVENTORY_PATH}/${inv}/host_vars/localhost/vars    

        ACM_HOSTNAME=$(hostname)
        mkdir "${ANSIBLE_INVENTORY_PATH}/${inv}/host_vars/${ACM_HOSTNAME}"
        echo "
all:
  hosts:
    ${ACM_HOSTNAME}
" > "${ANSIBLE_INVENTORY_PATH}/${inv}/hosts.yaml"

    fi
done
