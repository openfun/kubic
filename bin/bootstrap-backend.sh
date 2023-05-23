#!/usr/bin/env bash

# Retrieve the directory path from the first argument
directory=$1

# Check if the directory exists
if [ ! -d "$directory" ]; then
    echo "The directory '$directory' does not exist."
    exit 1
fi

# Check if the backend.conf file already exists and ask if the user wants to overwrite it
if [ -e "$directory/backend.conf" ]; then
    read -p "Are you sure you want to overwrite your backend.conf? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborting..."
        exit 1
    fi
fi

# Ask for the required values
read -p "Bucket name: " bucket
read -p "Region: " region
read -p "Access Key: " access_key
read -p "Secret Key: " secret_key
read -p "Endpoint: " endpoint
read -p "Skip Region Validation (true/false): " skip_region_validation
read -p "Skip Credentials Validation (true/false): " skip_credentials_validation

echo "The key used will be terraform.tfstate by default."
read -p "Would you like to use a differents key? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    read -p "State key: " key2
else
    key="terraform.tfstate"
fi

# Write the backend configurations
echo "bucket = \"$bucket\"" >$directory/backend.conf

echo "key = \"$key\"" >>$directory/backend.conf

echo "region = \"$region\"" >>$directory/backend.conf

echo "access_key = \"$access_key\"" >>$directory/backend.conf

echo "secret_key = \"$secret_key\"" >>$directory/backend.conf

echo "endpoint = \"$endpoint\"" >>$directory/backend.conf

echo "skip_region_validation = $skip_region_validation" >>$directory/backend.conf

echo "skip_credentials_validation = $skip_credentials_validation" >>$directory/backend.conf
