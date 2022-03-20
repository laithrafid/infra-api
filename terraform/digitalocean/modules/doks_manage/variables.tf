variable "DIGITALOCEAN_TOKEN" {
    type = string
    sensitive = true   
}
variable "cluster_name" {
  type = string
}

variable "cluster_id" {
  type = string
}

variable "write_kubeconfig" {
  type        = bool
  default     = false
}