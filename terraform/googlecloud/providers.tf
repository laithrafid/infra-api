terraform {
  required_version = ">= 0.13.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.14.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 4.14.0"
    }
    googleworkspace = {
      source  = "hashicorp/googleworkspace"
      version = "0.6.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.8.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.4.1"
    }
  }
}
provider "google" {
  project      = var.project
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
  project      = var.project
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


provider "kubernetes" {
  load_config_file       = false
  cluster_ca_certificate = module.gke_manage.cluster_ca_certificate
  host                   = module.gke_manage.host
  token                  = module.gke_manage.token
}

provider "helm" {
  load_config_file       = false
  cluster_ca_certificate = module.gke_manage.cluster_ca_certificate
  host                   = module.gke_manage.host
  token                  = module.gke_manage.token
}


provider "googleworkspace" {
  oauth_scopes = [
    "https://www.googleapis.com/auth/admin.directory.group",
    "https://www.googleapis.com/auth/admin.directory.group.member",
  ]
}
