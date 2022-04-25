terraform {
  cloud {
    organization = "bayt"
    hostname = "app.terraform.io"
    workspaces {
      name = "infra-api-aws-cluster"
      }
  }
  required_version = ">= 0.15.0"
  required_providers {
    aws = {
        configuration_aliases = [aws.files]
        source = "hashicorp/aws"
        version = "4.11.0"
        }
  }
}
provider "aws" {
  region      = var.region
  access_key  = var.AWS_KOPS_ACCESS_KEY_ID
  secret_key  = var.AWS_KOPS_SECRET_ACCESS_KEY
}
provider "aws" {
  alias  = "files"
  region      = var.region
  access_key  = var.AWS_KOPS_ACCESS_KEY_ID
  secret_key  = var.AWS_KOPS_SECRET_ACCESS_KEY
}