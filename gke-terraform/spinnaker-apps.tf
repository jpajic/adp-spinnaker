# Spinnaker Global IP + DNS
resource "google_compute_global_address" "gke-lb-global-ip-spinnaker" {
  name    = "${google_container_cluster.adp-spinnaker.name}-lb-main"
  project =  var.project
}
resource "google_dns_record_set" "gke-lb-dns-spinnaker" {
  project      = data.google_dns_managed_zone.spinnaker-dns-zone.project
  managed_zone = data.google_dns_managed_zone.spinnaker-dns-zone.name
  name         = "spinnaker.${data.google_dns_managed_zone.spinnaker-dns-zone.dns_name}"
  type         = "A"
  ttl          = 300
  rrdatas      = [google_compute_global_address.gke-lb-global-ip-spinnaker.address]
}

# Podinfo (deployed via Spinnaker) Global IP + DNS
resource "google_compute_global_address" "gke-lb-global-ip-app-podinfo" {
  name    = "${var.cluster_name}-lb-podinfo"
  project =  var.project
}
resource "google_dns_record_set" "gke-lb-dns-app-podinfo" {
  project      = data.google_dns_managed_zone.spinnaker-dns-zone.project
  managed_zone = data.google_dns_managed_zone.spinnaker-dns-zone.name
  name         = "podinfo.${data.google_dns_managed_zone.spinnaker-dns-zone.dns_name}"
  type         = "A"
  ttl          = 300
  rrdatas      = [google_compute_global_address.gke-lb-global-ip-app-podinfo.address]
}