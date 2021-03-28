# GKE cluster
resource "google_container_cluster" "adp-spinnaker" {
  name     = var.cluster_name
  location = var.region
  project =  var.project

  # K8s Version
  release_channel {
    channel = "RAPID"
  }

  remove_default_node_pool = true
  initial_node_count       = 1

  network    = "default"
  subnetwork = "default"

  # VPC native cluster
  ip_allocation_policy {
    cluster_ipv4_cidr_block  = "/16"
    services_ipv4_cidr_block = "/22"
  }

  # Enable GKE Workload Identity to allow k8s service accounts
  # to interact with GCP services
  workload_identity_config {
    identity_namespace = "${google_project.project.project_id}.svc.id.goog"
  }

  # Disable basic authentication and cert-based authentication.
  # Empty fields for username and password are how to "disable" the
  # credentials from being generated.
  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = "false"
    }
  }
}

# Separately Managed Node Pool
resource "google_container_node_pool" "adp-spinnaker-node-pool-default" {
  name       = "${google_container_cluster.adp-spinnaker.name}-default"
  location   = var.region
  project    =  var.project
  cluster    = google_container_cluster.adp-spinnaker.name

  autoscaling {
      min_node_count = 1
      max_node_count = 3
  }
  initial_node_count = 1
  # Ignore subsequent manual changes to node count
  # to avoid terraform destroying and recreating the cluster
  lifecycle {
    ignore_changes = [
      initial_node_count
    ]
  }

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    labels = {
      env = google_project.project.project_id
    }

    machine_type = "n1-standard-1"
    tags         = [google_container_cluster.adp-spinnaker.name]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}
