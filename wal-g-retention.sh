#!/bin/bash

# Fetch the list of pods with spilo-role=master across all namespaces
pod_list=$(kubectl get pods --all-namespaces -l spilo-role=master -o jsonpath='{range .items[*]}{.metadata.name}{" "}{.metadata.namespace}{"\n"}{end}')

# Check if the pod_list is not empty
if [ -z "$pod_list" ]; then
    echo "No pods with role=master found."
    exit 0
fi

# Process each pod name and namespace pair
echo "$pod_list" | while read -r pod_name namespace; do
    echo "Processing pod: $pod_name in namespace: $namespace"

    # Exec into the postgres container and modify the script as the postgres user
    kubectl exec -n $namespace $pod_name -- bash -c "
        sudo -u postgres bash -c '
            SCRIPT_PATH=\"/scripts/postgres_backup.sh\"

            # Replace the specified line in the script
            sed -i \"s|done < <(\\\$WAL_E backup-list 2> /dev/null | sed \\'0,/^name\\\\s*\\\\(last_\\\\)\\\\?modified\\\\s*/d\\')|done < <(\\\$WAL_E backup-list 2> /dev/null | sed \\'0,/^backup_name\\\\s*\\\\(last_\\\\)\\\\?modified\\\\s*/d\\')|\" \$SCRIPT_PATH

            echo \"Modified backup script in pod: $pod_name\"
        '
    "
done
