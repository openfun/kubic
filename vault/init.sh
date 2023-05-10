#!/bin/bash

printf "    __  __           __    _                     \n   / / / /___ ______/ /_  (_)________  _________ \n  / /_/ / __ \`/ ___/ __ \/ / ___/ __ \/ ___/ __ \\n / __  / /_/ (__  ) / / / / /__/ /_/ / /  / /_/ /\n/_/ /_/\__,_/____/_/ /_/_/\___/\____/_/  / .___/ \n _    _____   __  ____  ______          /_/     \n | |  / /   | / / / / / /_  __/                   \n| | / / /| |/ / / / /   / /                      \n| |/ / ___ / /_/ / /___/ /                       \n|___/_/  |_\____/_____/_/\n\n\n"
printf "This script will allow you to initialize your Hashicorp Vault. In order to do so, the following requirements are needed:
  * an uninitialized Hashicorp Vault
  * the kubectl command line tool configured to access your Kubernetes cluster, on which the Vault is installed.

If these requirements are met, the script will initialize the Vault and unseal it. The Vault's encryption algorithm is (by default) Shamir's algorithm. \e[1mn\e[0m keys (with n > 0) are generated, and \e[1mm\e[0m keys (with \e[1m0 < m <= n\e[0m) are needed to unseal the vault. The script will generate a cluster-keys.json file containing the keys and a root token to authenticate to the Vault. (which you may need for the next steps of the tutorial).

If a cluster-keys.json file already exists, the script will use it to unseal the vault, and not generate any new keys.
"
read -p "Are the requirements all met? (y/Y) " -n 1 -r
echo    # (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo 'Requirements not met. Exiting.'
    exit 1
fi

echo

kubectl cluster-info

echo 
echo "This is the output of the command: kubectl cluster-info. "
read -p "Do you confirm this is your cluster? (y/Y) " -n 1 -r
echo    # (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo 'Aborting.'
    exit 1
fi
echo
read -p "How many keys (n) do you want to generate? " -r key_nb
if [[ ! $key_nb =~ ^[0-9]+$ ]]
then
    echo 'This is not a number. Exiting.'
    exit 1
fi
echo
read -p "How many keys (m) do you want to unseal the vault? " -r key_nd
if [[ ! $key_nd =~ ^[0-9]+$ ]]
then
    echo 'This is not a number. Exiting.'
    exit 1
fi
echo
nb_replicas=$(kubectl get pods -n hashicorp-vault | grep -cE 'hashicorp-vault-[0-9]+')

if [ -s "cluster-keys.json" ]
then
    echo "A cluster-keys.json file already exists and is not empty. "
    read -p "Do you want to use it to unseal the vault? " -r -n 1
    echo    # (optional) move to a new line
    if [[ ! $REPLY =~ ^[Yy]$ ]]
    then
        echo 'Aborting.'
        exit 1
    fi
    echo "Using existing keys..."
else
    echo "Generating the keys..."
    kubectl exec -n hashicorp-vault hashicorp-vault-0 -- vault operator init \
        -key-shares=$key_nb \
        -key-threshold=$key_nd \
        -format=json > cluster-keys.json
fi

# We get the m first keys to unseal the vault.
for (( j=0 ; j<$nb_replicas ; j++ ))
do
  for (( i=3; i<=$((2+$key_nd)); i++ ))
  do
    key=$(sed "${i}q;d" cluster-keys.json | sed 's/ //g' | sed 's/\"//g' | sed 's/,//g')
    number=$(($i-2))
    echo "Unsealing pod ${j} with key ${number} out of ${key_nd} needed..."
    kubectl exec -n hashicorp-vault hashicorp-vault-$j -- vault operator unseal $key
    sleep 2
  done
done
echo
echo "Vault completely unsealed. You can now authenticate to the Vault with the root token in the cluster-keys.json file."
exit 0
