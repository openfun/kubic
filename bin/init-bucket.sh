#!/usr/bin/env bash
set -eo pipefail

echo "Initializing terraform..."
# Launch terraform init
DOCKER_USER="$(id -u):$(id -g)" \
    docker-compose run --rm tf-bucket-ovh init -input=false -reconfigure

echo "Planning bucket creation and configuration..."
# Launch terraform plan
DOCKER_USER="$(id -u):$(id -g)" \
    docker-compose run --rm tf-bucket-ovh plan -out=tfplan

echo "Applying the plan..."
# Launch terraform apply
DOCKER_USER="$(id -u):$(id -g)" \
    docker-compose run --rm tf-bucket-ovh apply -input=false tfplan

echo "Bucket created, retrieving credentials..."

# Give access key, secret key and bucket name
bucket_name=$(DOCKER_USER="$(id -u):$(id -g)" \
    docker-compose run --rm tf-bucket-ovh output -raw bucket_name)

access_key=$(DOCKER_USER="$(id -u):$(id -g)" \
    docker-compose run --rm tf-bucket-ovh output -raw access_key)

secret_key=$(DOCKER_USER="$(id -u):$(id -g)" \
    docker-compose run --rm tf-bucket-ovh output -raw secret_key)

echo "Here are your credentials:"
echo " - Bucket name: $bucket_name"
echo " - Access key: $access_key"
echo " - Secret key: $secret_key"