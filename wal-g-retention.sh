#!/bin/bash

# Loop through all namespaces to find pods with spilo-role:master
for pod in $(kubectl get pods --all-namespaces -l spilo-role=master -o jsonpath='{.items[*].metadata.name} {.items[*].metadata.namespace}'); do
    pod_name=$(echo $pod | awk '{print $1}')
    namespace=$(echo $pod | awk '{print $2}')

    # Exec into the postgres container and modify the script
    kubectl exec -n $namespace $pod_name -- bash -c postgres "
        # Path to the postgres_backup.sh script
        SCRIPT_PATH='/scripts/postgres_backup.sh'

        # Replace the specified line
        sed -i 's/done < <(\$WAL_E backup-list 2> \/dev\/null | sed '\''0,\/^name\s*\\\(last_\\\)\\?modified\s*/d'\'')/done < <(\$WAL_E backup-list 2> \/dev\/null | sed '\''0,\/^backup_name\s*\\\(last_\\\)\\?modified\s*/d'\'')/' \$SCRIPT_PATH

        echo "Modified backup script in pod: $pod_name"
    "
done