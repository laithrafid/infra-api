terraform { 
  cloud {
     organization = "bayt"
     hostname = "app.terraform.io"
     workspaces {
      name = "intra-api"
      //tags = ["APIs:digitalocean"]
    }
   }
  
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = ">= 2.18.0"
    }
  
    tfe = {
      source = "hashicorp/tfe"
      version = ">=0.28.1"
    }
  }
}
provider "tfe" {
  token = var.TERRAFORMCLOUD_TOKEN
}
provider "digitalocean" {
  token = var.DIGITALOCEAN_TOKEN
}
