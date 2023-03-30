# ansible

Install multiple version of Ansible with `virtualenv` alongside
Ansible Collections, `ansible-lint` and `yamllint`.

## Overview

This project contains a set of Makefiles that allow installing and
using different versions of Ansible and Ansible Collections.  Each
Asnible version is installed into

```
~/.local/virtualenv/ansible-<version>
```

and each version's Collections are installed into

```
~/.ansible/collections-<version>
```

In addition, the Makefiles in the below directories do the following:

* `yamllint`: symlink the project's `yamllint` config file to
  `~/.config/yamllint`
* `ansible-lint`: symlink the project's `ansible-lint` config file to
  `~/.ansible-lint`
* `roles`: provide a `Makefile` to facilitate linting of Yaml &
  Ansible code as well as creation of "scaffolding" playbooks

## Usage

### Install Ansible etc.

To install Ansible, Ansible Collections and config files for
`yamllint` and `ansible-lint` simply run

```
make all
```

The versions of Ansible to be installed are determined by this
`Makefile` variable:

```
ANSIBLE_VERSIONS
```

The order of version numbers is imporatant: the one listed last is
considered the "default".  This version is used to set the
`~/.ansible.cfg` symlink; for example, Ansible 5.9.0 will be symlinked
to

```
<repository clone dir>/ansible-5.9.0.cfg
```

### Switch between installed Ansible versions

Switching to a particular Ansible version is done in 2 steps:

1. Source `~/.local/virtualenv/ansible-<version>/bin/activate` from
   within your shell
2. Make sure `~/.asnible.cfg` points to the correct version of config
   file inside the cloned directory by removing `~/.ansible.cfg`
   (after making sure it is indeed a symlink) and running `ln -s
   <repository clone dir>/ansible-<version>.cfg ~/.ansible.cfg`

Step 2 is particularly important as each config file has a
version-specific `collections_path`, e.g.

```
collections_path = ~/.ansible/collections-5.9.0
```

### Add new version of Ansible

1. Edit `Makefile` and set `ANSIBLE_VERSIONS`
2. Edit `collections/Makefile` and set `ANSIBLE_VERSIONS`
3. Create requirements file for Ansible named
   `requirements-ansible-<version>.txt` by copying an existing
   requirements file and changing `ansible==<version>` accordingly
4. Create requirements file for Ansible collections named
   `collections/requirements-collections-<version>.yml` by copying
   an existing requirements file and changing all references to
   Ansible version with `version`
5. Create Ansible config file `ansible-<version>.cfg` by copying an
   existing file and updating all references to Ansible version to `version`
6. Run `make all`

## Components

### Collections

The `collections` subdirectory contains a `Makefile` that allows for
installing and removing Ansible Collections.  It supports 2 targets:

1. `make install` - install collections to
   `~/.ansible/collections-<version>`
2. `make uninstall` - remove previously installed collections

### ansible-lint

The `Makefile` in the `ansible-lint` subdirectory supports 1 target:

1. `make install` - symlink `ansible-lint` config file to `~/.ansible-lint.yml`

### yamllint

The `Makefile` in the `yamllint` subdirectory supports 1 target:

1. `make install` - symlink `yamllint` config file to `~/.local/config/yamllint`

### roles

The `roles` subdirectory contains a `Makefile` one might find helpful
during Ansible role development.  It could be either symlinked or
copied to the directory containing roles and then used as

```
make <role>
```

where `<role>` is actually a directory containing the role being
developed.  The `Makefile` will then

1. Run `yamllint` on the role's Yaml file
2. Run `ansible-lint` on the role itself
3. Create a "scaffolding" playbook in `../playbooks` (this can be
   overridden with `PLAYBOOKS_DIR=...`)
