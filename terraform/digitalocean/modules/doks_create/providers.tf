terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.18.0"
    }
  }
}

provider "digitalocean" {
  DIGITALOCEAN_TOKEN = var.DIGITALOCEAN_TOKEN
}
