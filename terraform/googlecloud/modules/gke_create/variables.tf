variable "GOOGLECLOUD_TOKEN" {
  type      = string
  sensitive = true
}
# variable "credentials_path" {
#   type = string
#   sensitive = true
# }
variable "environment" {
  type    = string
  default = "dev"
}
variable "billing_account" {
  type      = string
  sensitive = true
}
variable "cluster_name" {
  type    = string
  default = "gke"
}
variable "project_folder" {
  type = string
}
variable "project_name" {
  type = string
}
variable "organization_id" {
  type      = string
  sensitive = true
}
variable "activate_apis" {
  type = list(string)
  default = [
    "compute.googleapis.com",
    "serviceusage.googleapis.com",
    "container.googleapis.com",
    "servicemanagement.googleapis.com",
    "servicecontrol.googleapis.com",
    "endpoints.googleapis.com",
    "servicenetworking.googleapis.com",
    "logging.googleapis.com",
    "bigquery.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "billingbudgets.googleapis.com",
    "cloudbilling.googleapis.com",
    "iam.googleapis.com",
    "admin.googleapis.com",
    "appengine.googleapis.com",
    "storage-api.googleapis.com",
    "monitoring.googleapis.com"
  ]
}
variable "lien" {
  description = "Add a lien on the project to prevent accidental deletion"
  type        = bool
  default     = false
}
variable "consumer_quotas" {
  description = "The quotas configuration you want to override for the project."
  type = list(object({
    service = string,
    metric  = string,
    limit   = string,
    value   = string,
  }))
  default = []
}
variable "subnets" {
  description = "The list of subnets being created"
  type = list(object({
    subnet_name               = string
    subnet_ip                 = string
    subnet_region             = string
    subnet_flow_logs          = string
    subnet_flow_logs_interval = string
    subnet_flow_logs_sampling = string
    subnet_flow_logs_metadata = string
  }))
  default = [{
    subnet_name               = "gke-network-subnet-nodes"
    subnet_ip                 = "10.1.0.0/16"
    subnet_region             = "example-region"
    subnet_flow_logs          = "true"
    subnet_flow_logs_interval = "INTERVAL_10_MIN"
    subnet_flow_logs_sampling = 0.7
    subnet_flow_logs_metadata = "INCLUDE_ALL_METADATA"
  }, ]
}
variable "secondary_ranges" {
  description = "Secondary ranges that will be used in some of the subnets"
  type = map(list(object({
    range_name = string,
    ip_cidr_range = string })
    )
  )
  default = {
    "gke-network-subnet-nodes" = [{
      ip_cidr_range = "5.0.0.0/16"
      range_name    = "gke-network-subnet-pods"
      },
      {
        ip_cidr_range = "5.1.0.0/16"
        range_name    = "gke-network-subnet-services"
    }]
  }
}
variable "firewall_rules" {
  default     = []
  description = "List of firewall rules"
  type = list(object({
    name                    = string
    description             = string
    direction               = string
    priority                = number
    ranges                  = list(string)
    source_tags             = list(string)
    source_service_accounts = list(string)
    target_tags             = list(string)
    target_service_accounts = list(string)
    allow = list(object({
      protocol = string
      ports    = list(string)
    }))
    deny = list(object({
      protocol = string
      ports    = list(string)
    }))
    log_config = object({
      metadata = string
    })
  }))
}
variable "routes" {
  description = "List of routes being created in this VPC"
  type = list(map(string))
  default = []
}
variable "bastion_members" {
  type        = list(string)
  description = "members of List of users, groups, SAs who have access to bastion node and gke cluster"
  default     = []
}
variable "routing_mode" {
  description = "The network routing mode (default 'GLOBAL')	"
  type        = string
  default     = "GLOBAL"
}

variable "region" {
  type        = string
  description = "The zones to host the cluster in (optional if regional cluster / required if zonal)"
  default     = "northamerica-northeast1"
}
variable "cluster_zones" {
  type        = list(string)
  description = "The zones to host the cluster in (optional if regional cluster / required if zonal)"
  default = [
    "northamerica-northeast1-a",
    "northamerica-northeast1-b",
    "northamerica-northeast1-c"
  ]
}
variable "cluster_type_regional" {
  type        = bool
  description = "Whether is a regional cluster (zonal cluster if set false. WARNING: changing this after cluster creation is destructive!)"
  default     = true
}
variable "gke_node_locations" {
  type        = string
  description = "The list of zones in which the cluster's nodes are located. Nodes must be in the region of their regional cluster or in the same region as their cluster's zone for zonal clusters. Defaults to cluster level node locations if nothing is specified"
  default     = "northamerica-northeast1-a, northamerica-northeast1-b, northamerica-northeast1-c"
}
variable "auto_create_subnetworks" {
  type    = bool
  default = false
}
variable "delete_default_internet_gateway_routes" {
  type    = bool
  default = true
}
variable "shared_vpc_host" {
  type    = bool
  default = false
}
variable "worker_size" {
  type        = string
  default     = "t2d-standard-1"
  description = "machine_type , if no value provided defaults"
}
variable "use_private_endpoint" {
  type        = bool
  default     = "false"
  description = "private cluster endpoint"
}
variable "auto_scale" {
  type    = bool
  default = false
}
variable "min_nodes" {
  type        = number
  description = "minimum number of nudes in cluster, if no autoscale this number will be initial_node_count of your cluster"
  default     = 3
}
variable "max_nodes" {
  type        = number
  description = "release 1.18, GKE supports up to 15,000 nodes in a single cluster"
  default     = 4
}

variable "disk_size_gb" {
  default     = 30
  description = "(Optional) Size of the disk attached to each node, specified in GB. The smallest allowed disk size is 10GB"
}

variable "disk_type" {
  default     = "pd-standard"
  description = "(Optional) Type of the disk attached to each node (e.g. 'pd-standard', 'pd-balanced' or 'pd-ssd')."
}
variable "node_image_type" {
  type        = string
  nullable    = true
  description = "(Optional) The default image type used by NAP once a new node pool is being created. Please note that according to the official documentation the value must be one of the [COS_CONTAINERD, COS, UBUNTU_CONTAINERD, UBUNTU]."
  default     = "COS_CONTAINERD"
}
# cos_containerd: Container-Optimized OS with containerd.
# cos: Container-Optimized OS with Docker
# ubuntu_containerd: Ubuntu with containerd
# ubuntu: Ubuntu with Docker.
variable "auto_repair" {
  type     = bool
  nullable = true

}
variable "auto_upgrade" {
  type        = bool
  nullable    = true
  description = "auto updgrade nodes os"
}
# Preemptible VMs are Compute Engine VM instances that last a maximum of 24 hours, and provide no availability guarantees. 
# Preemptible VMs offer similar functionality to Spot VMs, but only last up to 24 hours after creation.

# In some cases, a preemptible VM might last longer than 24 hours. This can occur when the new Compute Engine instance comes
# up too fast and Kubernetes doesn't recognize that a different Compute Engine VM was created. The underlying Compute Engine
# instance will have a maximum duration of 24 hours and follow the expected preemptible VM behavior.
variable "is_preemptible" {
  type        = bool
  nullable    = true
  description = "(Optional) A boolean that represents whether or not the underlying node VMs are preemptible. See the official documentation for more information. Defaults to false."
  default     = false
}
variable "http_load_balancing" {
  type        = bool
  default     = true
  description = "Enable httpload balancer addon"
}
variable "horizontal_pod_autoscaling" {
  type        = bool
  default     = false
  description = "Enable horizontal pod autoscaling addon"
}
variable "network_policy" {
  type        = bool
  default     = false
  description = "Enable network policy addon"
}
variable "remove_default_node_pool" {
  type        = bool
  default     = false
  description = "Remove default node pool while setting up the cluster"
}
variable "gke_node_pool_oauth_scopes" {
  nullable    = true
  type        = map(list(string))
  description = "Map of lists containing node oauth scopes by node-pool name Scopes that are used by NAP when creating node pools."
  default = {
    all               = ["https://www.googleapis.com/auth/cloud-platform"]
    default-node-pool = []
  }
}
variable "gke_node_pool_tags" {
  type        = map(list(string))
  description = "The list of instance tags applied to all nodes. Tags are used to identify valid sources or targets for network firewalls."
  default = {
    all               = []
    default-node-pool = []
  }
  nullable = true
}
variable "filestore_csi_driver" {
  type        = bool
  description = "The status of the Filestore CSI driver addon, which allows the usage of filestore instance as volumes"
  default     = false
}
variable "local_ssd_count" {
  type        = number
  description = "number of locally attached ssds to node"
  default     = 0
}
variable "gke_node_pools_metadata" {
  type        = map(map(string))
  description = "Metadata configuration to expose to workloads on the node pool."
  default = {
    all               = {},
    default-node-pool = {}
  }
}
variable "kubernetes_version" {
  type    = string
  default = "latest"
}
variable "monitoring_service" {
  type        = string
  description = "The monitoring service that the cluster should write metrics to. Automatically send metrics from pods in the cluster to the Google Cloud Monitoring API. VM metrics will be collected by Google Compute Engine regardless of this setting Available options include monitoring.googleapis.com, monitoring.googleapis.com/kubernetes (beta) and none"
  default     = "monitoring.googleapis.com/kubernetes"
}
variable "logging_service" {
  type        = string
  description = "The logging service that the cluster should write logs to. Available options include logging.googleapis.com, logging.googleapis.com/kubernetes (beta), and none	"
  default     = "logging.googleapis.com/kubernetes"
}
variable "cluster_specific_service_account" {
  type        = bool
  default     = true
  description = "Defines if service account specified to run nodes should be created, The service account to run nodes as if not overridden in node_pools. The create_service_account variable default value (true) will cause a cluster-specific service account to be created."
}
variable "budget_amount" {
  description = "The amount to use for the budget"
  default     = 10
  type        = number
}

variable "budget_alert_spent_percents" {
  description = "The list of percentages of the budget to alert on"
  type        = list(number)
  default     = [0.7, 0.8, 0.9, 1.0]
}

variable "budget_services" {
  description = "A list of services to be included in the budget https://cloud.google.com/skus/"
  type        = list(string)
  default = [
    "6F81-5844-456A", # Compute Engine
    "CCD8-9BF1-090E", # Kubernetes Engine
    "A1E8-BE35-7EBC", # Pub/Sub
    "9186-F79E-3871", # Anthos
    "36A9-155B-23F0", # API Gateway
    "149C-F9EC-3994", # Artifact Registry
    "CD87-46A2-EE79", # Anthos Config Management
    "3DAD-B96D-BE09", # Anthos Service Mesh
    "E505-1604-58F8"  # Networking
  ]
}
variable "budget_alert_spend_basis" {
  description = "The type of basis used to determine if spend has passed the threshold"
  type        = string
  default     = "CURRENT_SPEND"
}

variable "budget_credit_types_treatment" {
  description = "Specifies how credits should be treated when determining spend for threshold calculations example INCLUDE_ALL_CREDITS"
  type        = string
  default     = "EXCLUDE_ALL_CREDITS"
}
variable "gke_node_pools_taints" {
  description = "Map of lists containing node taints by node-pool name"
  type        = map(list(object({ key = string, value = string, effect = string })))
  default = {
    all               = []
    default-node-pool = []
  }
}
variable "gke_node_pools_labels" {
  description = "Map of maps containing node labels by node-pool name	"
  type        = map(map(string))
  default = {
    all               = {}
    default-node-pool = {}
  }
}
variable "notification_channels" {
  type        = object({ number = string, email = string })
  description = "notification methods will be created"
  default = {
    email  = ""
    number = ""
  }
}
