resource "digitalocean_kubernetes_cluster" "primary" {
  name    = "${var.project_name}-${var.environment}-${var.cluster_name}"
  region  = var.cluster_region
  version = var.cluster_version

  node_pool {
    name       = "${var.project_name}-${var.environment}-${var.cluster_name}-nodepool"
    size       = var.worker_size
    node_count = var.max_nodes
    auto_scale = var.auto_scale
    min_nodes  = var.min_nodes
    max_nodes  = var.max_nodes
  }
}

resource "digitalocean_project" "primary" {
  name        = var.project_name
  description = "this project for API CI/CD project resources "
  purpose     = "API"
  environment = var.environment
  resources   = [digitalocean_kubernetes_cluster.primary.urn]
}