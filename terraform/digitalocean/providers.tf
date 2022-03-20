terraform { 
  cloud {
     token = var.TERRAFORMCLOUD_TOKEN
     organization = "bayt"
     hostname = "app.terraform.io"
  workspaces {
      name = "intra-api"
      tags = ["APIs:digitalocean"]
    }
   }
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = ">= 2.18.0"
    }
  }
}

provider "digitalocean" {
  DIGITALOCEAN_TOKEN = var.DIGITALOCEAN_TOKEN
}

  