# Helm chart parameter overrides

# Disable minio
minio:
  enabled: false

# Use a GCS (Google Cloud Storage) bucket instead of minio for persistent storage
gcs:
  enabled: true
  project: ${ADP_CONFIG_GCP_PROJECT}
  bucket: "${ADP_CONFIG_GCP_PROJECT}-spinnaker-storage"
  jsonKey: ""
  secretName: "empty"

# Create service accounts with deterministic names
serviceAccount:
  create: false
  halyardName: halyard-sa
  spinnakerName: spinnaker-sa