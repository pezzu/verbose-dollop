# devops

Install DevOps tool belt: Kubernetes, HashiCorp stack, cloud CLIs, and auxiliary tools.
All packages are installed via [Homebrew](https://brew.sh).

## Components

### Kubernetes

| Tool | Description |
|---|---|
| [kubectl](https://kubernetes.io/docs/reference/kubectl/) | Kubernetes CLI |
| [minikube](https://minikube.sigs.k8s.io) | Local Kubernetes cluster |
| [helm](https://helm.sh) | Kubernetes package manager |
| [kubectx](https://github.com/ahmetb/kubectx) | Switch between Kubernetes contexts and namespaces |
| [k9s](https://k9scli.io) | Terminal UI for Kubernetes clusters |
| [lfk](https://github.com/janosmiko/lfk) | Lightning Fast Kubernetes navigator |

### HashiCorp

| Tool | Description |
|---|---|
| [tfenv](https://github.com/tfutils/tfenv) | Terraform version manager |
| [consul](https://www.consul.io) | Service mesh and service discovery |
| [nomad](https://www.nomadproject.io) | Workload orchestrator |
| [packer](https://www.packer.io) | Machine image builder |
| [vagrant](https://www.vagrantup.com) | Development environment manager |

### Cloud CLIs

| Tool | Description |
|---|---|
| [AWS CLI](https://aws.amazon.com/cli/) | Amazon Web Services CLI |
| [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/) | Microsoft Azure CLI |
| [OCI CLI](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/cliconcepts.htm) | Oracle Cloud Infrastructure CLI |

### Tools

| Tool | Description |
|---|---|
| [hey](https://github.com/rakyll/hey) | HTTP load generator |
| [dive](https://github.com/wagoodman/dive) | Docker image layer inspector |
| [mintoolkit](https://github.com/mintoolkit/mint) | Container image minifier |

## Requirements

[Homebrew](https://brew.sh) must be available. It is installed by the `system` role.

## Role Variables

None.

## License

MIT

## Author

Peter Sukhenko
