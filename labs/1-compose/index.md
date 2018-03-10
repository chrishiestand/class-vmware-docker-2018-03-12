
# Lab: advanced docker-compose

Compose containers with docker-compose. Use dependencies and healthchecks where applicable.

## Option 1:
Your build. Choose any program with two or more network connected components. For example, a web app and a database. Create a docker-compose file, run the containers together, and test that they work and verify log output is as expected.
To limit lab scope, avoid building docker images. Pull pre-built images instead of building your own.

## Option 2:
Build a compose file for this guestbook application with 2 redis stores.

```
guestbook:
    image: gcr.io/google-samples/gb-frontend:v4
redis-master:
    image: k8s.gcr.io/redis:e2e
 redis-slave:
    image: gcr.io/google_samples/gb-redisslave:v1
```

docker-compose reference: <https://docs.docker.com/compose/compose-file/>
