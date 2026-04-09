"""Filter plugin providing molecule_get_docker_networks for create/destroy playbooks."""


def get_docker_networks(data, labels={}):
    """Get list of docker networks defined across platforms."""
    network_list = []
    network_names = []
    for platform in data:
        if "docker_networks" in platform:
            for docker_network in platform["docker_networks"]:
                if "labels" not in docker_network:
                    docker_network["labels"] = {}
                for key in labels:
                    docker_network["labels"][key] = labels[key]

                if "name" in docker_network:
                    network_list.append(docker_network)
                    network_names.append(docker_network["name"])

        if "networks" in platform:
            for network in platform["networks"]:
                if "name" in network:
                    name = network["name"]
                    if name not in network_names:
                        network_list.append({"name": name, "labels": labels})
    return network_list


class FilterModule(object):
    """Molecule Docker filter plugins."""

    def filters(self):
        return {
            "molecule_get_docker_networks": get_docker_networks,
        }
