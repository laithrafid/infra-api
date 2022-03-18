terraform { 
#   cloud {
#      token = var.TERRAFORMCLOUD_TOKEN
#      organization = "my-org"
#      hostname = "app.terraform.io"
#   workspaces {
#       name = ""
#       tags = ["app:mine"]
#     }
#    }
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "2.18.0"
    }
  }
}

provider "digitalocean" {
  DIGITALOCEAN_TOKEN = var.DIGITALOCEAN_TOKEN
}

  