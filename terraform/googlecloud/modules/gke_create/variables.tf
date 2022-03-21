variable "GOOGLECLOUD_TOKEN" {
  type = string
  sensitive = true
}
variable "folder_name" {
    type = string
}
variable "organization_id" {
    type = string
    sensitive = true
}
variable "project_name" {
    type = string
}
variable "billing_account" {
    type = string
    sensitive = true
}
variable "auto_create_subnetworks" {
    type = string
    default = "false"
}
variable "delete_default_internet_gateway_routes" {
  type = string 
  default = "true"
}
variable "shared_vpc_host" {
  type = string 
  default = "false"
}
variable "region" {
    type = string
    default = "northamerica-northeast1"
}
variable "ip_range_nodes" {
  type = string
  default = "10.10.10.0/24"
}
variable "ip_range_nodes_sec" {
  type = string
  default = "192.168.64.0/24"
}
variable "ip_range_pods" {
  type = string
  default = "10.10.20.0/16"
}
variable "ip_range_pods_sec" {
  type = string
  default = "192.168.65.0/16"
}
variable "ip_range_services" {
  type = string
  default = "10.10.30.0/24"
}
variable "ip_range_services_sec" {
  type = string
  default = "192.168.66.0/16"
}

variable "cluster_zones" {
    type = list  
    default = [
        "northamerica-northeast1-a",
        "northamerica-northeast1-b",
        "northamerica-northeast1-c"
    ]
}
variable "worker_size" {
  type = string
  default = "t2d-standard-1"
  description = "machine_type , if no value provided defaults"
}

variable "auto_scale" {
  type        = bool
  default     = false
}
variable "min_nodes" {
  type = number
  description = "minmum number of nudes in cluster"
  default = 3
}
variable "max_nodes" {
  type = number
  description = "release 1.18, GKE supports up to 15,000 nodes in a single cluster"
  default = 4
}
