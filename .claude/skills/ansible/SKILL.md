---
name: ansible
description:
  'Ansible playbook, role, and inventory development with best practices for
  IaC automation. Use when creating or modifying Ansible playbooks, roles,
  inventories, group_vars, or tasks. Covers YAML style, variable naming, role
  structure, idempotency, vault secrets, inventory organization, debugging,
  and this project''s three-area deployment architecture (vm-setup, sys-env-setup,
  db-setup). Also use when writing handlers, templates, or custom modules.'
---

# Ansible Development

Guidelines for writing, organizing, and running Ansible automation in this
infrastructure project.

## When to Use This Skill

- Creating or modifying playbooks, roles, tasks, or handlers
- Writing or restructuring inventory files and group_vars
- Adding or refactoring Ansible roles under `vm-setup/`, `sys-env-setup/`, or `db-setup/`
- Working with Ansible Vault for secrets
- Writing Jinja2 templates for managed configuration files
- Debugging playbook failures or connectivity issues
- Integrating Ansible with the cloud-init deployment pipeline

## Playbook & Task Style

### YAML Syntax

Always use native YAML key:value syntax -- never inline `key=value`:

```yaml
# CORRECT
- name: Install Apache packages
  ansible.builtin.yum:
    name: httpd
    state: latest

# WRONG -- inline args
- name: Install Apache packages
  yum: name=httpd state=latest
```

### Mandatory Practices

- **Always name plays, tasks, and blocks** -- names appear in output and logs
- **Always specify `state:`** -- even when it matches the module default
- **Use FQCN** -- `ansible.builtin.copy` not `copy`; `ansible.posix.seboolean` not `seboolean`
- **Use whitespace** -- blank line before each task/block for readability
- **Use comments** -- explain _why_, not just _what_
- **Use `block`/`rescue`** for error handling and rollback logic
- **Use** `true`/`false` for booleans (not `yes`/`no`).
- **Use** double quotes for strings.

### Module Selection

Prefer native modules over `command`/`shell`. If you must use `command` or
`shell`, add `changed_when` and `creates`/`removes` for idempotency:

```yaml
# CORRECT -- native module
- name: Create application user
  ansible.builtin.user:
    name: appuser
    state: present

# AVOID -- only when no module exists
- name: Run custom setup script
  ansible.builtin.command:
    cmd: /opt/setup.sh
    creates: /opt/.setup_done
  changed_when: false
```

### Mark Managed Files

Label template output as Ansible-managed to prevent accidental manual edits:

```jinja
# {{ ansible_managed | comment }}
```

## Variable Conventions

- **Descriptive names**: `apache_max_keepalive: 25`, not `a: 25`
- **Role-prefix variables**: `audit_log_format`, `hardening_ssh_permit_root`
- **Place variables strategically**: `defaults/main.yml` for overridable defaults,
  `vars/main.yml` for internal constants, `group_vars/` for environment/group config
- Avoid scattering variables across too many locations -- settle on a defined scheme

## Inventory Conventions

- **Human-readable names** with `ansible_host=`: `db1 ansible_host=10.1.2.3`
- **Group by function**: `[APP]`, `[DB]`, `[DMZ]` -- matches this project's taxonomy
- **Separate environments** via distinct inventory files or directories
- **Use dynamic inventory** where possible to stay in sync with cloud state
- **Parent groups with `[SCC:children]`** for cross-cutting selections

## Role Structure

Follow the standard layout matching this project's `vm-setup/roles/` pattern:

```
roles/
  role_name/
    tasks/main.yml       # Entry point, may include per-OS task files
    handlers/main.yml    # Service restart/reload handlers
    templates/           # Jinja2 templates
    files/               # Static files to copy
    vars/main.yml        # Internal variables (not for override)
    defaults/main.yml    # Default variables (user-overridable)
    meta/main.yml        # Role metadata and dependencies
```

- Keep roles focused on a single responsibility
- Limit role dependencies -- prefer explicit `include_role` in playbooks
- Store each role in a dedicated Git repo when scaling; use `roles/requirements.yml`

## Security

- **Use `become`, not root login** -- tasks run via sudo for auditability
- **Vault for secrets** -- encrypt sensitive variables with `ansible-vault`
- **Vault indirection** -- keep names visible in `vars`, secrets in `vault`:
  `db_password: "{{ vault_db_password }}"`
- Create a dedicated Ansible user on target machines

## Execution & Debugging

| Flag              | Purpose                                  |
| ----------------- | ---------------------------------------- |
| `--check`         | Dry run -- show what would change        |
| `--diff`          | Show file content differences            |
| `-vvvv`           | Maximum verbosity for troubleshooting    |
| `--step`          | Confirm each task before executing       |
| `--syntax-check`  | Validate playbook syntax without running |
| `--list-tasks`    | Show tasks that would be executed        |
| `--list-tags`     | Show available tags                      |
| `--start-at-task` | Resume from a specific task              |

Use the `debug` module with `verbosity` to control output noise:

```yaml
- name: Show variable only in verbose mode
  ansible.builtin.debug:
    msg: "Value is {{ my_var }}"
    verbosity: 2
```

## Project-Specific Patterns

This project uses a **three-area Ansible architecture** executed sequentially
by the cloud-init deployment pipeline. See [REFERENCE.md](REFERENCE.md) for
full details including directory layouts, dynamic inventory generation, retry
logic, and deployment pipeline integration.

| Area            | Directory        | Purpose                                            |
| --------------- | ---------------- | -------------------------------------------------- |
| VM hardening    | `vm-setup/`      | OS packages, SELinux, firewall, hardening, NTP      |
| App deployment  | `sys-env-setup/` | SCC software transfer, unpacking, environment config |
| DB deployment   | `db-setup/`      | Oracle user/fs prep, oradist, database creation     |

Key patterns:

- **Tag-based selective execution**: `--tags abrt,audit,hardening,...`
- **OS-aware roles**: branch on `ansible_distribution` and `ansible_distribution_major_version`
- **Host group taxonomy**: `APP`, `DB`, `DMZ`/`SCCLIS` with `SCC:children` parent
- **Dynamic inventory from OCI metadata**: Bash scripts generate INI inventory at runtime
- **Retry mechanism**: up to 5 attempts with progressive backoff for unreachable hosts
