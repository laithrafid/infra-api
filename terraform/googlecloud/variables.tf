variable "GOOGLECLOUD_TOKEN" {
  variable = string
  sensitive = true
}
variable "project_name" {
    variable = string
}
variable "billing_account" {
    variable = string
    default = "01F6E0-CAEE0D-ECCF35"
    sensitive = true
}
variable "org_id" {
    variable = string
    default = "27775405036"
    sensitive = true
}
variable "region" {
    variable = string
}
