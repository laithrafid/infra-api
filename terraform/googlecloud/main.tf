resource "random_id" "cluster_name" {
  byte_length = 5
}

locals {
  cluster_name = "tf-k8s-${random_id.cluster_name.hex}"
}

module "gke_create" {
    source = "./modules/gke_manage"
    

}
module "gke_manage" {
    source = "./modules/gke_manage"
    cluser_name      = module.gke_create.cluster_id
    cluster_id       = module.gke_manage.cluster_name
    write_kubeconfig = var.write_kubeconfig
}