terraform {
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
