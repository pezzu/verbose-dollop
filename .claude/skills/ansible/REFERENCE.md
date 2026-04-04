# Ansible Reference

Detailed patterns, examples, and project-specific conventions for Ansible
development in this infrastructure project.

## Recommended Directory Layout

```
site.yml                    # Master playbook, calling others
webservers.yml              # Playbook for a specific tier
deployonce.yml              # Single-shot tasks
inventories/
  production/
    hosts                   # Inventory file for production
    group_vars/
      all.yml               # Variables for all hosts
      APP.yml               # Variables for APP group
      DB.yml                # Variables for DB group
    host_vars/
  staging/
    hosts
    group_vars/
roles/
  requirements.yml          # External roles from Galaxy
  common/                   # Baseline, company-wide config
    tasks/main.yml
    handlers/main.yml
    defaults/main.yml
    vars/main.yml
    templates/
    files/
    meta/main.yml
  webtier/
```

## Project Three-Area Architecture

### Area 1: `vm-setup/` -- OS Hardening

Runs first. Configures the base operating system on all provisioned VMs.

```
vm-setup/
  ansible.cfg                           # 20 forks, SSH pipelining, fact caching
  requirements.yml                      # ansible.posix, community.general
  inventory/
    hosts                               # [APP], [DB], [SCCLIS], [SCC:children]
  playbooks/
    install.yml                         # Main entry -- full install
    install.oci.yml                     # OCI variant -- skips users, firewall, lvm
    init.yml                            # Pre-flight validation
    prerequisites.yml                   # OS, SELinux, hostname, drive checks
    group_vars/
      all.yml                           # Shared: firewall ports, LVM, packages, users
      APP.yml                           # APP-specific firewall ports (7701/tcp)
      DB.yml                            # DB-specific firewall ports (1521-1523/tcp)
      SCCLIS.yml                        # SCCLIS-specific firewall ports (8080/tcp)
  roles/
    packages/                           # OS packages by distribution
    selinux/                            # SELinux mode
    audit/                              # auditd configuration
    hardening/                          # sshd, sysctl, USB-storage
    sccfix/                             # SCC-specific fixes
    abrt/                               # ABRT crash reporting (RHEL8 only)
    tuneup/                             # System limits (nproc, file limits)
    ntp/                                # chrony time sync
    timezone/                           # System timezone
    users/                              # System users/groups (oracle, dba)
    firewall/                           # firewalld rules
    lvm/                                # LVM volume groups and logical volumes
```

**Tag-based execution** -- the automated pipeline selects roles:

```bash
ansible-playbook playbooks/install.yml \
  --tags abrt,audit,hardening,ntp,packages,sccfix,selinux,tuneup,timezone
```

### Area 2: `sys-env-setup/` -- Application Deployment

Runs second. Deploys SCC application software onto configured VMs.

```
sys-env-setup/
  ansible.cfg
  requirements.yml                      # ansible.posix
  inventory/
    hosts                               # [APP], [DB], [DMZ] with sys_* vars
    packages.yml                        # Software package list with types
    group_vars/
      all.yml                           # Computed: client_id, enviro_name, etc.
      APP.yml / DB.yml / DMZ.yml        # Per-group overrides
  playbooks/
    sys_install.yaml                    # Main: transfer, unpack, init, configure
    library/
      custom_shell.py                   # Custom module wrapping SCC Run! launcher
```

**Custom module usage:**

```yaml
- name: Initialize SCC environment
  custom_shell:
    command: "SYSinstall!"
```

### Area 3: `db-setup/` -- Oracle Database Deployment

Runs third. Installs Oracle software and creates database instances.

```
db-setup/
  ansible.cfg                           # collections_paths = ./collections
  inventory/
    hosts                               # [app_hosts], [db_hosts]
    group_vars/
      all                               # Oracle user, media directory
      app_hosts                         # CLI role, /ora01
      db_hosts                          # SRV role, full Oracle fs layout, DB params
  playbooks/
    01_system_prep.yml                  # Oracle user/groups, filesystem, packages
    02_dist_copy.yml                    # Copy Oracle distribution to hosts
    03_oradist.yml                      # Install oradist, configure firewall
    04_orasoft.yml                      # Oracle client/server, TNS, listeners
    05_cre_db.yml                       # Create database, configure systemd
```

Uses the proprietary `scc.dba` collection with roles like `scc.dba.sys_orauser`,
`scc.dba.odist_install`, `scc.dba.pub_inst_orasrv`.

## Deployment Pipeline Integration

Ansible is not run manually in production. It is orchestrated through
cloud-init driven Bash scripts in `terraform/assets/`:

```
000-iac-bootstrap.bash     Cloud-init entry, downloads assets from OCI
001-iac-main-script.bash   Sequentially calls numbered step scripts:
  010-run--linux-vm-init.bash        Initial Linux setup
  020-run--vm-setup.bash             Ansible area 1 (vm-setup)
  030-run--linux-lvm-setup.bash      LVM setup
  035-run--linux-fs-mount.bash       Filesystem mounting
  050-run--sys-env-setup.bash        Ansible area 2 (sys-env-setup)
  060-run--open-telemetry-setup.bash OpenTelemetry
  070-run--dba-oradist-setup.bash    Ansible area 3 (db-setup)
```

### Dynamic Inventory Generation

The deployment scripts generate Ansible inventory at runtime from OCI instance
metadata (`http://169.254.169.254/opc/v2/instance/`):

```bash
# Pattern used in 020-run--vm-setup.bash and 050-run--sys-env-setup.bash
cat > inventory/hosts <<EOF
[APP]
app1 ansible_host=10.0.1.10 ansible_python_interpreter=/usr/bin/python3

[DB]
db1 ansible_host=10.0.2.20 ansible_python_interpreter=/usr/bin/python3

[SCC:children]
APP
DB
EOF
```

### Retry Mechanism

Both `020` and `050` scripts retry `ansible-playbook` up to 5 times with
progressive backoff, checking for unreachable hosts in the PLAY RECAP:

```bash
MAX_RETRIES=5
RETRY_DELAY=15
for i in $(seq 1 $MAX_RETRIES); do
  ansible-playbook playbooks/install.yml --tags "$TAGS" 2>&1 | tee "$LOGFILE"
  if ! grep -q "unreachable=[1-9]" "$LOGFILE"; then
    break
  fi
  sleep $((RETRY_DELAY * i))
done
```

## OS-Aware Role Pattern

Branch task execution based on distribution. This is the standard pattern
used across `vm-setup/` roles:

```yaml
# roles/packages/tasks/main.yml
- name: Include OS-specific package tasks
  ansible.builtin.include_tasks: "{{ ansible_facts['distribution'] }}_{{ ansible_facts['distribution_major_version'] }}.yml"
```

## Fact Access Migration (Ansible Core 2.24+)

Use `ansible_facts[...]` for gathered facts instead of top-level injected
`ansible_*` fact variables:

```yaml
# Deprecated -> Preferred
# ansible_os_family        -> ansible_facts['os_family']
# ansible_architecture     -> ansible_facts['architecture']
# ansible_distribution     -> ansible_facts['distribution']
# ansible_env.PATH         -> ansible_facts['env']['PATH']
```

```yaml
# roles/packages/tasks/RedHat_8.yml
- name: Install RHEL 8 packages
  ansible.builtin.dnf:
    name: "{{ packages_rhel8 }}"
    state: present
```

Supported distributions in this project: `RedHat` (7/8/9), `OracleLinux` (7/8/9).

## Handler Patterns

```yaml
# roles/audit/handlers/main.yml
- name: Restart auditd
  ansible.builtin.service:
    name: auditd
    state: restarted

# Trigger from task
- name: Deploy auditd configuration
  ansible.builtin.template:
    src: auditd.conf.j2
    dest: /etc/audit/auditd.conf
    mode: '0640'
  notify: Restart auditd
```

## Smoke Testing After Deployment

Verify services are running after changes -- do not just start and hope:

```yaml
- name: Verify application responds
  ansible.builtin.uri:
    url: "http://localhost/myapp"
    return_content: true
  register: result
  until: '"Hello World" in result.content'
  retries: 10
  delay: 1
```

## Collections Management

Declare external collections in `requirements.yml`:

```yaml
# requirements.yml
collections:
  - name: ansible.posix
    version: "1.5.1"
  - name: community.general
    version: "6.2.0"
```

Install before running playbooks:

```bash
ansible-galaxy collection install -r requirements.yml
```

## Antipatterns

| Antipattern | Why It's Problematic | Better Approach |
| --- | --- | --- |
| Inline `key=value` args | Hard to read, no multiline support | Native YAML key:value syntax |
| Unnamed tasks | Output shows `TASK [yum]` -- useless for debugging | Always add `name:` to tasks, plays, blocks |
| Omitting `state:` | Default varies by module, intent unclear | Explicitly state `state: present` or `state: absent` |
| Short-name modules | Ambiguous, may conflict across collections | Use FQCN: `ansible.builtin.copy` |
| `command`/`shell` for everything | Not idempotent, no change detection | Use native modules; add `changed_when`/`creates` if forced |
| Running as root | Hard to audit, security risk | Use `become` with a dedicated Ansible user |
| Variables named `a`, `data2` | Meaningless, collision-prone | Descriptive names: `apache_max_keepalive` |
| Unprefixed role variables | Collisions between roles | Prefix: `audit_log_format`, `hardening_ssh_max_auth` |
| Secrets in plain group_vars | Exposed in version control | Vault indirection: `vars` + encrypted `vault` |
| Single inventory for all envs | Staging users can access production secrets | Separate inventory files/directories per environment |
| Hardcoded values | Fragile, not reusable | Use variables, data sources, and `ansible_facts` |
| No smoke tests | Deploy-and-pray | Use `uri`/`wait_for` modules to verify post-deploy |

## Quick-Launch Without Inventory

For ad-hoc one-off tasks, use the comma trick:

```bash
# Single host -- note the trailing comma
ansible all -i neon.example.com, -m ansible.builtin.service -a "name=httpd state=started"

# Playbook against single host
ansible-playbook -i neon.example.com, site.yml
```

## Handling OS Differences with group_by

Dynamically group hosts by OS at runtime:

```yaml
- name: Classify hosts by OS
  hosts: all
  tasks:
    - name: Create OS-based groups
      ansible.builtin.group_by:
        key: "os_{{ ansible_facts['distribution'] }}"

- name: Configure CentOS hosts
  hosts: os_CentOS
  gather_facts: false
  tasks:
    - name: Apply CentOS-specific settings
      ansible.builtin.include_vars: "os_CentOS.yml"
```

## References

- [Ansible Tips and Tricks](https://docs.ansible.com/ansible/latest/tips_tricks/ansible_tips_tricks.html)
- [Sample Ansible Setup](https://docs.ansible.com/ansible/latest/tips_tricks/sample_setup.html)
- [Ansible Best Practices](https://docs.ansible.com/ansible/latest/tips_tricks/ansible_tips_tricks.html#playbook-tips)
- [Special Variables](https://docs.ansible.com/ansible/latest/reference_appendices/special_variables.html)
- [Ansible Vault](https://docs.ansible.com/ansible/latest/vault_guide/index.html)
