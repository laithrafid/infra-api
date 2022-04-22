resource "random_id" "random_project_id_suffix" {
  byte_length = 2
}

locals {
  project         = "${var.project_name}-${random_id.random_project_id_suffix.hex}"
  project_id      = local.project
  cluster_name    = "gke-${local.project_id}"
  network_name    = "gke-network"
  nodes-subnet    = "gke-network-subnet-nodes"
  pods-subnet     = "gke-network-subnet-pods"
  services-subnet = "gke-network-subnet-services"
  nodepool_name   = "${var.project_name}-${var.environment}-${var.cluster_name}-node-pool"
  bastion_name    = format("%s-bastion", var.cluster_name)
  bastion_zone    = format("%s-a", var.region)
}

data "template_file" "startup_script" {
  template = <<-EOF
  sudo apt-get update -y
  sudo apt-get install -y tinyproxy
  EOF
}

resource "google_folder" "folder" {
  display_name = var.project_folder
  parent       = "organizations/${var.organization_id}"
}


module "project_create" {
  source            = "terraform-google-modules/project-factory/google"
  version           = ">= 12.0.0"
  name              = var.project_name
  project_id        = local.project_id
  org_id            = var.organization_id
  billing_account   = var.billing_account
  activate_apis     = var.activate_apis
  folder_id         = google_folder.folder.id
  create_project_sa = false
  lien              = var.lien
  depends_on = [
    google_folder.folder
  ]
}

# module "project_config" {
#   source                      = "./project_config/"
#   amount                      = var.budget_amount
#   billing_account             = var.billing_account
#   create_budget               = true
#   credit_types_treatment      = var.budget_credit_types_treatment
#   notification_channels_email = var.notification_channels.email
#   notification_channels_sms   = var.notification_channels.number
#   project_id                  = module.project_create.project_id
#   project_name                = var.project_name
#   services                    = var.budget_services
#   alert_spent_percents        = var.budget_alert_spent_percents
#   alert_spend_basis           = var.budget_alert_spend_basis
#   depends_on = [
#     module.project_create
#   ]
# }
module "vpc" {
  source                                 = "terraform-google-modules/network/google"
  version                                = ">= 5.0.0"
  project_id                             = module.project_create.project_id
  network_name                           = local.network_name
  auto_create_subnetworks                = var.auto_create_subnetworks
  delete_default_internet_gateway_routes = var.delete_default_internet_gateway_routes
  shared_vpc_host                        = var.shared_vpc_host
  routing_mode                           = var.routing_mode
  subnets                                = var.subnets
  secondary_ranges                       = var.secondary_ranges
  firewall_rules                         = var.firewall_rules
  routes                                 = var.routes
  depends_on = [
    #module.project_config
    module.project_create
  ]
}

module "gke" {
  source                     = "terraform-google-modules/kubernetes-engine/google"
  version                    = "20.0.0"
  kubernetes_version         = var.kubernetes_version
  monitoring_service         = var.monitoring_service
  logging_service            = var.logging_service
  project_id                 = module.project_create.project_id
  name                       = var.cluster_name
  region                     = var.region
  regional                   = var.cluster_type_regional
  zones                      = var.cluster_zones
  network                    = module.vpc.network_name
  subnetwork                 = module.vpc.subnets_names[0]
  ip_range_pods              = module.vpc.subnets_secondary_ranges[0].*.range_name[0]
  ip_range_services          = module.vpc.subnets_secondary_ranges[0].*.range_name[1]
  http_load_balancing        = var.http_load_balancing
  remove_default_node_pool   = var.remove_default_node_pool
  network_policy             = var.network_policy
  horizontal_pod_autoscaling = var.horizontal_pod_autoscaling
  filestore_csi_driver       = var.filestore_csi_driver
  create_service_account     = var.cluster_specific_service_account
  node_pools_oauth_scopes    = var.gke_node_pool_oauth_scopes
  node_pools_metadata        = var.gke_node_pools_metadata
  node_pools_tags            = var.gke_node_pool_tags
  node_pools_labels          = var.gke_node_pools_labels
  node_pools_taints          = var.gke_node_pools_taints
  node_pools = [
    {
      name               = "${local.nodepool_name}"
      machine_type       = "${var.worker_size}"
      node_locations     = "${var.gke_node_locations}"
      min_count          = "${var.min_nodes}"
      max_count          = "${var.max_nodes}"
      local_ssd_count    = "${var.local_ssd_count}"
      disk_size_gb       = "${var.disk_size_gb}"
      disk_type          = "${var.disk_type}"
      image_type         = "${var.node_image_type}"
      auto_repair        = "${var.auto_repair}"
      auto_upgrade       = "${var.auto_upgrade}"
      preemptible        = "${var.is_preemptible}"
      initial_node_count = "${var.min_nodes}"
    },
  ]
  depends_on = [
    module.project_create,
    module.vpc,
  ]
}