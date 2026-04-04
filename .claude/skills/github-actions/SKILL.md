---
name: github-actions-security
description: Reviews, designs, and hardens GitHub Actions workflows with strong defaults for token permissions, secret handling, OIDC, untrusted pull request events, third-party actions, reusable workflows, and runner isolation. Use when creating, reviewing, or upgrading .github/workflows/*.yml, reusable workflows, Actions settings, or CI/CD security policy.
---

# GitHub Actions Security

## Quick start

Use this skill when working on GitHub Actions workflows, reusable workflows, or repo/org Actions settings.

Start with this review order:

1. Identify triggers and trust boundaries.
2. Check `permissions:` for least privilege.
3. Check secrets, OIDC usage, and environment protections.
4. Check every `uses:` reference for SHA pinning and trust.
5. Check whether untrusted input can reach shell, scripts, artifacts, or privileged jobs.
6. Check runner choice and whether self-hosted runners are exposed to untrusted code.
7. Recommend GitHub-native guardrails like `CODEOWNERS`, Dependabot, dependency review, code scanning, and Scorecards.

## Default stance

- Prefer `pull_request` for building and testing PR code.
- Treat `pull_request_target` as privileged and high risk.
- Prefer `workflow_run` for privileged follow-up on untrusted PRs.
- Default `GITHUB_TOKEN` to minimal permissions.
- Prefer OIDC over long-lived cloud secrets.
- Pin third-party actions and reusable workflows to full commit SHAs.
- Prefer GitHub-hosted runners unless there is a concrete self-hosted requirement.

## High-severity findings

Flag these first:

- `pull_request_target` combined with checkout, build, test, package install, or execution of PR-controlled code.
- Broad or missing `permissions:` on workflows that only need read access.
- Third-party actions or reusable workflows pinned only to tags or branches.
- Long-lived cloud credentials where OIDC is available.
- Secrets exposed to untrusted PR contexts, reusable workflows without clear boundaries, or self-hosted runners handling untrusted code.
- Direct interpolation of untrusted expressions into inline shell.

## Secure workflow pattern

For forked PRs or otherwise untrusted input:

1. Use `pull_request` to run build, test, lint, and generate artifacts.
2. Keep that workflow unprivileged.
3. Use `workflow_run` for privileged steps like commenting, labeling, publishing status, or uploading results.
4. Treat artifacts from the untrusted workflow as untrusted data. Read them, but do not execute them.

## Review checklist

- Are triggers appropriately scoped with `types`, `branches`, and `paths`?
- Is `permissions:` set at workflow or job scope with the minimum required access?
- Are secrets minimized, masked, and replaced with OIDC where possible?
- Are all external `uses:` references pinned to full SHAs?
- Are reusable workflows passed only the inputs and secrets they need?
- Is untrusted data passed through `env:` or action inputs instead of direct shell interpolation?
- Are self-hosted runners isolated from untrusted workflows?
- Are workflows protected by `CODEOWNERS` and supported by dependency review or code scanning?

## Output style

When reviewing workflows:

- Lead with concrete risks and file references.
- Distinguish critical security flaws from maintainability suggestions.
- Offer the smallest safe fix that preserves intent.

For detailed guidance, see [REFERENCE.md](REFERENCE.md).
For secure and insecure examples, see [EXAMPLES.md](EXAMPLES.md).
