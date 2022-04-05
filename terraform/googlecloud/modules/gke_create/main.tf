resource "random_id" "random_project_id_suffix" {
  byte_length = 2
}

locals {
  project_id   = "${var.project_name}-${random_id.random_project_id_suffix.hex}"
  cluster_name = "gke-${local.project_id}}"
  network_name = "gke-network-${var.project_name}"
  nodes-subnet = "${local.network_name}-subnet-nodes"
  pods-subnet = "${local.network_name}-subnet-pods"
  services-subnet = "${local.network_name}-subnet-services"
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
resource "google_pubsub_topic" "budget" {
  name    = "budget-topic-${module.project_factory.project_id}"
  project = module.project_factory.project_id
}
module "budget_project_factory" {
  source                 = "terraform-google-modules/project-factory/google"
  version                = ">= 12.0.0"
  billing_account        = var.billing_account
  budget_display_name    = "${module.project_factory.project_id}-budget"
  projects               = [module.project_factory.project_id]
  amount                 = var.budget_amount
  credit_types_treatment = var.budget_credit_types_treatment
  services               = var.budget_services
  alert_spent_percents   = var.budget_alert_spent_percents
  alert_pubsub_topic     = "projects/${module.project_factory.project_id}/topics/${google_pubsub_topic.budget.name}"
  labels                = {
    "cost-center" : "bayt-training"
  }
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
      subnet_name               = "${local.nodes-subnet}"
      subnet_ip                 = "${var.ip_range_nodes}"
      subnet_region             = "${var.region}"
      subnet_private_access     = "true"
      subnet_flow_logs          = "true"
      subnet_flow_logs_interval = "INTERVAL_10_MIN"
      subnet_flow_logs_sampling = 0.7
      subnet_flow_logs_metadata = "INCLUDE_ALL_METADATA"
      description               = "this subnet for GKE Cluster masters/nodes"
    },
  ]
  secondary_ranges = {
    (local.nodes-subnet) = [
      {
        range_name    = "${local.pods-subnet}"
        ip_cidr_range = var.ip_range_pods
      },
       {
        range_name    = "${local.services-subnet}"
        ip_cidr_range = var.ip_range_services
      },
    ]
  }
   firewall_rules = [
    {
      name      = "allow-ssh-ingress"
      direction = "INGRESS"
      ranges    = ["0.0.0.0/0"]
      allow = [{
        protocol = "tcp"
        ports    = ["22"]
      }]
      log_config = {
        metadata = "INCLUDE_ALL_METADATA"
      }
    },
    {
      name      = "deny-udp-egress"
      direction = "INGRESS"
      ranges    = ["0.0.0.0/0"]
      deny = [{
        protocol = "udp"
        ports    = null
      }]
    },
  ]
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
  source                     = "terraform-google-modules/kubernetes-engine/google"
  version                    = "20.0.0"
  project_id                 = module.project_factory.project_id
  name                       = var.cluster_name
  region                     = var.region
  zones                      = var.cluster_zones
  network                    = module.vpc.network_name
  subnetwork                 = "${module.vpc.subnets_names[0]}"
  ip_range_pods              = "${local.pods-subnet}"
  ip_range_services          = "${local.services-subnet}"
  http_load_balancing        = var.http_load_balancing
  remove_default_node_pool   = var.remove_default_node_pool
  network_policy             = var.network_policy
  horizontal_pod_autoscaling = var.horizontal_pod_autoscaling
  filestore_csi_driver       = var.filestore_csi_driver
  create_service_account     = true
  depends_on = [
    module.project_factory,
    module.vpc,
  ]
}
module "gke_node_pools" {
  source                   = "./gke_create_node_pool"
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
  service_account          = module.gke.service_account
  initial_node_count       = var.min_nodes
  oauth_scopes             = var.gke_node_pool_oauth_scopes
  tags                     = var.gke_node_pool_tags
  workload_metadata_config = var.workload_metadata_config

  labels = {
    all-pools = "true"
  }
  depends_on = [
    module.gke,
    module.project_factory
  ]
}
