
module "gke_create" {
  source                                 = "./modules/gke_create"
  GOOGLECLOUD_TOKEN                      = var.GOOGLECLOUD_TOKEN
  environment                            = var.environment
  billing_account                        = var.billing_account
  project_folder                         = var.project_folder
  project_name                           = var.project_name
  organization_id                        = var.organization_id
  region                                 = var.region
  cluster_zones                          = [var.cluster_zones]
  auto_create_subnetworks                = var.auto_create_subnetworks
  delete_default_internet_gateway_routes = var.delete_default_internet_gateway_routes
  shared_vpc_host                        = var.shared_vpc_host
  ip_range_nodes                         = var.ip_range_nodes
  ip_range_nodes_sec                     = var.ip_range_nodes_sec
  ip_range_pods                          = var.ip_range_pods
  ip_range_pods_sec                      = var.ip_range_pods_sec
  ip_range_services                      = var.ip_range_services
  ip_range_services_sec                  = var.ip_range_services_sec
  worker_size                            = var.worker_size
  auto_scale                             = var.auto_scale
  min_nodes                              = var.min_nodes
  max_nodes                              = var.max_nodes
  node_image_type                        = var.node_image_type
  auto_repair                            = var.auto_repair
  auto_upgrade                           = var.auto_upgrade
  consumer_quotas                        = [var.consumer_quotas]
  gke_node_pool_oauth_scopes             = [var.gke_node_pool_oauth_scopes]
  gke_node_pool_tags                     = [var.gke_node_pool_tags]
}
module "gke_manage" {
  source               = "./modules/gke_manage"
  project_id           = module.gke_create.project_id
  cluster_name         = module.gke_create.cluster_name
  location             = module.gke_create.location
  use_private_endpoint = var.use_private_endpoint
  depends_on = [
    module.gke_create
  ]
}