variable "access_key_id" {
  type = string 
  description = "Access Key ID of your aws account"
  sensitive = true 
}
variable "secret_access_key" {
  type = string
  description = "Secret Access Key of your aws account"
  sensitive = true
}
variable "stage" {
  type = string
  description = "which stage is this cluster should run vaiables from var file .tfvars"
  default = "dev"
}
variable "region" {
  type = string
  description = "region of cluster"
  default = "ca-central-1"
}
variable "kops_state" {
  type = string
  description = "bucket where kops state files will be saved"
  default = "kopsdev-state"
}
