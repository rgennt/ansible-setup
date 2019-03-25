#!/bin/bash

# setup-new-role.sh

# This script will create a new ansible role directory 
# defined in $ANSIBLE_ROLE_PATH and populate it with some skeleton files

# Setting a static role path in the parent folder of ansible-setup

# Create the following roles sub directories
# * tasks - contains the main list of tasks to be executed by the role.
# * handlers - contains handlers, which may be used by this role or even anywhere outside this role.
# * defaults - default variables for the role (see Using Variables for more information).
# * vars - other variables for the role (see Using Variables for more information).
# * files - contains files which can be deployed via this role.
# * templates - contains templates which can be deployed via this role.
# * meta - defines some meta data for this role. See below for more details.

if [ -z "${ANSIBLE_ROLE_PATH}" ]; then
    echo "variable ANSIBLE_ROLE_PATH is empty and must be set, using default of parent dir"
    ANSIBLE_ROLE_PATH="../ansible-roles"
fi

# Create the ansible_role_path directory as required
if [ ! -e ${ANSIBLE_ROLE_PATH} ]; then
    mkdir -p ${ANSIBLE_ROLE_PATH}
fi

# Check if a new role name was provided
if [ "$#" -ne 1 ]; then
    echo "No role name received.  Re-run with the first argument the name of the new role"
else
    # Check if the directory exists before creating
    if [ -d $1 ]; then
        echo "Ansible role directory exists. Not recreating."
    else
        mkdir -p "${ANSIBLE_ROLE_PATH}/$1" \
                 "${ANSIBLE_ROLE_PATH}/$1/tasks" \
                 "${ANSIBLE_ROLE_PATH}/$1/vars" \
                 "${ANSIBLE_ROLE_PATH}/$1/defaults" \
                 "${ANSIBLE_ROLE_PATH}/$1/files" \
                 "${ANSIBLE_ROLE_PATH}/$1/templates" \
                 "${ANSIBLE_ROLE_PATH}/$1/handlers" \
                 "${ANSIBLE_ROLE_PATH}/$1/meta"                 
    fi
fi
