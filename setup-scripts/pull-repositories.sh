#!/bin/bash
# This script clones a number of ansible playbooks and roles.
REPOSITORY="https://github.com/mfallone"
# Change dir to roles path. Defined in `setup.sh` script.
cd ${ANSIBLE_ROLES}

# Roles
git clone ${REPOSITORY}/ansible-role-common.git
git clone ${REPOSITORY}/ansible-role-control-machine.git
git clone ${REPOSITORY}/ansible-role-vagrant.git
