resource "random_id" "random_project_id_suffix" {
  byte_length = 2
}

locals {
  project_id = "${var.project_name}-${random_id.random_project_id_suffix.hex}"
  cluster_name = "gke-${local.project_id}}"
  network_name = "gke-network-${local.project_id}"
}


resource "google_folder" "folder" {
  display_name = var.project_folder
  parent       = "organizations/${var.organization_id}"
}

module "project_factory" {
  source          = "terraform-google-modules/project-factory/google"
  version         = ">= 12.0.0"
  name            = var.project_name
  project_id      = local.project_id
  org_id          = var.organization_id
  billing_account = var.billing_account
  folder_id       = google_folder.folder.id
  activate_apis   = var.activate_apis
  consumer_quotas = var.consumer_quotas
  lien            = var.lien
  depends_on = [
    google_folder.folder
  ]
}
module "service_accounts" {
  source        = "terraform-google-modules/service-accounts/google"
  version       = ">= 4.0.0"
  project_id    = "${module.project_factory.project_id}"
  prefix        = ""
  generate_keys = true
  names         = ["gkeproject"]
  project_roles = [for project_role in var.project_roles : "${module.project_factory.project_id}=>${project_role}"] 
  depends_on = [
    module.project_factory
  ]
}
module "vpc" {
  source                                 = "terraform-google-modules/network/google"
  version                                = ">= 5.0.0"
  project_id                             = module.project_factory.project_id
  network_name                           = local.network_name
  auto_create_subnetworks                = var.auto_create_subnetworks
  delete_default_internet_gateway_routes = var.delete_default_internet_gateway_routes
  shared_vpc_host                        = var.shared_vpc_host
  routing_mode                           = "GLOBAL"
  depends_on = [
    module.project_factory
  ]

  subnets = [
    {
      subnet_name               = "nodes-subnet"
      subnet_ip                 = "${var.ip_range_nodes}"
      subnet_region             = "${var.region}"
      subnet_private_access     = "true"
      subnet_flow_logs          = "true"
      subnet_flow_logs_interval = "INTERVAL_10_MIN"
      subnet_flow_logs_sampling = 0.7
      subnet_flow_logs_metadata = "INCLUDE_ALL_METADATA"
      description               = "this subnet for GKE Cluster masters/nodes"
    },
    {
      subnet_name               = "pods-subnet"
      subnet_ip                 = "${var.ip_range_pods}"
      subnet_region             = "${var.region}"
      subnet_private_access     = "true"
      subnet_flow_logs          = "true"
      subnet_flow_logs_interval = "INTERVAL_10_MIN"
      subnet_flow_logs_sampling = 0.7
      subnet_flow_logs_metadata = "INCLUDE_ALL_METADATA"
      description               = "this subnet for GKE Cluster pods/containers"
    },
    {
      subnet_name               = "services-subnet"
      subnet_ip                 = "${var.ip_range_services}"
      subnet_region             = "${var.region}"
      subnet_private_access     = "true"
      subnet_flow_logs          = "true"
      subnet_flow_logs_interval = "INTERVAL_10_MIN"
      subnet_flow_logs_sampling = 0.7
      subnet_flow_logs_metadata = "INCLUDE_ALL_METADATA"
      description               = "this subnet for GKE services in $cluster"
    }
  ]

  # secondary_ranges = {
  #   "nodes_subnet" = [
  #     {
  #       range_name    = "nodes-subnet-secondary01"
  #       ip_cidr_range = var.ip_range_nodes_sec
  #     },
  #   ]
  #   "pods_subnet" = [
  #     {
  #       range_name    = "pods-subnet-secondary01"
  #       ip_cidr_range = var.ip_range_pods_sec
  #     },
  #   ]
  #   "services_subnet" = [
  #     {
  #       range_name    = "services-subnet-secondary01"
  #       ip_cidr_range = var.ip_range_services_sec
  #     },
  #   ]
  # }

  routes = [
    {
      name              = "egress-internet-kubernetes-network"
      description       = "route through  IGW to access internet"
      destination_range = "0.0.0.0/0"
      tags              = "egress-gke"
      next_hop_internet = "true"
    },
  ]
}

module "gke" {
  source                      = "terraform-google-modules/kubernetes-engine/google"
  version                     = "20.0.0"
  project_id                  = module.project_factory.project_id
  name                        = var.cluster_name
  region                      = var.region
  zones                       = var.cluster_zones
  network                     = module.vpc.network_name
  subnetwork                  = "${local.network_name}-subnet"
  ip_range_pods               = "${local.network_name}-subnet_pods"
  ip_range_services           = "${local.network_name}-subnet_services"
  http_load_balancing         = var.http_load_balancing
  remove_default_node_pool    = var.remove_default_node_pool
  network_policy              = var.network_policy
  horizontal_pod_autoscaling  = var.horizontal_pod_autoscaling
  filestore_csi_driver        = var.filestore_csi_driver
  impersonate_service_account = module.service_accounts.service_account.email
  depends_on = [
    module.project_factory,
    module.vpc,
    module.service_accounts
  ]
}
module "gke_node_pools" {
  source                   = "../gke_create_node_pool"
  name                     = "${var.project_name}-${var.environment}-${var.cluster_name}-node-pool"
  cluster                  = module.gke.name
  project_id               = module.project_factory.project_id
  machine_type             = var.worker_size
  location                 = var.region
  min_node_count           = var.min_nodes
  max_node_count           = var.max_nodes
  disk_size_gb             = var.disk_size_gb
  disk_type                = var.disk_type
  image_type               = var.node_image_type
  auto_repair              = var.auto_repair
  auto_upgrade             = var.auto_upgrade
  service_account          = module.service_accounts.service_account.email
  initial_node_count       = var.min_nodes
  oauth_scopes             = var.gke_node_pool_oauth_scopes
  tags                     = var.gke_node_pool_tags
  workload_metadata_config = var.workload_metadata_config

  labels = {
    all-pools = "true"
  }
  depends_on = [
    module.gke,
    module.service_accounts,
    module.project_factory
  ]
}
