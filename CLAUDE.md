# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A set of Makefiles (no application code) that install and manage multiple
side-by-side versions of Ansible using `virtualenv`, plus per-version Ansible
Collections, and shared `yamllint`/`ansible-lint` configs. There is no
build/compile step and no test suite — "correctness" means the Makefiles
produce the right virtualenvs, symlinks, and config files.

## Layout and how the pieces fit together

- Top-level `Makefile` — creates a `virtualenv` per version in
  `ANSIBLE_VERSIONS` under `$(VENV_BASE)` (`~/.local/venv/ansible-<version>`),
  installing from `requirements-ansible-<version>.txt` into each. Also
  symlinks `~/.ansible.cfg` to `ansible-<version>.cfg` for the *default*
  version, and creates `~/.ansible` + `~/.ansible/log`.
- `ansible-<version>.cfg` — one Ansible config file per version, each pointing
  `collections_path` at that version's own collections dir
  (`~/.ansible/collections-<version>`). `collections_on_ansible_version_mismatch = error`
  is set deliberately so an Ansible version can never load another version's
  collections.
- `requirements-ansible-<version>.txt` — pip requirements for that version's
  virtualenv (pins `ansible==<version>` plus tooling like `ansible-lint`,
  `yamllint`, `molecule`, `boto3`, etc).
- `collections/` — has its own `Makefile` (variables `ANSIBLE_HOME`,
  `ANSIBLE_VERSIONS`, `VENV_BASE` are inherited from the top-level Makefile
  when invoked via `$(MAKE) -C collections`, but default sensibly on their
  own too). For each version it activates that version's virtualenv and runs
  `ansible-galaxy collection install -r requirements-collections-<version>.yml
  -p ~/.ansible/collections-<version>`. Requirements files:
  `collections/requirements-collections-<version>.yml`.
- `ansible-lint/` — `make install` symlinks `ansible-lint/ansible-lint.yml` to
  `~/.config/ansible-lint.yml`.
- `yamllint/` — `make install` symlinks `yamllint/yamllint.yml` to
  `~/.config/yamllint/config`.
- `roles/` — a standalone `Makefile` meant to be copied/symlinked into a
  separate directory that contains Ansible roles (one subdirectory per role).
  `make <role-name>` runs `yamllint` on the role's YAML, runs `ansible-lint`
  on the role, and generates a scaffold playbook in `../playbooks` (pulling
  the playbook's `name:` from the role's `meta/main.yml` `description:`).

## The versioning convention (critical to understand before editing)

Every version-specific file follows the pattern `*-<ansible-version>.*`, and
these four must be kept in lockstep for a given version:

1. `ansible-<version>.cfg`
2. `requirements-ansible-<version>.txt`
3. `collections/requirements-collections-<version>.yml`
4. The version string listed in `ANSIBLE_VERSIONS` in both the top-level
   `Makefile` and `collections/Makefile`.

**`ANSIBLE_VERSIONS` order matters**: it's a space-separated list, and
`ANSIBLE_DEFAULT_VERSION` is derived as `$(lastword $(ANSIBLE_VERSIONS))`.
Whichever version is listed *last* becomes the default (`~/.ansible.cfg`
symlink target). Currently only one version (`14.0.0`) is listed; historical
`.cfg`/requirements files for older versions remain in the repo as an
archive/reference even though they're no longer installed by default.

## Adding a new Ansible version

1. Add the version to `ANSIBLE_VERSIONS` in the top-level `Makefile` (put it
   last if it should become the new default).
2. Add the same version to `ANSIBLE_VERSIONS` in `collections/Makefile`.
3. Copy the most recent `requirements-ansible-<old>.txt` to
   `requirements-ansible-<new>.txt` and bump the `ansible==<version>` pin.
4. Copy `collections/requirements-collections-<old>.yml` to
   `collections/requirements-collections-<new>.yml` and update any
   version-specific comments/refs.
5. Copy `ansible-<old>.cfg` to `ansible-<new>.cfg` and update
   `collections_path` to `~/.ansible/collections-<new-version>`.
6. Run `make all` (see below).

## Common commands

Run from the repo root unless noted:

```
make all                 # install everything: venvs, collections, yamllint & ansible-lint configs
make install             # create virtualenvs for ANSIBLE_VERSIONS and set up ~/.ansible.cfg symlink
make collections         # install Ansible Collections into each version's venv
make yamllint             # symlink yamllint config
make ansible-lint         # symlink ansible-lint config
make uninstall            # remove the installed virtualenvs
make reinstall            # uninstall then install
make clean                # remove backup/temp files (*~, .*~, ...) in this dir and subdirs
make help                 # list targets (also the default goal)
```

Sub-Makefiles support the same idioms independently, e.g.:

```
make -C collections install    # install/refresh collections only
make -C collections uninstall
make -C ansible-lint install
make -C yamllint install
```

In a directory of Ansible roles where `roles/Makefile` has been copied in:

```
make <role-name>         # yamllint + ansible-lint the role, generate scaffold playbook
```

## Switching between installed Ansible versions (manual, two steps)

1. `source ~/.local/venv/ansible-<version>/bin/activate`
2. Point `~/.ansible.cfg` at the matching config: remove the existing symlink
   and run `ln -s <repo>/ansible-<version>.cfg ~/.ansible.cfg`. This step
   matters because each `.cfg` has a version-specific `collections_path`, and
   `collections_on_ansible_version_mismatch = error` will hard-fail if the
   active Ansible and the linked collections path don't match.

## Notes

- `ANSIBLE_CONFIG`/`ANSIBLE_HOME`/`VENV_BASE`/etc. are exported from the
  top-level `Makefile` so they're visible to sub-makes invoked via `$(MAKE)
  -C <dir>`, but each sub-Makefile also defines its own defaults (`?=`) so it
  still works if run standalone.
