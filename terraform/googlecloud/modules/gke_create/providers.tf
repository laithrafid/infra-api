terraform {
  cloud {
    organization = "bayt"
    hostname     = "app.terraform.io"
    workspaces {
      name = "intra-api-googlecloud"
      //tags = ["APIs:digitalocean"]
    }
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.14.0"
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
  scopes = [
    # Default scopes
    "https://www.googleapis.com/auth/compute",
    "https://www.googleapis.com/auth/cloud-platform",
    "https://www.googleapis.com/auth/ndev.clouddns.readwrite",
    "https://www.googleapis.com/auth/devstorage.full_control",

    # Required for google_client_openid_userinfo
    "https://www.googleapis.com/auth/userinfo.email",
  ]
}

provider "google-beta" {
  project      = var.project_name
  region       = var.region
  access_token = var.GOOGLECLOUD_TOKEN
  scopes = [
    # Default scopes
    "https://www.googleapis.com/auth/compute",
    "https://www.googleapis.com/auth/cloud-platform",
    "https://www.googleapis.com/auth/ndev.clouddns.readwrite",
    "https://www.googleapis.com/auth/devstorage.full_control",

    # Required for google_client_openid_userinfo
    "https://www.googleapis.com/auth/userinfo.email",
  ]
}