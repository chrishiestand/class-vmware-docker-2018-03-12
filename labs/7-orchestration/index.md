## docker swarm tutorial

We're going to follow docker's swarm tutorial. Go here <https://docs.docker.com/engine/swarm/swarm-tutorial/create-swarm/>. Note that the very first doesn't require docker-machine. Instead just ssh into your primary lab machine.

On step 2, `docker swarm init --advertise-addr <MANAGER-IP>`, the manager-ip needs to be the private ip address of the VM.

Stop the tutorial after you have created the swarm mode routing mesh with this command (note the port should be 80 for our setup):  
docker service create \
  --name my-web \
  --publish published=80,target=80 \
  --replicas 2 \
  nginx
