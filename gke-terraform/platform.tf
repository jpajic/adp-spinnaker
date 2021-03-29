# Remote terraform state in Google Cloud Storage bucket
terraform {
  backend "gcs" {
    bucket  = "adp-tf-state"
  }
}

# Download google provider for terraform
provider "google" {
  version = "~> 3.61"
}

resource "google_project" "project" {
  project_id      = var.project
  name            = var.project
  billing_account = var.billing_account
}

data "google_dns_managed_zone" "spinnaker-dns-zone" {
  name    = var.dns_zone_name
  project = var.project_dns
}
