terraform {
  cloud {
    organization = "bayt"
    hostname = "app.terraform.io"
    workspaces {
      name = "infra-api-aws-pre"
      }
  }
  required_version = ">= 0.15.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.11.0"
    }
  }
}

provider "aws" {
  region      = var.region
  access_key  = var.access_key_id
  secret_key  = var.secret_access_key
}