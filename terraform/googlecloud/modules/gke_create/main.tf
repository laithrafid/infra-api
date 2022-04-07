resource "random_id" "random_project_id_suffix" {
  byte_length = 2
}

locals {
  project         = "${var.project_name}-${random_id.random_project_id_suffix.hex}"
  project_id      = local.project
  cluster_name    = "gke-${local.project_id}}"
  network_name    = "gke-network-${var.project_name}"
  nodes-subnet    = "${local.network_name}-subnet-nodes"
  pods-subnet     = "${local.network_name}-subnet-pods"
  services-subnet = "${local.network_name}-subnet-services"
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
resource "google_pubsub_topic" "budget" {
  name    = "budget-topic-${var.project_name}"
  project = module.project_create.project_id
}
resource "google_monitoring_notification_channel" "email" {
  project      = module.project_create.project_id
  display_name = "Email Channel"
  type         = "email"
  labels = {
    email_address = "${var.notification_channels.email}"
  }
  depends_on = [
    module.project_create
  ]
}
resource "google_monitoring_notification_channel" "sms" {
  project      = module.project_create.project_id
  display_name = "SMS Channel"
  type         = "sms"
  labels = {
    number = "${var.notification_channels.number}"
  }
  depends_on = [
    module.project_create
  ]
}
data "google_pubsub_topic" "budget" {
  name = "budget-topic-${var.project_name}"
  depends_on = [
    google_pubsub_topic.budget
  ]
}
data "google_monitoring_notification_channel" "sms" {
  display_name = "SMS Channel"
  depends_on = [
    google_monitoring_notification_channel.sms
  ]
}
data "google_monitoring_notification_channel" "email" {
  display_name = "Email Channel"
  depends_on = [
    google_monitoring_notification_channel.email
  ]
}

module "project_config" {
  source                      = "terraform-google-modules/project-factory/google"
  version                     = ">= 12.0.0"
  name                        = module.project_create.project_name
  project_id                  = module.project_create.project_id
  billing_account             = var.billing_account
  org_id                      = var.organization_id
  consumer_quotas             = var.consumer_quotas
  budget_alert_pubsub_topic   = "projects/${module.project_create.project_id}/topics/${data.google_pubsub_topic.budget.name}"
  budget_alert_spent_percents = var.budget_alert_spent_percents
  budget_amount               = var.budget_amount
  budget_display_name         = data.google_pubsub_topic.budget.name
  budget_monitoring_notification_channels = ["${data.google_monitoring_notification_channel.sms.name}",
  "${data.google_monitoring_notification_channel.email.name}"]
  depends_on = [
    google_pubsub_topic.budget,
    google_monitoring_notification_channel.email,
    google_monitoring_notification_channel.sms

  ]
}
module "vpc" {
  source                                 = "terraform-google-modules/network/google"
  version                                = ">= 5.0.0"
  project_id                             = module.project_create.project_id
  network_name                           = local.network_name
  auto_create_subnetworks                = var.auto_create_subnetworks
  delete_default_internet_gateway_routes = var.delete_default_internet_gateway_routes
  shared_vpc_host                        = var.shared_vpc_host
  routing_mode                           = "GLOBAL"
  depends_on = [
    module.project_config
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
  kubernetes_version         = var.kubernetes_version
  monitoring_service         = var.monitoring_service
  logging_service            = var.logging_service
  project_id                 = module.project_create.project_id
  name                       = var.cluster_name
  region                     = var.region
  regional                   = var.cluster_type
  zones                      = var.cluster_zones
  network                    = module.vpc.network_name
  subnetwork                 = module.vpc.subnets_names[0]
  ip_range_pods              = local.pods-subnet
  ip_range_services          = local.services-subnet
  http_load_balancing        = var.http_load_balancing
  remove_default_node_pool   = var.remove_default_node_pool
  network_policy             = var.network_policy
  horizontal_pod_autoscaling = var.horizontal_pod_autoscaling
  filestore_csi_driver       = var.filestore_csi_driver
  create_service_account     = var.cluster_specific_service_account
  node_pools_oauth_scopes    = var.gke_node_pool_oauth_scopes
  node_pools_metadata        = var.node_pools_metadata
  node_pools_tags            = var.gke_node_pool_tags
  node_pools_labels          = var.node_pools_labels
  node_pools_taints          = var.node_pools_taints
  node_pools = [
    {
      name               = "${var.project_name}-${var.environment}-${var.cluster_name}-node-pool"
      machine_type       = var.worker_size
      node_locations     = "${var.node_locations}"
      min_count          = var.min_nodes
      max_count          = var.max_nodes
      local_ssd_count    = var.local_ssd_count
      disk_size_gb       = var.disk_size_gb
      disk_type          = var.disk_type
      image_type         = var.node_image_type
      auto_repair        = var.auto_repair
      auto_upgrade       = var.auto_upgrade
      preemptible        = var.is_preemptible
      initial_node_count = var.min_nodes
    },
  ]
  depends_on = [
    module.project_create,
    module.vpc,
  ]
}