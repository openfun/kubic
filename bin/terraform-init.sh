#!/usr/bin/env bash
set -eo pipefail

# Retrieve the directory path from the first argument
directory=$1

# Check if the directory exists
if [ ! -d "$directory" ]; then
    echo "The directory '$directory' does not exist."
    exit 1
fi

DOCKER_USER="$(id -u):$(id -g)" \
    docker-compose run --rm tf-$directory init -backend-config=backend.conf -reconfigure
