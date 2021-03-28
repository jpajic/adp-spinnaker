# GCS bucket for Spinnaker persistent state
resource "google_storage_bucket" "spinnaker-storage" {
  name          = "${google_project.project.project_id}-spinnaker-storage"
  location      = var.gcs_region
  project       =  var.project

  force_destroy               = true
  uniform_bucket_level_access = true
}

# Allow Spinnaker access to GCS bucket
resource "google_storage_bucket_iam_binding" "spinnaker-sa-iam-storage-bucket" {
  bucket  = google_storage_bucket.spinnaker-storage.name
  role    = "roles/storage.admin"
  members = [
    "serviceAccount:${google_service_account.spinnaker-sa.email}",
  ]
}