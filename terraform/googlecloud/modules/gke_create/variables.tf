variable "GOOGLECLOUD_TOKEN" {
  type      = string
  sensitive = true
}
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
  default = ["compute.googleapis.com",
  "container.googleapis.com"]
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
variable "region" {
  type        = string
  description = "The zones to host the cluster in (optional if regional cluster / required if zonal)"
  default     = "northamerica-northeast1"
}
variable "cluster_zones" {
  type = list(string)
  default = [
    "northamerica-northeast1-a",
    "northamerica-northeast1-b",
    "northamerica-northeast1-c"
  ]
}
variable "auto_create_subnetworks" {
  type    = string
  default = "false"
}
variable "delete_default_internet_gateway_routes" {
  type    = string
  default = "true"
}
variable "shared_vpc_host" {
  type    = string
  default = "false"
}
variable "ip_range_nodes" {
  type        = string
  description = "10.10.10.0/24"
}
variable "ip_range_pods" {
  type        = string
  description = "192.168.64.0/24"
}
variable "ip_range_services" {
  type        = string
  description = "192.168.64.0/24"
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
}
# cos_containerd: Container-Optimized OS with containerd.
# cos: Container-Optimized OS with Docker
# ubuntu_containerd: Ubuntu with containerd
# ubuntu: Ubuntu with Docker.
variable "auto_repair" {
  type     = string
  nullable = true

}
variable "auto_upgrade" {
  type        = string
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
  description = "(Optional) Scopes that are used by NAP when creating node pools."
  default     = []
  type        = list(string)
}
variable "gke_node_pool_tags" {
  type        = list(string)
  description = "The list of instance tags applied to all nodes. Tags are used to identify valid sources or targets for network firewalls."
  default     = []
  nullable    = true
}
variable "filestore_csi_driver" {
  type        = bool
  description = "The status of the Filestore CSI driver addon, which allows the usage of filestore instance as volumes"
  default     = false
}
variable "workload_metadata_config" {
  description = "Metadata configuration to expose to workloads on the node pool."
  default = [
    {
      mode = "MODE_UNSPECIFIED"
    }
  ]
  type = list(object({
    mode = string
  }))
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

variable "budget_credit_types_treatment" {
  description = "Specifies how credits should be treated when determining spend for threshold calculations"
  type        = string
  default     = "EXCLUDE_ALL_CREDITS"
}