# README - ansible-setup

Ansible is used to simplify IT automation.  An Ansible Control Machine is 
configured to connect to other managed devices and automate various tasks.

This repository is meant to boot strap the installation and configuration of an 
ACM on a local host.  These instructions are adapted from the official 
Ansible [Installation Guide](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html).

After installation, the ACM can manage tasks on inventoried devices by connecting
to them (typically over SSH) and performing tasks.  In order to achieve this, 
the ACM needs a way to run privileged and unprivileged commands as necessary.

To ease integration and provided auditability, the ACM and inventoried hosts 
should have an additional _ansible-user_ account created that all ansible tasks 
should be run as and should have the ability to perform all tasks necessary, with 
little to no user input.

The _ansible-user_ can simply be the _root_ user, however this does not provide 
the auditability that may be required.

## Installation 

### Summary

1. Clone this repository.
2. Run `setup-scripts/setup.sh` as a user that can elevate privileges. (herein 
   known as _setup-user_)
3. Run `setup-scripts/setup-new-inventory.sh` to generate a default directory 
   structure and populate it with a `localhost` object.
4. Create password hashes for the _setup-user_ and _ansible-user_ accounts.

```bash
git clone https://github.com/mfallone/ansible-setup.git ./ansible
cd ansible
./setup-scripts/setup.sh
./setup-scripts/setup-new-inventory.sh
# See README - Next Steps
```

### Detailed Steps

Clone this repository into a new root ansible path and run `setup-scripts/setup.sh` 
as a user with elevated privileges.

`setup.sh` calls `install-ansible.sh` as an elevated user to:

* Install the Debian/Ubuntu Ansible PPA
* Install Ansible through `apt`

`setup.sh` will then create the default paths, which can be overidden or 
changed later:

* Create Ansible inventory (`ANSIBLE_INVENTORY`) and role (`ANSIBLE_ROLE`) paths
* Generate a local config (`./ansible.cfg`) file if it doesn't already exist.

For additional setup steps, add the [ansible-role-control-machine](https://github.com/mfallone/ansible-role-control-machine) 
role, check the configuration and run `example-playbook.yaml`.


## New Inventory

A helper script [`setup-new-inventory.sh`](./setup-scripts/setup-new-inventory.sh) 
is provided and should be run on newly created control machines.  The script will

* Create new `production` and `testing` inventory directories (which can be 
  overridden). 
  with `group_vars`, `host_vars` and `vars` files/folders.
* Create a new `localhost` directory with `vars` and `vault` files.
* Populate `vars` fiile with reasonable default values (i.e. `setup-user`) used 
  to continue setup.


## First Run Playbook

After the `localhost` inventory folder is created, a playbook must be run to finish 
configuration of the Ansible Control Machine.  This playbook is intended to 
be run by the same user that ran the setup script.  The final configuration 
steps include: 

* Create a new ansible user and group.
* Create a ssh_key for the ansible user.
* Grant elevated permissions to new account.
* Change ownership of the sensitive ansible vault files to the new account. (Optional)

A new `vault` file is should be created and put in the `host_vars/localhost` directory.
This file contains the hashed password of the new `ansible-user` that will run all
future plays.

During `setup-new-inventory.sh` a new file is created `group_vars/all/vars` containing
some default values that can be overridden as necessary and can be used by other roles including
the `ansible-user` which is defined in the `ansible-role-common` and `ansible-role-control-machine`
roles that were downloaded.

__To change the default vaults, edit `group_vars/all/vars`__

See the [ansible documentation](https://docs.ansible.com/ansible/latest/reference_appendices/faq.html#how-do-i-generate-crypted-passwords-for-the-user-module) for details on
how to generate the hash.  To quickly get going, run the python snippet to 
generate a hash.

```bash
NEW_USER_PASSWORD_HASH=$(python3 -c 'import crypt,getpass; print(crypt.crypt(getpass.getpass(), crypt.mksalt(crypt.METHOD_SHA512)))')
```

Store this hash in the `host_vars/localhost/vault`  file and set appropriate restrictions.

```bash
echo "
vault_new_user_password: \"${NEW_USER_PASSWORD_HASH}\"
" > ./inventory/production/host_vars/localhost/vault
```

Run the playbook to complete setup, this will prompt for a `SUDO` password.

```bash
ansible-playbook 00-setup-control-machine-playbook.yaml -K
```

The play will setup a new user and group, add that user to `sudoers.d` and grant
privilege elevation.


### Ansible-Vault (Optional)

Ansible Vault can be used to generate and store encrypted values.  To quickly
encrypt the above file, run the `ansible-vault encrypt` command and enter in a
password.

```bash
ansible-vault encrypt ./inventory/production/host_vars/localhost/vault
```

When using Ansible Vault, pass the `--ask-vault-pass` flag.

```bash
ansible-playbook 00-setup-control-machine-playbook.yaml -K --ask-vault-pass
```

-------------------------------------------------

## Adding new Hosts

There are a variety of ways to add new hosts.  To quickly define a set of variables
across the inventory, populate the `inventory/production/group_vars/all` folder.

Building on the previous work, to add new hosts add the hostname to the `host_vars`
folder path and to the `hosts.yaml` file in appropriate groups.

Create or modify `vars` and `vault` files in the `group_vars/all` or override for 
specific hosts by using the `host_vars` path (i.e. `host_vars/<hostname>`) with the following:

* `ansible_new_user_password` - The ansible user password hash
* `setup_ssh_password` - The ssh password when first connecting as the user

Customized `vars` file:

```yaml
ansible_new_user_password: "{{ vault_new_user_password }}"
setup_ssh_password: "{{ vault_setup_ssh_password }}"
```

* customized `vault` file

```bash
echo "
vault_new_user_password: \"${NEW_USER_PASSWORD_HASH}\"
vault_setup_ssh_password: \"<cluster password>\"
" >> ./inventory/production/group_vars/all/vault

echo "
vault_setup_ssh_password: \"<host password>\"
" > ./inventory/production/host_vars/hostname/vault
```

To complete setup of the new host, run the `01-setup-new-hosts.yaml` file.

_NOTE: The `ANSIBLE_HOST_KEY_CHECKING=False` flag should only be used when 
adding a host for the first time and you are willing to accept the key without
proper verification._

```
sudo su ansible-user -c "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook 01-setup-new-hosts.yaml --ask-vault-pass"
```

## Example Playbook

An example playbook named `99-whoami.yaml` is included in the repository.
This playbook is useful for testing connectivity to hosts and demonstrates 
privilege escalation.

Example use:

```
sudo su ansible-user -c "ansible-playbook 99-whoami.yaml"
```

