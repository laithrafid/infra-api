resource "random_id" "project_id" {
  byte_length = 5
}

locals {
  project_id   = "${random_id.project_id.hex}"
  cluster_name = "gke-${local.project_id}"
  network_name = "gke-network-${local.project_id}"
}


resource "google_folder" "folder" {
  display_name = var.folder_name
  parent       = "organizations/${var.organization_id}"
}

module "project-factory" {
  source            = "terraform-google-modules/project-factory/google"
  version           = ">= 12.0.0"
  name              = var.project_name
  project_id	      = local.project_id	
  org_id            = var.organization_id
  billing_account   = var.billing_account
  folder_id         = google_folder.folder.id
  activate_apis     = [ "compute.googleapis.com",
                        "container.googleapis.com" ]
  consumer_quotas	  = [""]
}

module "vpc" {
    source                  = "terraform-google-modules/network/google"
    version                 = ">= 5.0.0"
    project_id              = local.project_id	
    network_name            = local.network_name
    auto_create_subnetworks	= false
    delete_default_internet_gateway_routes = true
    shared_vpc_host         = false
    routing_mode            = "GLOBAL"

    subnets = [
        {
            subnet_name           = var.gke-subnet
            subnet_ip             = "10.10.10.0/24"
            subnet_region         = var.region
        },
        {
            subnet_name           = var.gke_subnet_pods
            subnet_ip             = "10.10.20.0/24"
            subnet_region         = var.region
            subnet_private_access = "true"
            subnet_flow_logs      = "true"
            description           = "This subnet has a description"
        },
        {
            subnet_name               = var.gke_subnet_services
            subnet_ip                 = "10.10.30.0/24"
            subnet_region             = var.region
            subnet_flow_logs          = "true"
            subnet_flow_logs_interval = "INTERVAL_10_MIN"
            subnet_flow_logs_sampling = 0.7
            subnet_flow_logs_metadata = "INCLUDE_ALL_METADATA"
        }
    ]

    secondary_ranges = {
        subnet-01 = [
            {
                range_name    = "subnet-01-secondary-01"
                ip_cidr_range = "192.168.64.0/24"
            },
        ]

        subnet-02 = []
    }

    routes = [
        {
            name                   = "egress-internet"
            description            = "route through IGW to access internet"
            destination_range      = "0.0.0.0/0"
            tags                   = "egress-inet"
            next_hop_internet      = "true"
        },
        {
            name                   = "app-proxy"
            description            = "route through proxy to reach app"
            destination_range      = "10.50.10.0/24"
            tags                   = "app-proxy"
            next_hop_instance      = "app-proxy-instance"
            next_hop_instance_zone = "us-west1-a"
        },
    ]
}

module "gke" {
  source                      = "terraform-google-modules/kubernetes-engine/google"
  project_id                  = project-factory.project_id
  name                        = "${var.project_name}-${var.environment}-${var.cluster_name}"
  region                      = var.cluster_region
  zones                       = [var.cluster_zones]
  network                     = vpc.network_name
  subnetwork                  = var.gke-subnet
  ip_range_pods               = var.gke_subnet_pods
  ip_range_services           = var.gke_subnet_services
  http_load_balancing         = true
  remove_default_node_pool    = true
  network_policy              = false
  horizontal_pod_autoscaling  = true
  filestore_csi_driver        = false
  impersonate_service_account = var.service_account
  node_pools = [
    {
      name                      = "default-node-pool"
      machine_type              = "e2-medium"
      node_locations            = "us-central1-b,us-central1-c"
      min_count                 = 1
      max_count                 = 100
      local_ssd_count           = 0
      disk_size_gb              = 100
      disk_type                 = "pd-standard"
      image_type                = "COS_CONTAINERD"
      auto_repair               = true
      auto_upgrade              = true
      service_account           = "project-service-account@<PROJECT ID>.iam.gserviceaccount.com"
      preemptible               = false
      initial_node_count        = 80
    },
  ]

  node_pools_oauth_scopes = {
    all = []

    default-node-pool = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  node_pools_labels = {
    all = {}

    default-node-pool = {
      default-node-pool = true
    }
  }

  node_pools_metadata = {
    all = {}

    default-node-pool = {
      node-pool-metadata-custom-value = "my-node-pool"
    }
  }

  node_pools_taints = {
    all = []

    default-node-pool = [
      {
        key    = "default-node-pool"
        value  = true
        effect = "PREFER_NO_SCHEDULE"
      },
    ]
  }

  node_pools_tags = {
    all = []

    default-node-pool = [
      "default-node-pool",
    ]
  }
}