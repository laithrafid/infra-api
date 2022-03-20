resource "random_id" "id" {
  byte_length = 4
  prefix      = "${var.project_name}-"
}

resource "google_folder" "terraform" {
  display_name = "terraform"
  parent       = "organizations/bayt.cloud"
}
locals {
  project_id = random_id.id.hex
}

resource "google_project" "project" {
  name            = var.project_name
  project_id      = local.project_id
  folder_id       = google_folder.terraform.name
  billing_account = "${var.billing_account}"
  org_id          = "${var.org_id}"
}

resource "google_project_services" "project" {
  project = "${google_project.project.project_id}"

  services = [
    "compute.googleapis.com",
  ]
}


resource "google_service_account" "default" {
  account_id   = "service-account-id"
  display_name = "Service Account"
}

resource "google_container_cluster" "primary" {
  name     = "${var.project_name}-${var.environment}-${var.cluster_name}"
  location = var.cluster_region
  remove_default_node_pool = true
}

resource "google_container_node_pool" "primary_nodes" {
  name          = "${var.project_name}-${var.environment}-${var.cluster_name}-nodepool"
  location      = var.cluster_region
  cluster       = google_container_cluster.primary.name
  autoscaling   = var.auto_scale
  min_node_count = var.min_nodes
  max_node_count = var.max_nodes
  }
  node_config {
    preemptible  = true
    machine_type = var.worker_size

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.default.email
    oauth_scopes    = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }