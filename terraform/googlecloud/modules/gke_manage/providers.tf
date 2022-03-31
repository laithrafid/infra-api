terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = ">= 4.14.0"
    }
    google-beta = {
      source = "hashicorp/googleworkspace"
      version = ">= 4.14.0"
    }
  }
}