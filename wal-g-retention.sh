#!/bin/bash

# Fetch the list of pods with spilo-role=master across all namespaces
pod_list=$(kubectl get pods --all-namespaces -l application=spilo,spilo-role=master -o jsonpath='{range .items[*]}{.metadata.name}{" "}{.metadata.namespace}{"\n"}{end}')

# Check if the pod_list is not empty
if [ -z "$pod_list" ]; then
    echo "No pods with role=master found."
    exit 0
fi

# Process each pod name and namespace pair
echo "$pod_list" | while read -r pod_name namespace; do
    echo "Processing pod: $pod_name in namespace: $namespace"

    # Exec into the postgres container and replace the entire postgres_backup.sh file
    kubectl exec -n $namespace $pod_name -- bash -c "
        SCRIPT_PATH='/scripts/postgres_backup.sh'
        TEMP_PATH='/tmp/postgres_backup.sh'

        # Download the new version of postgres_backup.sh from the Spilo repository
        curl -sSL https://raw.githubusercontent.com/zalando/spilo/c547abe3e4ae802d94b3702a925e743bf8c35df5/postgres-appliance/scripts/postgres_backup.sh -o \$TEMP_PATH

        # Replace the current script with the downloaded one
        mv \$TEMP_PATH \$SCRIPT_PATH
        chmod +x \$SCRIPT_PATH

        echo 'Replaced backup script in pod: $pod_name'
    "
done
