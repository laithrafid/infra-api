output "project_id" {
  value       = module.project-factory.project_id
  description = "The GCP project you want to enable APIs on"
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