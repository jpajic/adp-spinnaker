# References
Credit to external resources used in developing this demo

## Google Cloud
* [Google Kubernetes Engine](https://cloud.google.com/kubernetes-engine/docs)
* [Google Cloud Storage](https://cloud.google.com/storage/docs)
* [Workload Identity](https://cloud.google.com/blog/products/containers-kubernetes/introducing-workload-identity-better-authentication-for-your-gke-applications)
* [Container-native Load Balancing](https://cloud.google.com/kubernetes-engine/docs/concepts/container-native-load-balancing)
* [Managed Certificates](https://cloud.google.com/load-balancing/docs/ssl-certificates/google-managed-certs)
* [GCP APIs](https://console.cloud.google.com/apis/library)

## Spinnaker
* [Helm Chart](https://github.com/OpsMx/spinnaker-helm)
* [Helm Chart Values (Configuration Options)](https://github.com/OpsMx/spinnaker-helm/blob/main/values.yaml)
* [Spinnaker Custom Configuration](https://spinnaker.io/reference/halyard/custom/)
* [Manage Spinnaker pipelines](https://spinnaker.io/guides/spin/pipeline/)

## Terraform
* [Google Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
* [Google Cloud Project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project)
* [Google Cloud Platform APIs](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_service)
* [GKE](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster)
* [GKE Node Pool](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_node_pool)
* [GCS Bucket](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket)
* [GCS Bucket Permissions](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam)
* [IAM Service Account](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account)
* [Workload Identity IAM Binding](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account_iam)
* [Global IP Address](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_address)
* [DNS Managed Zone](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_managed_zone)
* [DNS Record Set](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_record_set)

## Tutorials
* [Creating a regional GKE Cluster](https://cloud.google.com/kubernetes-engine/docs/how-to/creating-a-regional-cluster)
* [Using Workload Identity](https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity)
* [Container-native load balancing through Ingress](https://cloud.google.com/kubernetes-engine/docs/how-to/container-native-load-balancing)
* [Using Google-managed SSL certificates](https://cloud.google.com/kubernetes-engine/docs/how-to/managed-certs)
* [Spinnaker Persistent State in GCS Bucket](https://spinnaker.io/setup/install/storage/gcs/) *Note: inspirational only, authentication is done via Workload Identity, not Service Account Key JSON*
* [Manage Traffic Using Kubernetes Manifests](https://spinnaker.io/guides/user/kubernetes-v2/traffic-management/)
* [Receiving artifacts in Spinnaker from GitHub](https://spinnaker.io/guides/user/pipeline/triggers/github/)
