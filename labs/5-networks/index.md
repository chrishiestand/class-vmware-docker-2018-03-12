# Networks

For this lab we will go through the docker networking with overlays tutorial here: <https://docs.docker.com/network/network-tutorial-overlay/>

Your swarm manager IP will always be the private IP of your primary lab machine e.g. `docker swarm init --advertise-addr <MANAGER-IP>`

Follow the directions as if the host only had one interface, since we're only using the private interface.

Use the command `docker network inspect` to inspect the networks.
