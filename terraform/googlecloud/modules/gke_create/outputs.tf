output "project_name" {
  value = module.project_create.project_name
}

output "project_id" {
  value = module.project_create.project_id
}

output "project_number" {
  value = module.project_create.project_number
}
output "enabled_apis" {
  description = "Enabled APIs in the project"
  value       = module.project_create.enabled_apis
}
output "quota_overrides" {
  description = "The server-generated names of the quota override."
  value       = var.consumer_quotas
}
output "vpc" {
  value       = module.vpc
  description = "The network info"
}

output "network_name" {
  value       = module.vpc.network_name
  description = "The name of the VPC being created"
}
output "network_self_link" {
  value       = module.vpc.network_self_link
  description = "The URI of the VPC being created"
}
output "subnets" {
  value       = module.vpc.subnets_self_links
  description = "The shared VPC subets"
}

output "subnets_names" {
  value       = [for network in module.vpc.subnets : network.name]
  description = "The names of the subnets being created"
}

output "subnets_ids" {
  value       = [for network in module.vpc.subnets : network.id]
  description = "The IDs of the subnets being created"
}

output "subnets_ips" {
  value       = [for network in module.vpc.subnets : network.ip_cidr_range]
  description = "The IPs and CIDRs of the subnets being created"
}
output "subnets_self_links" {
  value       = [for network in module.vpc.subnets : network.self_link]
  description = "The self-links of subnets being created"
}

output "subnets_regions" {
  value       = [for network in module.vpc.subnets : network.region]
  description = "The region where the subnets will be created"
}

output "subnets_private_access" {
  value       = [for network in module.vpc.subnets : network.private_ip_google_access]
  description = "Whether the subnets will have access to Google API's without a public IP"
}

output "subnets_flow_logs" {
  value       = [for network in module.vpc.subnets : length(network.log_config) != 0 ? true : false]
  description = "Whether the subnets will have VPC flow logs enabled"
}

output "subnets_secondary_ranges" {
  value       = [for network in module.vpc.subnets : network.secondary_ip_range]
  description = "The secondary ranges associated with these subnets"
}
output "cluster_name" {
  value       = module.gke.name
  description = "Cluster name"
}
output "kubernetes_endpoint" {
  sensitive   = true
  value       = module.gke.endpoint
  description = "Cluster endpoint"
}
output "ca_certificate" {
  value       = module.gke.ca_certificate
  sensitive   = true
  description = "Cluster ca certificate (base64 encoded)"
}
output "type" {
  value       = module.gke.type
  description = "Cluster type (regional / zonal)"
}
output "location" {
  value       = module.gke.location
  description = "Cluster location (region if regional cluster, zone if zonal cluster)"
}
output "service_account" {
  value       = module.gke.service_account
  description = "The service account to default running nodes as if not overridden in node_pools."
}


output "budget_amount" {
  description = "The amount to use for the budget"
  value       = var.budget_amount
}

output "budget_alert_spent_percents" {
  description = "The list of percentages of the budget to alert on"
  value       = var.budget_alert_spent_percents
}

output "budget_services" {
  description = "A list of services to be included in the budget"
  value       = var.budget_services
}

output "budget_credit_types_treatment" {
  description = "Specifies how credits should be treated when determining spend for threshold calculations"
  value       = var.budget_credit_types_treatment
}