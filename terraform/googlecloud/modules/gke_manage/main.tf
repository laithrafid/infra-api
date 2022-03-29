locals {
  cluster_ca_certificate = data.google_container_cluster.gke.master_auth != null ? data.google_container_cluster.gke.master_auth[0].cluster_ca_certificate : ""
  private_endpoint       = try(data.google_container_cluster.gke.private_cluster_config[0].private_endpoint, "")
  default_endpoint       = data.google_container_cluster.gke.endpoint != null ? data.google_container_cluster.gke.endpoint : ""
  endpoint               = var.use_private_endpoint == true ? local.private_endpoint : local.default_endpoint
  host                   = local.endpoint != "" ? "https://${local.endpoint}" : ""
  context                = data.google_container_cluster.gke.name != null ? data.google_container_cluster.gke.name : ""
}

data "google_container_cluster" "gke" {
  name     = var.cluster_name
  location = var.location
  project  = var.project_id
}

data "google_client_config" "provider" {}

