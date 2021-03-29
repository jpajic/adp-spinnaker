#!/bin/bash
set -e

# Tools
gcloud="gcloud"
terraform="$(pwd)/tools/terraform"
kubectl="$(pwd)/tools/kubectl"
helm="$(pwd)/tools/helm"

# Default Configuration
function _default_config {
    if [[ -z ${ADP_CONFIG_GCP_PROJECT} ]]; then
        export ADP_CONFIG_GCP_PROJECT="adp-demo-1-20210329"
    fi
    if [[ -z ${ADP_CONFIG_GCP_REGION} ]]; then
        export ADP_CONFIG_GCP_REGION="europe-west3"
    fi
    if [[ -z ${ADP_CONFIG_GCP_GCS_LOCATION} ]]; then
        export ADP_CONFIG_GCP_GCS_LOCATION="EU"
    fi
    if [[ -z ${ADP_CONFIG_GCP_GKE_CLUSTER} ]]; then
        export ADP_CONFIG_GCP_GKE_CLUSTER="adp-spinnaker"
    fi
    if [[ -z ${ADP_CONFIG_DNS_GCP_PROJECT} ]]; then
        export ADP_CONFIG_DNS_GCP_PROJECT="dns-apps-pajic-io"
    fi
    if [[ -z ${ADP_CONFIG_DNS_ZONE} ]]; then
        export ADP_CONFIG_DNS_ZONE="apps-pajic-io"
    fi
    if [[ -z ${ADP_CONFIG_DNS_DOMAIN} ]]; then
        export ADP_CONFIG_DNS_DOMAIN="apps.pajic.io"
    fi
    if [[ -z ${ADP_CONFIG_GCP_BILLING_ACCOUNT} ]]; then
        export ADP_CONFIG_GCP_BILLING_ACCOUNT=$(cat ./.secrets/gcp_billing_account)
    fi
}

# Setup Environment (copy config to terraform env variables)
function _default_tf_env {
    export TF_VAR_billing_account=${ADP_CONFIG_GCP_BILLING_ACCOUNT}
    export TF_VAR_project=${ADP_CONFIG_GCP_PROJECT}
    export TF_VAR_region=${ADP_CONFIG_GCP_REGION}
    export TF_VAR_gcs_region=${ADP_CONFIG_GCP_GCS_LOCATION}
    export TF_VAR_cluster_name=${ADP_CONFIG_GCP_GKE_CLUSTER}
    export TF_VAR_project_dns=${ADP_CONFIG_DNS_GCP_PROJECT}
    export TF_VAR_dns_zone_name=${ADP_CONFIG_DNS_ZONE}
    export TF_VAR_dns_domain=${ADP_CONFIG_DNS_DOMAIN}
}

# Helper function to unify terraform deployments
function _deploy_tf {
    # Wrap terraform init and apply calls into per-project terraform workspaces.
    # This makes switching between multiple deployments safe and simple
    # while keeping the terraform state cleanly separated in the same cloud storage bucket.
    dir=$(pwd)
    cd "./$1"                                                &&\
    terraform init                                           &&\
    ($terraform workspace new ${ADP_CONFIG_GCP_PROJECT}      ||\
    $terraform workspace select ${ADP_CONFIG_GCP_PROJECT})   &&\
    $terraform init                                          &&\
    $terraform apply -auto-approve                           ||\
    $terraform apply -auto-approve                           ||\
    $terraform apply -auto-approve
    # Sometimes multiple rounds (of terraform apply) are necessary (gcp api enabling too slow)
    cd $dir
}

# Deploy GKE Cluster and associated resources using Terraform
function deploy-gke-tf {
    echo "Deploying GKE Cluster and associated resources using Terraform..."
    _deploy_tf "gke-terraform"
    $gcloud config set project ${ADP_CONFIG_GCP_PROJECT}
    $gcloud container clusters get-credentials ${ADP_CONFIG_GCP_GKE_CLUSTER} --region ${ADP_CONFIG_GCP_REGION}
}

# Deploy Spinnaker using helm and custom config from ./spinnaker
function deploy-spinnaker {
    echo "Deploying Spinnaker using helm v3..."

    # Create namespace, service accounts + workload identity setup
    echo "Preparing k8s cluster for Spinnaker setup..."
    $kubectl create ns spinnaker || echo "Nevermind."
    $kubectl -n spinnaker create serviceaccount spinnaker-sa || echo "Nevermind."
    $kubectl -n spinnaker annotate serviceaccount spinnaker-sa iam.gke.io/gcp-service-account=spinnaker@${ADP_CONFIG_GCP_PROJECT}.iam.gserviceaccount.com || echo "Nevermind."
    $kubectl -n spinnaker create serviceaccount halyard-sa || echo "Nevermind."
    $kubectl -n spinnaker annotate serviceaccount halyard-sa iam.gke.io/gcp-service-account=spinnaker@${ADP_CONFIG_GCP_PROJECT}.iam.gserviceaccount.com || echo "Nevermind."

    # Replace parametrized values in yaml template from ENV and install helm chart
    echo "Installing Spinnaker helm (v3) chart..."
    cat ./spinnaker/spinnaker-helm-values.yaml.tpl | envsubst | $helm install spinnaker ./spinnaker/spinnaker-2.2.5.tgz -n spinnaker -f - --timeout 1200s

    echo "Deploying Spinnaker Ingress..."
    cat ./spinnaker/spinnaker-ingress.yaml.tpl | envsubst | $kubectl apply -n spinnaker -f -

    # Wait for Spinnaker to be available
    url="https://spinnaker.${ADP_CONFIG_DNS_DOMAIN}"
    timeout=1800
    interval=15
    acc=0
    while [[ "$(curl -s -o /dev/null -w ''%{http_code}'' $url)" != "200" ]]; do 
        echo "Waiting for Spinnaker to become available..."
        sleep $interval
        acc=$(($acc+$interval))
        if (( acc >= timeout )); then
            echo "Timeout waiting for Spinnaker to come up"
            exit 1
        fi
    done
    echo "Spinnaker deployed successfully"
}

# Configure GitHub account for access to application manifests and pipeline triggers (webhooks)
function configure_github_account {
    # Enable GitHub account provider in Spinnaker using halyard
    $kubectl -n spinnaker exec spinnaker-spinnaker-halyard-0 -- hal config artifact github enable
    # Copy GitHub access token to halyard pod
    $kubectl -n spinnaker cp ./.secrets/github_accesstoken spinnaker-spinnaker-halyard-0:/tmp/
    # Configure GitHub access token using halyard
    $kubectl -n spinnaker exec spinnaker-spinnaker-halyard-0 -- hal config artifact github account add github --token-file /tmp/github_accesstoken
    # Apply config changes to Spinnaker instance
    $kubectl -n spinnaker exec spinnaker-spinnaker-halyard-0 -- hal deploy apply
    # Cleanup GitHub access token
    $kubectl -n spinnaker exec spinnaker-spinnaker-halyard-0 -- rm /tmp/github_accesstoken
}

# Create local spin (Spinnaker cli) config pointing to Spinnaker gate endpoint
function configure_spinnaker_cli {
    echo "gate:" > ./tools/spin-config
    echo "  endpoint: https://spinnaker.${ADP_CONFIG_DNS_DOMAIN}/gate" >> ./tools/spin-config
}

function main {
    # Prepare
    _default_config
    _default_tf_env

    if [[ -z $1 ]]; then
        echo "Deploying Spinnaker to new GKE cluster..."
        # Stage 1: gke cluster
        echo "Setting up cloud infrastructure using terraform..."
        deploy-gke-tf

        # Stage 2: spinnaker
        echo "Installing Spinnaker using helm (v3)..."
        deploy-spinnaker

        # Stage 3: 
        echo "Configuring access to GitHub for webhooks..."
        configure_github_account

        # Stage 4:
        echo "Creating local spin cli config..."
        configure_spinnaker_cli

        # Done
        exit 0
    fi

    if [[ $1 == "terraform" ]]; then
        echo "Running terraform only..."
        deploy-gke-tf
        exit 0
    fi

    if [[ $1 == "spinnaker" ]]; then
        echo "Deploying spinnaker only..."
        deploy-spinnaker
        exit 0
    fi
}

main $@
