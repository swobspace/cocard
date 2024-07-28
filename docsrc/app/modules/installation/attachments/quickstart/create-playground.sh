#!/bin/bash

# create a network
# podman network create --subnet 192.168.242.64/28 --gateway 192.168.242.65 play-cocard

# pod with shared setup over all containers
podman pod create --name play-cocard \
  --publish=3000:3000 \
  --label=group=cocard-playground

podman create --pod play-cocard --name play-cocard-redis \
  --volume play-cocard-redis:/data \
  docker.io/library/redis:latest

podman create --pod play-cocard --name play-cocard-postgres \
  --volume=play-cocard-postgres:/var/lib/postgresql/data \
  --env-file=env.playground \
  --health-cmd="/usr/local/bin/pg_isready -q -d postgres -U postgres" \
  --health-interval=10s \
  --health-timeout=45s \
  --health-retries=10 \
  docker.io/postgres:16.3

podman create --pod play-cocard --name play-cocard-app \
  --requires=play-cocard-redis,play-cocard-postgres \
  --env-file=env.playground \
  --env="FORCE_SSL=false" \
  --cap-add=CAP_NET_RAW \
  --restart=on-failure \
  --volume=play-cocard-storage:/rails/storage \
  ghcr.io/swobspace/cocard:latest

podman create --pod play-cocard --name play-cocard-worker \
  --requires=play-cocard-redis,play-cocard-postgres \
  --env-file=env.playground \
  --env="FORCE_SSL=false" \
  --restart=on-failure \
  --volume=play-cocard-storage:/rails/storage \
  ghcr.io/swobspace/cocard:latest good_job start

