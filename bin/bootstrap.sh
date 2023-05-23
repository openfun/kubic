#!/usr/bin/env bash

# Define function sed_inplace that works on both GNU and BSD sed
function sed_inplace() {
    local file=$2
    local command=$1
    local tmp_file=$(mktemp)

    sed -e "${command}" "${file}" >"${tmp_file}"
    mv "${tmp_file}" "${file}"
}

# Retrieve the directory path from the first argument
directory=$1

# Check if the directory exists
if [ ! -d "$directory" ]; then
    echo "The directory '$directory' does not exist."
    exit 1
fi

var_files=("$directory/variables.tf" "$directory/variables-common.tf")
tfvars_file="$directory/terraform.tfvars"

# Ensure docker is installed and running
read -p "Please make sure you have docker installed and running. Press any key to continue..." -n 1 -r -s
echo

# Create and clean the $all_variables file
all_variables=$(mktemp)

# Concatenate the contents of the elements of var_files into a single file
for var_file in "${var_files[@]}"; do
    if [ -f "$var_file" ]; then
        cat "$var_file" >>$all_variables
        echo "" >>$all_variables
    fi
done

# Create the tfvars_file of tfvars_files from their templates
if [ ! -f "${tfvars_file}.template" ]; then
    echo "The file '${tfvars_file}.template' does not exist."
fi
if [ -f "$tfvars_file" ]; then
    read -p "Are you sure you want to overwrite $tfvars_file? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborting..."
        exit 0
    fi
fi
cat "${tfvars_file}.template" >"$tfvars_file"

# Add a mandatory empty line at the end of the file
echo "" >>$all_variables

# Retrieving the names of variables declared in the file
varnames=$(grep "^variable" $all_variables | sed 's/^.*variable "\(.*\)".*$/\1/p' | awk '!a[$0]++')

# Creation of a temporary file that will contain the sorted and unique variables
tmp_file=$(mktemp)
while read -r varname; do
    sed -n "/variable \"$varname\"/,/^}/p" $all_variables | sed -n '1,/^}/p' >>$tmp_file
    echo "" >>$tmp_file
done <<<"$varnames"

# Delete duplicates
cat $tmp_file >$all_variables
# Delete the temporary file
rm $tmp_file

# Parse the $all_variables file and extract the variable names and descriptions
mapfile -t variable_names < <(sed -n 's/^.*variable "\(.*\)".*$/\1/p' $all_variables)
mapfile -t variable_descs < <(sed -n 's/^.*description *= *"\(.*\)".*$/\1/p' $all_variables)
mapfile -t variable_types < <(sed -n 's/^.*type *= *\(.*\)$/\1/p' $all_variables)

# Loop through each variable and prompt the user for a value
for i in "${!variable_names[@]}"; do
    var_name=${variable_names[i]}
    var_desc=${variable_descs[i]}
    var_type=${variable_types[i]}

    # Extract the default value for the current variable (if available)
    var_default=$(sed -n "/variable \"$var_name\"/,/^}/p" $all_variables | grep "default" | sed -E 's/^.*default *= *"?([^"]*)"?.*$/\1/')

    # If the var_name doesn't exist in the .tfvars file, continue to the next loop iteration
    if ! $(grep -q "$var_name" $tfvars_file); then
        continue
    fi

    # Check if the variable has a default value
    if [ -n "$var_default" ]; then
        default_variables+=("$var_name")
        default_descs+=("$var_desc")
        default_defaults+=("$var_default")
        default_types+=("$var_type")
    else
        non_default_variables+=("$var_name")
        non_default_descs+=("$var_desc")
        non_default_types+=("$var_type")
    fi
done

# Loop through variables with no default values first
for i in "${!non_default_variables[@]}"; do
    var_name=${non_default_variables[i]}
    var_desc=${non_default_descs[i]}
    var_type=${non_default_types[i]}

    if [ "$var_name" == "argocd_password" ]; then
        read -p "ArgoCD password : " argocd_password
        while [ -z "$argocd_password" ]; do
            read -p "You have to specify a value for \"argocd_password\": " argocd_password
        done
        DOCKER_USER="$(id -u):$(id -g)" \
        argocd_password_hashed="$(docker-compose run --quiet-pull --rm argocd-cli argocd account bcrypt --password $argocd_password)"

        # Store the variable name and value in the $tfvars_file file if the variable is declared in the file
        if $(grep -q "argocd_password" "$tfvars_file"); then
            sed_inplace "s%^argocd_password *= *\".*\"%argocd_password=\"$argocd_password_hashed\"%" "$tfvars_file"
        fi

    else
        # Add (true/false) to the description if the variable is a boolean
        if [ "$var_type" == "bool" ]; then
            var_desc="$var_desc (true/false)"
        fi

        # Prompt the user for a value
        read -p "$var_desc: " var_value

        # if the variable is a boolean and if the user imput is not true or false, prompt again
        if [ "$var_type" == "bool" ]; then
            while [ "$var_value" != "true" ] && [ "$var_value" != "false" ]; do
                read -p "Your value has to be true or false: " var_value
            done
        fi

        # If the user entered nothing, prompt again
        while [ -z "$var_value" ]; do
            read -p "You have to specify a value for \"$var_name\": " var_value
        done

        # Store the variable name and value in the $tfvars_file file if the variable is declared in the file
        if $(grep -q "$var_name" "$tfvars_file"); then
            if [ "$var_type" == "string" ]; then
                sed_inplace "s%^$var_name *= *\".*\"%$var_name=\"$var_value\"%" "$tfvars_file"
            else
                sed_inplace "s%^$var_name *= *.*%$var_name=$var_value%" "$tfvars_file"
            fi
        fi

    fi
done

# Loop through variables with default values next
for i in "${!default_variables[@]}"; do
    var_name=${default_variables[i]}
    var_desc=${default_descs[i]}
    var_default=${default_defaults[i]}
    var_type=${default_types[i]}

    if [ "$var_name" == "issuers" ]; then
        read -p "Let's encrypt email (default \"admin@admin.com\", leave blank): " letsencrypt_email
        if [ -z "$letsencrypt_email" ]; then
            letsencrypt_email="admin@admin.com"
        fi
        sed_inplace "s%^    email *= *\".*\"%    email=\"$letsencrypt_email\"%" "$tfvars_file"
        continue
    fi

    # Add (true/false) to the description if the variable is a boolean
    if [ "$var_type" == "bool" ]; then
        var_desc="$var_desc (true/false)"
    fi

    # Display the default value to the user
    read -p "$var_desc (default \"$var_default\", leave blank): " var_value

    # if the variable is a boolean and if the user imput is not true or false or nothing, prompt again
    if [ "$var_type" == "bool" ]; then
        while [ "$var_value" != "true" ] && [ "$var_value" != "false" ] && [ -n "$var_value" ]; do
            read -p "Your value has to be true or false, leave blank for the default value: " var_value
        done
    fi

    # If the user entered nothing, use the default value
    if [ -z "$var_value" ]; then
        var_value="$var_default"
    fi

    # Store the variable name and value in the $tfvars_file file if the variable is declared in the file
    if $(grep -q "$var_name" "$tfvars_file"); then
        if [ "$var_type" == "string" ]; then
            sed_inplace "s%^$var_name *= *\".*\"%$var_name=\"$var_value\"%" "$tfvars_file"
        else
            sed_inplace "s%^$var_name *= *.*%$var_name=$var_value%" "$tfvars_file"
        fi
    fi
done

# Ensure suppression of the temporary files if the script ends successfully
trap 'rm -f $all_variables' EXIT
