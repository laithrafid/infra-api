resource "random_id" "project_id" {
  byte_length = 5
}

locals {
  project_id   = "${random_id.project_id.hex}"
  cluster_name = "gke-${local.project_id}"
  network_name = "gke-network-${local.project_id}"
}


resource "google_folder" "folder" {
  display_name = var.project_folder
  parent       = "organizations/${var.organization_id}"
}

module "project_factory" {
  source            = "terraform-google-modules/project-factory/google"
  version           = ">= 12.0.0"
  name              = var.project_name
  project_id	    = local.project_id	
  org_id            = var.organization_id
  billing_account   = var.billing_account
  folder_id         = google_folder.folder.id
  activate_apis     = [var.activate_apis]
  consumer_quotas   = [var.consumer_quotas]
}


module "service_accounts" {
  source        = "terraform-google-modules/service-accounts/google"
  version       = ">= 4.0.0"
  project_id    = module.project_factory.project_id
  prefix        = "dev-sa"
  generate_keys = true
  names         = ["gke-${prefix}"]
  project_roles = [
    "${module.project_factory.project_name}=>roles/container.admin",
    "${module.project_factory.project_name}=>roles/container.clusterAdmin",
    "${module.project_factory.project_name}=>roles/container.clusterViewer",
    "${module.project_factory.project_name}=>roles/container.developer",
    "${module.project_factory.project_name}=>roles/container.hostServiceAgentUser",
    "${module.project_factory.project_name}=>roles/container.viewer"
  ]
  depends_on = [
    module.project_factory
  ]
}
module "vpc" {
    source                  = "terraform-google-modules/network/google"
    version                 = ">= 5.0.0"
    project_id              = module.project_factory.project_id	
    network_name            = local.network_name
    auto_create_subnetworks	= var.auto_create_subnetworks
    delete_default_internet_gateway_routes = var.delete_default_internet_gateway_routes
    shared_vpc_host         = var.shared_vpc_host
    routing_mode            = "GLOBAL"
    depends_on = [
      module.project_factory
    ]

    subnets = [
        {
            subnet_name               = "${local.network_name}-subnet"
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
            subnet_name               = "${local.network_name}-subnet_pods"
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
            subnet_name               = "${local.network_name}-subnet_services"
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

    secondary_ranges = {
        "${local.network_name}-subnet" = [
            {
                range_name    = "${local.network_name}-subnet-secondary-01"
                ip_cidr_range = var.ip_range_nodes_sec
            },
        ]
        "${local.network_name}-subnet_pods" = [
            {
                range_name    = "${local.network_name}-subnet_pods-secondary-01"
                ip_cidr_range = var.ip_range_pods_sec 
            },
        ]
         "${local.network_name}-subnet_services" = [
            {
                range_name    = "${local.network_name}-subnet_services-secondary-01"
                ip_cidr_range = var.ip_range_services_sec 
            },
        ]
    }

    routes = [
        {
            name                   = "egress-internet-${local.network_name}"
            description            = "route through  IGW to access internet"
            destination_range      = "0.0.0.0/0"
            tags                   = "egress-gke"
            next_hop_internet      = "true"
        },
        {
            name                   = "ingress-internet-to-${local.network_name}"
            description            = "route through proxy to reach app"
            destination_range      = "Loadbalancer/23"
            tags                   = "ingress-gke"
            next_hop_instance      = "app-proxy-instance"
            next_hop_instance_zone = var.cluster_zones
        },
    ]
}

module "gke" {
  source                      = "terraform-google-modules/kubernetes-engine/google"
  project_id                  = module.project_factory.project_id
  name                        = "${var.project_name}-${var.environment}-${var.cluster_name}"
  region                      = var.region
  zones                       = [var.cluster_zones]
  network                     = vpc.network_name
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
  source                    = "../gke_create_node_pool"
  name                      = "${var.project_name}-${var.environment}-${var.cluster_name}-node-pool"
  cluster                   = gke.name
  project_id                = module.project_factory.project_id
  machine_type              = var.worker_size
  location                  = var.region ? null : [var.cluster_zones]
  min_node_count            = var.min_nodes
  max_node_count            = var.max_nodes
  disk_size_gb              = var.disk_size_gb
  disk_type                 = var.disk_type
  local_ssd_count           = var.nodelocal_ssd_count
  image_type                = var.node_image_type
  auto_repair               = var.auto_repair
  auto_upgrade              = var.auto_upgrade
  service_account           = module.service_accounts.service_account.email
  preemptible               = var.preemptible
  initial_node_count        = var.min_nodes
  oauth_scopes              = [var.gke_node_pool_oauth_scopes]
  tags                      = [var.gke_node_pool_tags]
  labels = {
    all-pools     = "true"
  }
  depends_on = [
      module.gke,
      module.service_accounts,
      module.project_factory
  ]
}
