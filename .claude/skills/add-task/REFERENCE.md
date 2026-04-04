# Add Task — Reference

Patterns, templates, and update checklists for the `add-task` workflow.

---

## Role Assignment Heuristics

| Tool category | Suggested role | Notes |
|---|---|---|
| apt packages, shell utilities, editors, fonts | `system` | No Homebrew dependency |
| Container runtimes, compilers, language toolchains | `devtools` | Build and runtime environment |
| Cloud CLIs, Kubernetes tools, HashiCorp, infra tools | `devops` | Requires Homebrew from `system` |
| Ambiguous / cross-cutting | ask user | No clear single mapping |

---

## GitHub Release Pattern

Use when the tool ships a binary or AppImage on GitHub Releases and no package
manager option exists or is preferred.

```yaml
---
- name: Install <Tool>
  block:
    - name: Check current <tool> version
      ansible.builtin.command: "<tool> --version"
      register: <role>_<tool>_version
      changed_when: false
      failed_when: false

    - name: Get latest <tool> release
      ansible.builtin.uri:
        method: GET
        url: https://api.github.com/repos/<owner>/<repo>/releases/latest
      register: <role>_<tool>_release

    - name: Register versions
      ansible.builtin.set_fact:
        <role>_current_<tool>: >-
          {{ (<role>_<tool>_version.rc | int == 0) | ternary(
            <role>_<tool>_version.stdout_lines[0]
              | regex_replace('<version-prefix-regex>', '\1'),
            '') }}
        <role>_latest_<tool>: >-
          {{ <role>_<tool>_release.json.tag_name | regex_replace('^v', '') }}

    - name: Install latest <tool>
      when: <role>_latest_<tool> != <role>_current_<tool>
      block:
        - name: Download <tool> binary
          vars:
            _<tool>_url: >-
              {{ <role>_<tool>_release.json.assets
                | selectattr('name', 'equalto', '<asset-filename>')
                | map(attribute='browser_download_url')
                | first }}
          ansible.builtin.get_url:
            url: "{{ _<tool>_url }}"
            dest: "/tmp/<asset-filename>"
            mode: "u=rwx,g=rx,o=rx"

        - name: Create installation directory
          ansible.builtin.file:
            path: "{{ <role>_local_bin }}"
            state: directory
            mode: "u=rwx,g=rx,o=rx"

        - name: Install <tool>
          ansible.builtin.copy:
            src: "/tmp/<asset-filename>"
            dest: "{{ <role>_local_bin }}/<tool>"
            mode: "u=rwx,g=rx,o=rx"
            remote_src: true

        - name: Clean up downloaded file
          ansible.builtin.file:
            path: "/tmp/<asset-filename>"
            state: absent
```

### Version-string extraction tips

| Version output example | Extract with |
|---|---|
| `NVIM v0.10.0 …` | `regex_replace('^NVIM v([0-9.]+).*', '\1')` on `stdout_lines[0]` |
| `Homebrew 4.2.0 …` | `regex_replace('^Homebrew ([0-9.]+).*', '\1')` on `stdout_lines[0]` |
| Last word (e.g. `gah v0.5.1`) | `stdout \| split \| last` |
| `tag_name: v1.2.3` | `tag_name \| regex_replace('^v', '')` |

Check the actual `releases/latest` JSON (`tag_name` field) before writing
the `set_fact` to confirm whether the tag includes a `v` prefix.

If the install script pattern is used instead of a direct binary download
(as in `brew.yml` and `gah.yml`), replace the download/copy/symlink block with:

```yaml
        - name: Download <tool> install script
          ansible.builtin.get_url:
            url: "{{ _<tool>_script_url }}"
            dest: "/tmp/<tool>_install.sh"
            mode: "u=rwx,g=rx,o=rx"

        - name: Run <tool> install script
          ansible.builtin.command: /tmp/<tool>_install.sh
          changed_when: true

        - name: Clean up install script
          ansible.builtin.file:
            path: /tmp/<tool>_install.sh
            state: absent
```

---

## Homebrew Pattern

Use for any tool available as a Homebrew formula.

```yaml
---
- name: Install <Tool>
  community.general.homebrew:
    name: <formula>
    state: present
    path: >-
      /home/linuxbrew/.linuxbrew/bin:/opt/homebrew/bin:/usr/local/bin:{{ ansible_facts['env']['PATH'] }}
```

If several packages need to be installed use loop

```yaml
---
- name: Install <Tool>
  community.general.homebrew:
    name: "{{ item }}"
    state: present
    path: >-
      /home/linuxbrew/.linuxbrew/bin:/opt/homebrew/bin:/usr/local/bin:{{ ansible_facts['env']['PATH'] }}
  loop:
    - <formula>
```

When a tap is required, add a preceding task:

```yaml
- name: Add <vendor> Homebrew tap
  community.general.homebrew_tap:
    name: <vendor>/<tap>
    state: present
    path: >-
      /home/linuxbrew/.linuxbrew/bin:/opt/homebrew/bin:/usr/local/bin:{{ ansible_facts['env']['PATH'] }}
```

---

## APT Pattern

Use for tools available as standard Debian/Ubuntu packages.

```yaml
---
- name: Install <Tool>
  become: true
  ansible.builtin.apt:
    name: "{{ item }}"
    state: present
  loop:
    - <package>
  when: ansible_facts['os_family'] == 'Debian'
```

When the package requires a third-party apt repository, follow the Docker
pattern in `roles/devtools/tasks/docker.yml`:

1. Install `apt-transport-https`, `gnupg`, `ca-certificates`
2. Add GPG key via `ansible.builtin.apt_key`
3. Add repository via `ansible.builtin.apt_repository`
4. Install packages via `ansible.builtin.apt`

---

## `tasks/main.yml` Entry

**`system` and `devops` roles** — `tasks/` prefix (match existing entries):

```yaml
- name: Install <Tool>
  ansible.builtin.import_tasks: tasks/<tool>.yml
```

**`devtools` role** — bare filename, no prefix (match existing entries):

```yaml
- name: Import <Tool> tasks
  ansible.builtin.import_tasks: <tool>.yml
```

---

## `meta/main.yml` Update

Extend the folded `description` scalar and append to `galaxy_tags`.
Tags must be lowercase with no spaces (hyphens allowed).

```yaml
galaxy_info:
  description: >
    Existing description. Added <tool>: one-line purpose.
  galaxy_tags:
    - existing_tag
    - new_tag
```

---

## Role README Section Template

Add under `## Components`, matching the style of surrounding sections.

**Prose style** (`system` / `devtools` pattern — tools with notable behaviour):

```markdown
### <Tool>

Installs [<Tool>](<upstream-url>) via <method>. <One sentence describing
what it does or notable behaviour — version-check logic, symlinks created,
configurable options.>

<If configurable:> Configurable via `<role>_<var>`.
```

**Table style** (`devops` pattern — tools grouped by category):

```markdown
### <Category>

| Tool | Description |
|---|---|
| [<Tool>](<upstream-url>) | One-line description |
```

If new variables were added to `defaults/main.yml`, add rows to the
**Role Variables** table:

```markdown
| `<role>_<var>` | `<default>` | Description of what it controls |
```

---

## Main README Entry Format

The top-level `README.md` uses GFM task-list checkboxes under each role section.
Use `- [x]` for implemented items and `- [ ]` for planned ones.

**Adding to an existing group:**

```markdown
- [x] [<Tool>](<upstream-url>) — short description
```

**Adding a new group:**

```markdown
- [x] <Group name>
  - [x] [<Tool>](<upstream-url>) — short description
```

Match the capitalisation, link style, and em-dash separator (`—`) used in
existing entries.
