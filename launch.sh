#!/bin/bash

ENV_LIST=("dev" "staging" "prod")
COMMAND_LIST=("plan" "apply" "destroy")

# Access Keys
TF_VAR_do_token=$(pass do_token)
TF_VAR_cf_token=$(pass cf_token)
TF_VAR_zone_id=$(pass zone_id)
TF_VAR_access_key=$(pass do_space_access)
TF_VAR_secret_key=$(pass do_space_secret)

# formatted_list [list]
#
# Create a formatted list of options for the user to see
function formatted_list {
    local arr=("$@")

    for (( i = 0; i < ${#arr[@]}; i++ ));
    do
        echo "$(( "$i" + 1 ))"")" "${arr[$i]}"
    done
}

# valid_argument [input] [list]
#
# Check input to see if it's in the list
function valid_argument {
    local input="$1"
    local arr=("$@")

    for (( i = 1; i <= $((${#arr[@]}+1)); i++ ));
    do
        if [[ "${arr[$i]}" = "$input" ]]; then
            echo "$input"
            break
        elif [[ "${arr[$i]}" = "${arr[$input]}" ]]; then
            echo "${arr[$input]}"
            break
        elif [ "$i" == $((${#arr[@]}+1)) ]; then
            kill 0
        else
            :
        fi
    done
}

function main {
    # Setup enviornment
    echo ""
    echo "What enviornment do you want to change?"
    echo "------------------------------"
    formatted_list "${ENV_LIST[@]}"
    read -r -p "Enter env: " input
    env=$(valid_argument "$input" "${ENV_LIST[@]}")

    # Setup Action
    echo ""
    echo "What would you like Terraform to do?"
    echo "------------------------------"
    formatted_list "${COMMAND_LIST[@]}"
    read -r -p "Enter your command: " input
    tf_command=$(valid_argument "$input" "${COMMAND_LIST[@]}")

    # Select the workspace
    terraform workspace select "$env"

    if [ "$env" == "prod" ] && [ "$tf_command" == "destroy" ]; then # Prevent destroying production
        echo "Are you really really REALLY sure you want to DESTROY PRODUCTION?"
        read -r -p "YES I DO WANT TO DESTROY PRODUCTION [Y/N] " input
        if [ "$input" == "Y" ] || [ "$input" == "y" ]; then
            terraform "$tf_command" -var-file="env/$env.tfvars"
        else
            echo "Good call"
            exit 0
        fi
    elif [ "$env" == "prod" ] && [ "$tf_command" == "apply" ]; then
        echo "You are about to make a change on a production server. Please click yes to confirm that you have tested these changes in staging before rolling them out to production"
        read -r -p "Have you tested this change [Y/N] " input
        if [ "$input" == "Y" ] || [ "$input" == "y" ]; then
            terraform "$tf_command" -var-file="env/$env.tfvars"
        else
            echo "Thank you"
            exit 0
        fi
    else
        terraform "$tf_command" -var-file="env/$env.tfvars"
    fi
}

echo "Initialising Terraform"

export TF_VAR_do_token
export TF_VAR_cf_token
export TF_VAR_zone_id
export TF_VAR_access_key
export TF_VAR_secret_key

terraform init \
          -backend-config="access_key=$TF_VAR_access_key" \
          -backend-config="secret_key=$TF_VAR_secret_key"
main
