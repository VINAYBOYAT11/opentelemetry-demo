#!/bin/bash

# Define your target AWS ECR path
AWS_BASE="public.ecr.aws/f6a5u4d3/opentelematry/vinay-dev"

# Loop ONLY through your custom vinay11 application images
for local_img in $(docker images --format "{{.Repository}}:{{.Tag}}" | grep "^vinay11/"); do
    
    # Extract the service name (e.g., "accounting" from "vinay11/accounting:v1")
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
echo "All vinay11 images successfully processed!"
