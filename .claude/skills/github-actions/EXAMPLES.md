# GitHub Actions Security Examples

## Minimal least-privilege CI

```yaml
name: ci

on:
  pull_request:
    branches: [main]
    paths:
      - "src/**"
      - ".github/workflows/ci.yml"

permissions:
  contents: read

jobs:
  test:
    runs-on: ubuntu-latest
    timeout-minutes: 20
    steps:
      - uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11
      - run: npm ci
      - run: npm test
```

## Safe split for untrusted PRs

### Unprivileged PR workflow

```yaml
name: pr-ci

on:
  pull_request:

permissions:
  contents: read

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11
      - run: npm ci
      - run: npm test
      - name: Save PR metadata
        run: |
          mkdir -p out
          printf '%s\n' '${{ github.event.pull_request.number }}' > out/pr-number.txt
      - uses: actions/upload-artifact@65462800fd760344b1a7b4382951275a0abb4808
        with:
          name: pr-metadata
          path: out/
```

### Privileged follow-up workflow

```yaml
name: pr-comment

on:
  workflow_run:
    workflows: [pr-ci]
    types: [completed]

permissions:
  contents: read
  pull-requests: write

jobs:
  comment:
    if: >
      github.event.workflow_run.event == 'pull_request' &&
      github.event.workflow_run.conclusion == 'success'
    runs-on: ubuntu-latest
    steps:
      - name: Comment using trusted metadata only
        run: |
          echo "Download artifact and comment on the PR here."
```

## OIDC for cloud auth

```yaml
name: deploy

on:
  push:
    branches: [main]

permissions:
  contents: read
  id-token: write

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11
      - name: Authenticate to cloud via OIDC
        run: echo "Use provider login action or SDK with OIDC here."
```

## Safe handling of untrusted values

```yaml
steps:
  - name: Check title safely
    env:
      TITLE: ${{ github.event.pull_request.title }}
    run: |
      if [[ "$TITLE" =~ ^release: ]]; then
        echo "release PR"
      else
        echo "non-release PR"
      fi
```

## Insecure `pull_request_target` pattern

Do not do this:

```yaml
on:
  pull_request_target:

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11
        with:
          ref: ${{ github.event.pull_request.head.sha }}
      - run: npm ci
      - run: npm test
```

Why this is dangerous:

- the event is privileged
- the workflow checks out untrusted PR code
- `npm ci` or tests can execute attacker-controlled code

## Safer metadata-only `pull_request_target` use

```yaml
on:
  pull_request_target:
    types: [opened, synchronize]

permissions:
  contents: read
  pull-requests: write

jobs:
  label:
    runs-on: ubuntu-latest
    steps:
      - name: Label PR without checking out PR code
        run: echo "Use gh or GitHub API to label/comment here."
```

## External reusable workflow pinned to SHA

```yaml
jobs:
  security-checks:
    uses: octo-org/security-repo/.github/workflows/review.yml@172239021f7ba04fe7327647b213799853a9eb89
    permissions:
      contents: read
```

## CODEOWNERS recommendation

```text
.github/workflows/ @platform-team @security-team
```
