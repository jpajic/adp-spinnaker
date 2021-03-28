resource "google_project_service" "apis" {
  project            = var.project
  disable_on_destroy = false

  for_each = toset([
      "cloudapis.googleapis.com",
      "cloudbuild.googleapis.com",
      "compute.googleapis.com",
      "container.googleapis.com",
      "iam.googleapis.com",
      "iamcredentials.googleapis.com",
      "iap.googleapis.com",
      "logging.googleapis.com",
      "monitoring.googleapis.com",
      "stackdriver.googleapis.com",
      "storage-api.googleapis.com",
      "storage-component.googleapis.com",
  ])
  service = each.value
}