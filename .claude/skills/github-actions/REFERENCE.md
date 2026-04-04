# GitHub Actions Security Reference

## Threat model

GitHub Actions security work should start with one question: what code or data is untrusted, and what privileges are available when that code or data is handled?

The most important trust boundaries are:

- Code from forked pull requests.
- User-controlled metadata such as PR titles, branch names, labels, issue comments, and workflow inputs.
- Third-party actions and reusable workflows.
- Artifacts produced by untrusted workflows.
- Self-hosted runner environments.

## Secure defaults for new workflows

Recommended defaults:

- Add explicit `permissions:` instead of relying on defaults.
- Set token access as low as possible, often `contents: read`.
- Use `branches`, `paths`, and `types` filters to avoid unnecessary execution.
- Set `timeout-minutes` on long-running jobs.
- Use `concurrency` when duplicate runs could conflict or create risky deployment races.
- Keep privileged actions in separate jobs or separate workflows.

Example baseline:

```yaml
permissions:
  contents: read
```

## Triggers and trust boundaries

### `pull_request`

Use for building and testing PR code, especially from forks. This is the safer default because forked PRs do not receive repository secrets, and `GITHUB_TOKEN` is read-only in that context.

Good for:

- CI
- tests
- linting
- artifact generation

### `pull_request_target`

Treat this as privileged. It runs in the context of the base repository and can expose write-capable tokens and secrets.

Safe-ish use cases:

- adding labels
- commenting on PRs
- lightweight metadata handling that does not execute PR-controlled code

Dangerous pattern:

- checking out the PR head and then running package managers, builds, tests, scripts, or anything that can execute PR-controlled content

If a workflow needs to process untrusted PR code and then perform a privileged action, split it into:

1. `pull_request` for unprivileged processing
2. `workflow_run` for privileged follow-up

### `workflow_run`

Use when a second workflow needs elevated permissions after an unprivileged workflow completes. This is the preferred pattern for commenting on PRs, applying labels, or publishing derived results after running tests on untrusted code.

Artifacts from the first workflow are still untrusted.

### Other events

Be careful with any event that processes user input, including:

- `issue_comment`
- `pull_request_review_comment`
- `workflow_dispatch`
- `repository_dispatch`

Treat inputs from these events as untrusted.

## Token permissions

### `GITHUB_TOKEN`

Always declare the minimum required permissions. If a workflow only reads the repo, keep it read-only.

Examples:

```yaml
permissions:
  contents: read
```

```yaml
jobs:
  comment:
    permissions:
      contents: read
      pull-requests: write
```

Avoid broad write access unless there is a clear need.

### When `GITHUB_TOKEN` is insufficient

Prefer GitHub App tokens over long-lived personal access tokens. If a cloud provider is involved, prefer OIDC over stored credentials.

## Secrets and OIDC

### Secret handling

Use the smallest possible set of secrets.

Best practices:

- Never store secrets in workflow YAML.
- Avoid structured blobs like JSON as a single secret when possible.
- Rotate exposed secrets and delete affected logs.
- Mask non-secret sensitive values with `::add-mask::`.
- Prefer environment variables or stdin over command-line arguments when passing secrets to processes.

### OIDC

Prefer OIDC for cloud authentication. Benefits:

- no long-lived cloud secrets in GitHub
- short-lived, job-scoped credentials
- better scoping and auditability through cloud IAM

If using OIDC, ensure:

- the workflow requests only the necessary permissions
- cloud trust conditions are scoped to repo, ref, environment, or workflow as tightly as possible

## Third-party actions and reusable workflows

### Pinning

Pin external actions and external reusable workflows to full commit SHAs.

Strong recommendation:

- `uses: owner/action@<full-sha>`

Weaker and riskier:

- tags like `@v4`
- branches like `@main`

### Auditing

Review external actions for:

- secret handling
- network calls to external services
- shell execution behavior
- provenance and maintenance quality

Prefer official, well-maintained, or verified publishers where possible, but do not treat a badge as a substitute for SHA pinning.

### Reusable workflows

Apply the same trust rules as third-party actions.

Specific caveats:

- external reusable workflows should be pinned to SHAs
- `secrets: inherit` is broad and should be used deliberately
- environment secrets do not pass through `workflow_call` in the same way as explicit secrets
- nested reusable workflows can maintain or reduce permissions, not elevate them

## Untrusted input and script injection

Do not interpolate untrusted expressions directly into inline shell.

Risky example:

```yaml
run: echo "${{ github.event.pull_request.title }}"
```

Safer pattern:

```yaml
env:
  TITLE: ${{ github.event.pull_request.title }}
run: |
  printf '%s\n' "$TITLE"
```

Preferred options:

- pass data as an action input
- pass data via `env:`
- quote shell variables
- avoid eval-like behavior

Treat these values as untrusted:

- PR titles and bodies
- issue comments
- branch names
- workflow inputs
- artifact file names and contents

## Runners

### GitHub-hosted runners

These are usually the safest default because they are ephemeral and isolated.

### Self-hosted runners

Use only with clear justification and strong isolation.

Important guidance:

- avoid self-hosted runners for public repos when untrusted PRs can trigger workflows
- separate runner groups by trust boundary
- minimize sensitive data and network access on runner hosts
- prefer ephemeral or just-in-time runners where possible
- do not assume deleting a runner after each job fully removes cross-job risk if hardware is reused carelessly

## GitHub-native guardrails

Recommend these when appropriate:

- `CODEOWNERS` on `.github/workflows/`
- Actions policy requiring full SHA pinning
- Dependabot version updates for actions
- Dependabot alerts and security updates
- dependency review on PRs
- code scanning for workflow issues
- OpenSSF Scorecards
- audit logs for secrets and Actions settings
- disabling Actions from creating or approving PRs if not needed

## Other recommendations

These are not all strictly security issues, but they improve overall quality and reduce accidental risk:

- add `merge_group` triggers when using merge queues
- use path filters to reduce unnecessary privileged runs
- centralize repeated policy in reusable workflows
- keep workflow responsibilities narrow and explicit
- separate build, test, deploy, and repo-mutation concerns

## Review output guidance

When reporting findings:

1. Lead with exploitability and impact.
2. Name the trigger, privilege, and untrusted input involved.
3. Point to the exact workflow file and job or step.
4. Recommend the smallest safe change.
5. Note residual risk if the workflow must stay privileged.
