output "project_name" {
  value = module.project_factory.project_name
}

output "project_id" {
  value = module.project_factory.project_id
}

output "project_number" {
  value = module.project_factory.project_number
}
output "enabled_apis" {
  description = "Enabled APIs in the project"
  value       = module.project_factory.enabled_apis
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

output "email" {
  description = "The service account email."
  value       = module.service_accounts.service_account.email
}
output "key" {
  description = "The service account email."
  value       = module.service_accounts.service_account.key
  sensitive = true
}
output "iam_email" {
  description = "The service account IAM-format email."
  value       = module.service_accounts.iam_email
}
output "cluster_location" {
  value = module.gke.location
}
output "cluster_name" {
  value = module.gke.name
}
output "kubernetes_endpoint" {
  sensitive = true
  value     = module.gke.endpoint
}
output "ca_certificate" {
  value = module.gke.ca_certificate
}