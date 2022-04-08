terraform {
  cloud {
    organization = "bayt"
    hostname     = "app.terraform.io"
    workspaces {
      name = "intra-api-googlecloud"
      //tags = ["APIs:digitalocean"]
    }
  }
  required_version = ">= 0.13"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.16.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 4.16.0"
    }
    gsuite = {
      source  = "hashicorp/googleworkspace"
      version = ">= 0.6.0"
    }
  }
}

provider "google" {
  project      = var.project_name
  region       = var.region
  access_token = var.GOOGLECLOUD_TOKEN
  #user_project_override = true
  # credentials  = "${file(var.credentials_path)}"
}

provider "google-beta" {
  project      = var.project_name
  region       = var.region
  access_token = var.GOOGLECLOUD_TOKEN
  #user_project_override = true
  #  credentials  = "${file(var.credentials_path)}"
}