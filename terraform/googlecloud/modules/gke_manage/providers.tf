terraform {
  required_version = ">= 0.13.0"
  required_providers {
    google = {
      source = "hashicorp/google"
      version = ">= 4.14.0"
    }
    google-beta = {
      source = "hashicorp/googleworkspace"
      version = ">= "
    }
  }
}

provider "google" {
  //credentials = file("<SERVICE ACCOUNT>.json")
  access_token = var.GOOGLECLOUD_TOKEN
  project      = var.project_name
  region       = var.region
}
provider "google-beta" {
  //credentials = file("<SERVICE ACCOUNT>.json")
  access_token = var.GOOGLECLOUD_TOKEN
  project      = var.project_name
  region       = var.region
}