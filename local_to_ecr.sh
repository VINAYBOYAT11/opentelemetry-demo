#!/bin/bash

# Define your target AWS ECR path
AWS_BASE="public.ecr.aws/f6a5u4d3/opentelematry/vinay-dev"

# Loop through all local docker images cleanly
for local_img in $(docker images --format "{{.Repository}}:{{.Tag}}"); do
    
    # Extract the service name (e.g., "frontend" from "vinay11/frontend:v1")
    # This also cleanly handles names like "grafana/grafana" or "valkey/valkey"
    service_name=$(echo "$local_img" | awk -F'/' '{print $NF}' | cut -d':' -f1)
    
    # Build the final AWS destination tag
    aws_target="${AWS_BASE}:${service_name}-latest"
    
    echo "--------------------------------------------------"
    echo "1. Tagging: $local_img ➡️ $aws_target"
    docker tag "$local_img" "$aws_target"
    
    echo "2. Pushing: $aws_target"
    docker push "$aws_target"
done

echo "--------------------------------------------------"
echo "All images successfully processed!"
