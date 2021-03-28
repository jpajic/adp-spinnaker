function _secret_config {
    if [[ -z ${ADP_CONFIG_GCP_BILLING_ACCOUNT} ]]; then
        export ADP_CONFIG_GCP_BILLING_ACCOUNT="<insert gcp billing account id>"
    fi
}

_secret_config