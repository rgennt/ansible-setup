# README - ansible-setup

This repository is used to download and set up the local environment for use
with Ansible.

This is adapted from the official Ansible [Installation Guide](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html).

Clone this repository into a root andible path and run `setup-scripts/setup.sh` as a user with elevated privileges.

`setup.sh` calls `install-ansible.sh` as an elevated user to:

* Install the Debian/Ubuntu Ansible PPA
* Install Ansible through `apt`

`setup.sh` will then create the default paths, which can be overidden:

* Create Ansible inventory (`ANSIBLE_INVENTORY`) and role (`ANSIBLE_ROLE`) paths
* Generate a local config (`./ansible.cfg`) file if it doesn't already sexist

For additional setup steps, add the [ansible-role-control-machine](https://github.com/mfallone/ansible-role-control-machine) role, check the configuration and run `example-playbook.yaml`.
