#!/usr/bin/env bash
set -eo pipefail

# Retrieve the directory path from the first argument
directory=$1

# Check if the directory exists
if [ ! -d "$directory" ]; then
    echo "The directory '$directory' does not exist."
    exit 1
fi

# Ensure tfplan file exists
if [ ! -f "$directory/tfplan" ]; then
    echo "The tfplan file does not exist. Please run terraform plan first, with the following command: 'bin/terraform-plan.sh "$directory"'."
    exit 1
fi

DOCKER_USER="$(id -u):$(id -g)" \
    docker-compose run --rm tf-$directory apply -input=false -auto-approve "/app/$directory/tfplan"

ingress_ip=$(DOCKER_USER="$(id -u):$(id -g)" \
    docker-compose run --rm tf-$directory output -raw ingress_ip)

echo "Your ingress is now running and available at $ingress_ip, please update your DNS accordingly, at least for the following domains:"
for domain in $(grep -Eo '^[^=]+hostname[^=]*=([^=]*)' scaleway/terraform.tfvars | cut -d '"' -f 2); do
    echo " - $domain"
done
