terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = ">= 4.14.0"
    }
    gsuite = {
      source = "hashicorp/googleworkspace"
      version = ">= "
    }
  }
}
provider "googleworkspace" {
  impersonated_user_email = var.admin_email

  oauth_scopes = [
    "https://www.googleapis.com/auth/admin.directory.group",
    "https://www.googleapis.com/auth/admin.directory.group.member",
  ]
}
provider "google" {
  //credentials = file("<SERVICE ACCOUNT>.json")
  access_token = var.GOOGLECLOUD_TOKEN
  project      = var.project_name
  zone         = var.zone
  region       = var.region

}