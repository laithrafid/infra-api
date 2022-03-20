resource "random_id" "cluster_name" {
  byte_length = 5
}

locals {
  cluster_name = "tf-k8s-${random_id.cluster_name.hex}"
}

module "doks_create" {
    source = "./modules/doks_create"
    DIGITALOCEAN_TOKEN = var.DIGITALOCEAN_TOKEN
    project_name       = var.project_name
    environment        = var.environment
    cluster_name       = local.cluster_name
    cluster_region     = var.cluster_region
    cluster_version    = var.cluster_version
    worker_size        = var.worker_size
    max_nodes          = var.max_nodes
    auto_scale         = var.auto_scale
    min_nodes          = var.min_nodes
}
module "doks_manage" {
    source = "./modules/doks_manage"
    DIGITALOCEAN_TOKEN = var.DIGITALOCEAN_TOKEN
    cluster_name      = module.doks_create.cluster_name
    cluster_id        = module.doks_create.cluster_id
    write_kubeconfig  = var.write_kubeconfig
}