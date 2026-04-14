---
name: add-task
description: >
  Adds a new installation or configuration task to the Ansible roles in this
  playbook (system, devtools, devops). Handles installation method research
  (Homebrew first, then apt, then direct GitHub release), user verification,
  task implementation, role meta/README updates, main README update, and
  super-linter run. Use when adding, installing, configuring, or setting up
  a new tool, package, or system component.
---

# Add Task

Adds a new installation or configuration component to the playbook.

## Workflow

### Step 1 — Identify task type

Ask: is this an *installation* task (a tool or package to acquire) or a
*configuration* task (a system setting or file to manage, nothing to install)?
Configuration tasks skip Steps 2–4.

### Step 2 — Determine role

Suggest a role based on tool category; confirm with user before writing code:

| Category | Role |
|---|---|
| OS utilities, editors, fonts, shell tooling | `system` |
| Container runtimes, compilers, language runtimes | `devtools` |
| Cloud CLIs, Kubernetes, HashiCorp, infra tools | `devops` |

### Step 3 — Research installation methods *(installation tasks only)*

Investigate in priority order, then present all findings to user:

1. **Homebrew** — fetch `https://formulae.brew.sh/formula/<tool>` and
   `https://formulae.brew.sh/cask/<tool>`; note any required tap
2. **apt** — check if available in standard Debian/Ubuntu repositories
3. **GitHub direct** — locate `<owner>/<repo>`; verify `GET
   /repos/<owner>/<repo>/releases/latest` returns a `tag_name`; note
   the version-string format for comparison

### Step 4 — Verify with user

Present ranked findings and confirm the preferred method before writing any code.

### Step 5 — Implement task file

Create `roles/<role>/tasks/<tool>.yml` using the appropriate pattern from
[REFERENCE.md](REFERENCE.md) (Homebrew / APT / GitHub Release).

Add an `import_tasks` entry to `roles/<role>/tasks/main.yml` matching that
role's existing import style (see REFERENCE.md → tasks/main.yml entry).

### Step 6 — Update role meta and README

**`roles/<role>/meta/main.yml`**
- Extend `description` to mention the new tool
- Add relevant `galaxy_tags`

**`roles/<role>/README.md`**
- Add a `### <Tool>` section under `## Components` (see REFERENCE.md → Role README)
- If new variables were added to `defaults/main.yml`, add rows to the Role
  Variables table

### Step 7 — Update main README

Add the tool to the appropriate role section in the top-level `README.md`.
Use `- [x]` for implemented items, `- [ ]` for planned ones.
See REFERENCE.md → Main README for existing section shapes.

### Step 8 — Run linter and fix

```bash
docker run \
  -e RUN_LOCAL=true \
  -e VALIDATE_ALL_CODEBASE=true \
  -e DEFAULT_BRANCH=main \
  -e VALIDATE_ANSIBLE=true \
  -e ANSIBLE_DIRECTORY=. \
  -e VALIDATE_BASH=true \
  -e VALIDATE_CHECKOV=true \
  -e CHECKOV_FILE_NAME=.checkov.yml \
  -e VALIDATE_GITHUB_ACTIONS=true \
  -e VALIDATE_GITHUB_ACTIONS_ZIZMOR=true \
  -e VALIDATE_YAML=true \
  -e YAML_CONFIG_FILE=.yaml-lint.yml \
  -v $(pwd):/tmp/lint \
  ghcr.io/super-linter/super-linter:latest
```

Fix any reported issues and re-run to confirm clean output.
