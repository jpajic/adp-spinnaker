# GCP service account for Spinnaker
resource "google_service_account" "spinnaker-sa" {
  project      =  var.project
  account_id   = "spinnaker"
  display_name = "Spinnaker (GKE Workload Identity)"
}

# Bind Spinnaker k8s service account to GCP service account using GKE Workload Identity
# See: https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity
resource "google_service_account_iam_binding" "spinnaker-sa-k8s-binding" {
  service_account_id  = google_service_account.spinnaker-sa.name
  role                = "roles/iam.workloadIdentityUser"

  members = [
    "serviceAccount:${google_project.project.project_id}.svc.id.goog[spinnaker/spinnaker-sa]",
    "serviceAccount:${google_project.project.project_id}.svc.id.goog[spinnaker/halyard-sa]",
  ]
}
