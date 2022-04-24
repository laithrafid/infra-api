variable "AWS_KOPS_ACCESS_KEY_ID" {
    type = string
    description = "which stage is this cluster should run vaiables from var file .tfvars"
    sensitive = true 
}
variable "AWS_KOPS_SECRET_ACCESS_KEY" {
    type = string
    description = "which stage is this cluster should run vaiables from var file .tfvars"
    sensitive = true 
}
variable "region" {
    type = string
    description = "region of cluster"
    default = "ca-central-1"
}