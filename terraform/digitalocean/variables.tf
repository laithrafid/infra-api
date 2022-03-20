variable "TERRAFORMCLOUD_TOKEN" {
  type = string
  sensitive = true
}
variable "DIGITALOCEAN_TOKEN" {
    type = string
    sensitive = true   
}
variable "project_name" {
  type = string
  default = "doks"
}
variable "environment" {
  type = string
}
variable "cluster_region" {
    type = string
    description = "region where cluster should be based, New York 1 is default"
    default = "nyc1"
}
variable "cluster_version" {
  type = string
  default = "1.22.7-do.0"
}
variable "worker_size" {
  type = string
  description = "droplet type , if no value provided defaults"
  default = "s-2vcpu-4gb"
}
variable "max_nodes" {
  type = number
  description = "number of worker nodes less than 5000 nodes for a cluster"
  default = 3
}
variable "auto_scale" {
  type        = bool
  default     = false
}
variable "min_nodes" {
  type = number
  description = "minmum number of nudes in cluster"
  default = 1
}
variable "write_kubeconfig" {
  type        = bool
  default     = false
}