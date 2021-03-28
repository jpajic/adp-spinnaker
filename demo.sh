#!/bin/bash
set -e

# Demo environment config
export ADP_CONFIG_GCP_PROJECT="adp-demo-1-20210329"
export ADP_CONFIG_GCP_REGION="europe-west3"
export ADP_CONFIG_GCP_GCS_LOCATION="EU"
export ADP_CONFIG_GCP_GKE_CLUSTER="adp-spinnaker"
export ADP_CONFIG_DNS_GCP_PROJECT="dns-apps-pajic-io"
export ADP_CONFIG_DNS_ZONE="apps-pajic-io"
export ADP_CONFIG_DNS_DOMAIN="apps.pajic.io"

export ADP_SECRET_GCP_BILLING_ACCOUNT="<Your google billing account id>"
export ADP_SECRET_GITHUB_ACCESSTOKEN="<Your GitHub personal access token (PAT)>"

# Prepare secrets
mkdir -p ./.secrets
if [ ! -f "./.secrets/gcp_billing_account" ]; then
    echo ${ADP_SECRET_GCP_BILLING_ACCOUNT} > ./.secrets/gcp_billing_account
fi
if [ ! -f "./.secrets/github_accesstoken" ]; then
    echo ${ADP_SECRET_GITHUB_ACCESSTOKEN} > ./.secrets/github_accesstoken
fi

# Setup Infrastructure + Spinnaker
./scripts/setup.sh

# Setup Spinnaker pipelines + execute initial deployment
./scripts/setup_spinnaker_pipelines.sh
