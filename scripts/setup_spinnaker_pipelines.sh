#!/bin/bash
set -e

# Tools
spin="./tools/spin --config ./tools/spin-config"

# Create Spinnaker Application
echo "Creating Spinnaker application..."
$spin application save --application-name podinfo --owner-email "pajicjelena26@gmail.com" --cloud-providers "kubernetes"

# Import Pipelines
echo "Importing Spinnaker initial-deployment pipeline..."
$spin pipeline save --file ./spinnaker-pipelines/initial-deployment.json
echo "Importing Spinnaker blue-green-deployment pipeline..."
$spin pipeline save --file ./spinnaker-pipelines/blue-green-deployment.json
echo "Importing Spinnaker rollback pipeline..."
$spin pipeline save --file ./spinnaker-pipelines/rollback.json

# List Spinnaker Pipelines
echo "List of Spinnaker pipelines:"
$spin pipeline list --application podinfo

# Pipeline Executions here
echo "Executing Spinnaker initial-deployment pipeline..."
$spin pipeline execute --name initial-deployment --application podinfo
