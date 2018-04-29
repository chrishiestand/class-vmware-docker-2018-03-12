# Networks

In this lab we will see how overlay networks are created with docker. Because swarm uses an overlay network, we will use the swarm commands to automatically generate our overlay networks.

Your swarm manager IP will always be the private IP of your primary lab machine e.g. `docker swarm init --advertise-addr <MANAGER-IP>`

Follow the directions as if the host only had one interface, only use the private interface.

Use the command `docker network inspect` to inspect the networks.

# Setup
SSH into your lab VM and run:


## Use the default overlay network

Start swarm on your lab vm. Use your lab private IP address as the advertisement IP

```bash
docker swarm init --advertise-addr=[PRIVATE IP]
```

List all your swarm nodes. Since we're only running on master you'll only see one node

```bash
docker node ls
```

    ID                            HOSTNAME            STATUS              AVAILABILITY        MANAGER STATUS      ENGINE VERSION
    wzy6sxorlo54fe50sq25gi80e *   lab1                Ready               Active              Leader              18.03.1-ce


You can filter the nodes by their role. `manager` manages the swarm cluster.
```bash
docker node ls --filter role=manager
```

    ID                            HOSTNAME            STATUS              AVAILABILITY        MANAGER STATUS      ENGINE VERSION
    wzy6sxorlo54fe50sq25gi80e *   lab1                Ready               Active              Leader              18.03.1-ce

`worker` is a swarm worker node. In this case we don't have any.

```bash
docker node ls --filter role=worker
```

    ID                  HOSTNAME            STATUS              AVAILABILITY        MANAGER STATUS      ENGINE VERSION


List the network on the manager. Notice that it has an overlay network called `ingress` and a bridge network called `docker_gwbridge`

```bash
docker network ls
```

    NETWORK ID          NAME                DRIVER              SCOPE
    f0d185a0ef87        bridge              bridge              local
    b3de6a68c312        docker_gwbridge     bridge              local
    34bb8861d8eb        host                host                local
    mgh6hwlyeg8p        ingress             overlay             swarm
    914aa364f861        none                null                local

The docker_gwbridge connects the ingress network to the Docker host’s network interface so that traffic can flow to and from swarm managers and workers. If you create swarm services and do not specify a network, they are connected to the ingress network. It is recommended that you use separate overlay networks for each application or group of applications which will work together. In the next procedure, you will create two overlay networks and connect a service to each of them.

### Create the services

Create a new overlay network called `nginx-net`

```bash
docker network create -d overlay nginx-net
```

    o1vqpfi8y4sfxaghlqf92mjlg

If your master had any worker nodes, you wouldn't need to explicitly create the network there. The network will automatically be created when a node starts running a service task requiring that network.

Next create a 5-replica nginx service connected to `nginx-net`. The service will publish port 80 to the outside world. All of the service task containers can communicate with each other without opening any ports.

```bash
docker service create \
  --name my-nginx \
  --publish target=80,published=80 \
  --replicas=5 \
  --network nginx-net \
  nginx
```

    hjdihhvhdq747bl49mks7x6ye
    overall progress: 5 out of 5 tasks
    1/5: running   [==================================================>]
    2/5: running   [==================================================>]
    3/5: running   [==================================================>]
    4/5: running   [==================================================>]
    5/5: running   [==================================================>]
    verify: Service converged

The default publish mode of ingress, which is used when you do not specify a mode for the --publish flag, means that if you browse to port 80 on a node you will be connected to port 80 on one of the 5 service tasks, even if no tasks are currently running on the node you browse to. If you want to publish the port using host mode, you can add mode=host to the --publish output. However, you should also use --mode global instead of --replicas=5 in this case, since only one service task can bind a given port on a given node.

Run docker service ls to monitor the progress of service bring-up, which may take a few seconds.

```bash
docker service ls
```

    ID                  NAME                MODE                REPLICAS            IMAGE               PORTS
    hjdihhvhdq74        my-nginx            replicated          5/5                 nginx:latest        *:80->80/tcp


Inspect the nginx-net network. The output will be long, but notice the Containers and Peers sections. Containers lists all service tasks (or standalone containers) connected to the overlay network from that host. Note that the peer address is your host IP address.

```bash
docker inspect nginx-net
```

```json
[
    {
        "Name": "nginx-net",
        "Id": "o1vqpfi8y4sfxaghlqf92mjlg",
        "Created": "2018-03-29T07:27:30.09764593Z",
        "Scope": "swarm",
        "Driver": "overlay",
        "EnableIPv6": false,
...
```

Inspect the service using docker service inspect my-nginx and notice the information about the ports and endpoints used by the service.

```bash
docker inspect my-nginx
```

```json
[
    {
        "ID": "hjdihhvhdq747bl49mks7x6ye",
        "Version": {
            "Index": 16
        },
        "CreatedAt": "2018-03-29T07:27:29.900043695Z",
        "UpdatedAt": "2018-03-29T07:27:29.920289368Z",
        "Spec": {
            "Name": "my-nginx",
...
```


Create a new network nginx-net-2, then update the service to use this network instead of nginx-net.

```bash
docker network create -d overlay nginx-net-2
```

    bt9y9df72nhtmh95kzbxqgo41


```bash
docker service update \
  --network-add nginx-net-2 \
  --network-rm nginx-net \
  my-nginx
```

    my-nginx
    overall progress: 5 out of 5 tasks
    1/5: running   [==================================================>]
    2/5: running   [==================================================>]
    3/5: running   [==================================================>]
    4/5: running   [==================================================>]
    5/5: running   [==================================================>]
    verify: Service converged

Run `docker service ls` to verify that the service has been updated and all tasks have been redeployed. Run `docker network inspect nginx-net` to verify that no containers are connected to it. Run the same command for `nginx-net-2` and notice that all the service task containers are connected to it.

Note: Even though overlay networks are automatically created on swarm worker nodes as needed, they are not automatically removed.

Clean up the service and the networks with the following commands.

```bash
docker service rm my-nginx
docker network rm nginx-net nginx-net-2
```

## Use user-defined overlay networks
