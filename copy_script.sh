#!/bin/bash

# Define the path to your updated postgres_backup.sh script
LOCAL_SCRIPT_PATH="./postgres_backup.sh"
REMOTE_SCRIPT_PATH="/scripts/postgres_backup.sh"

# Fetch the list of pods with role=master and application=spilo across all namespaces
pod_list=$(kubectl get pods --all-namespaces -l spilo-role=master,application=spilo -o jsonpath='{range .items[*]}{.metadata.name}{" "}{.metadata.namespace}{"\n"}{end}')

# Check if the pod_list is not empty
if [ -z "$pod_list" ]; then
    echo "No pods with role=master and application=spilo found."
    exit 0
fi

# Process each pod name and namespace pair
echo "$pod_list" | while read -r pod_name namespace; do
    echo "Processing pod: $pod_name in namespace: $namespace"

    # Use kubectl cp to copy the script into the postgres container
    kubectl cp "$LOCAL_SCRIPT_PATH" "$namespace/$pod_name:$REMOTE_SCRIPT_PATH" -c postgres

    if [ $? -eq 0 ]; then
        echo "Successfully copied postgres_backup.sh to pod: $pod_name in namespace: $namespace"
    else
        echo "Failed to copy postgres_backup.sh to pod: $pod_name in namespace: $namespace"
    fi
done
