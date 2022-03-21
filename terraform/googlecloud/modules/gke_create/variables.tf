variable "GOOGLECLOUD_TOKEN" {
  variable = string
  sensitive = true
}
variable "project_name" {
    variable = string
}
variable "billing_account" {
    variable = string
    sensitive = true
}
variable "organization_id" {
    variable = string
    sensitive = true
}
variable "region" {
    variable = string
}
