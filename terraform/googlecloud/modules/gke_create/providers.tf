terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = ">= 4.14.0"
    }
  }
}

provider "google" {
  region = var.region
  //credentials = file("<SERVICE ACCOUNT>.json")
  access_token = var.GOOGLECLOUD_TOKEN
  project = var.project_name
  zone    = var.zone
}