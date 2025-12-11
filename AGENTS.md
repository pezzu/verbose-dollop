# Agent Guidelines for verbose-dollop

## Project Type
This is an Ansible playbook for local machine setup and configuration.

## Build/Lint/Test Commands
- **Install/Run**: `./install.sh` (installs Ansible and runs the playbook)
- **Lint YAML**: `yamllint .`
- **Lint Ansible**: `ansible-lint`
- **Run playbook**: `ansible-playbook ./playbook.yml --extra-vars "@./defaults/main.yml"`
- **Install requirements**: `ansible-galaxy install -r requirements.yml`

## Code Style Guidelines
- **YAML formatting**: Follow `.yamllint.yml` rules (max line length 100, max 1 space inside braces/brackets)
- **Ansible structure**: Use `ansible.builtin.*` module names, organize tasks in separate files
- **Variable naming**: Use snake_case (e.g., `local_bin`, `repo_url`)
- **File organization**: Keep role-specific tasks in `roles/*/tasks/main.yml`, use `import_tasks` for modularity
- **Configuration**: Store defaults in `defaults/main.yml`, use structured YAML with proper indentation
- **Shell scripts**: Use bash with proper error handling (`set -e` style), check for root user

## Testing
- CI runs yamllint, ansible-lint, and idempotence tests
- Test idempotence by running install twice and checking for minimal changes