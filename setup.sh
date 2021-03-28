#!/bin/bash
set -e

# Default Configuration
function _default_config {
    if [[ -z ${ADP_CONFIG_GCP_PROJECT} ]]; then
        export ADP_CONFIG_GCP_PROJECT="adp-demo-1-20210327"
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
}

# Load secret configuration into environment from git-ignored file
function _secret_config {
    source .secrets/setup_secret_env.sh
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
    cd "./$1"                                               &&\
    (terraform workspace new ${ADP_CONFIG_GCP_PROJECT}      ||\
    terraform workspace select ${ADP_CONFIG_GCP_PROJECT})   &&\
    terraform init                                          &&\
    terraform apply -auto-approve                           ||\
    terraform apply -auto-approve
    # Sometimes two rounds (of terraform apply) are necessary (gcp api enabling too slow)
    cd $dir
}

# Deploy GKE Cluster and associated resources using Terraform
function deploy-gke-tf {
    echo "Deploying GKE Cluster and associated resources using Terraform..."
    _deploy_tf "gke-terraform"
    gcloud config set project ${ADP_CONFIG_GCP_PROJECT}
    gcloud container clusters get-credentials ${ADP_CONFIG_GCP_GKE_CLUSTER} --region ${ADP_CONFIG_GCP_REGION}
}

# Deploy Spinnaker using helm and custom config from ./spinnaker
function deploy-spinnaker {
    echo "Deploying Spinnaker using helm v3..."

    # Get Helm chart
    # helm repo add spinnaker https://helmcharts.opsmx.com/ && helm repo update

    # Create namespace, service accounts + workload identity setup
    echo "Preparing k8s cluster for Spinnaker setup..."
    kubectl create ns spinnaker || echo "Nevermind."
    kubectl -n spinnaker create serviceaccount spinnaker-sa || echo "Nevermind."
    kubectl -n spinnaker annotate serviceaccount spinnaker-sa iam.gke.io/gcp-service-account=spinnaker@${ADP_CONFIG_GCP_PROJECT}.iam.gserviceaccount.com || echo "Nevermind."
    kubectl -n spinnaker create serviceaccount halyard-sa || echo "Nevermind."
    kubectl -n spinnaker annotate serviceaccount halyard-sa iam.gke.io/gcp-service-account=spinnaker@${ADP_CONFIG_GCP_PROJECT}.iam.gserviceaccount.com || echo "Nevermind."

    # Replace parametrized values in yaml template from ENV and install helm chart
    echo "Installing Spinnaker helm (v3) chart..."
    cat ./spinnaker/spinnaker-helm-values.yaml.tpl | envsubst | helm install spinnaker ./spinnaker/spinnaker-2.2.5.tgz -n spinnaker -f - --timeout 1200s

    echo "Deploying Spinnaker Ingress..."
    cat ./spinnaker/spinnaker-ingress.yaml.tpl | envsubst | kubectl apply -n spinnaker -f -

    # Wait for Spinnaker to be available
    url="https://spinnaker.${ADP_CONFIG_DNS_DOMAIN}"
    timeout=1800
    interval=15
    acc=0
    while [[ "$(curl -s -o /dev/null -w ''%{http_code}'' $url)" != "300" ]]; do 
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

function main {
    # Prepare
    _default_config
    _secret_config
    _default_tf_env

    if [[ -z $1 ]]; then
        echo "Deploying Spinnaker to new GKE cluster..."
        # Stage 1: gke cluster
        deploy-gke-tf

        # Stage 2: spinnaker
        deploy-spinnaker

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
