#!/bin/bash

NAMESPACE="tekton-pipelines"
CURRENT_TIME=$(date +%s)

kubectl get pvc -n "$NAMESPACE" -o json | jq -r '.items[] | select(.metadata.creationTimestamp != null) | "\(.metadata.name) \(.metadata.creationTimestamp)"' | while read -r NAME TIMESTAMP; do

    CREATION_TIME=$(date -d "$TIMESTAMP" +%s)

    AGE=$((CURRENT_TIME - CREATION_TIME))

    # CHECK IF OLDER THEN 3600 SECONDS (1 HOUR)
    if [ $AGE -gt 3600 ]; then
        echo "Entferne Finalizer von PVC: $NAME (Alter: $((AGE / 60)) Minuten)"

        kubectl patch pvc "$NAME" -n "$NAMESPACE" -p '[{"op": "remove", "path": "/metadata/finalizers"}]' --type=json

        echo "Lösche PVC: $NAME"
        #kubectl delete pvc "$NAME" -n "$NAMESPACE"
    fi
done
