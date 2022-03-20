terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = ">= 2.18.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = ">= 2.8.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.4.1"
    }
  }
}

provider "digitalocean" {
  token = var.DIGITALOCEAN_TOKEN
}

provider "kubernetes" {
  host             = data.digitalocean_kubernetes_cluster.primary.endpoint
  token            = data.digitalocean_kubernetes_cluster.primary.kube_config[0].token
  cluster_ca_certificate = base64decode(
    data.digitalocean_kubernetes_cluster.primary.kube_config[0].cluster_ca_certificate
  )
}

provider "helm" {
  kubernetes {
    host  = data.digitalocean_kubernetes_cluster.primary.endpoint
    token = data.digitalocean_kubernetes_cluster.primary.kube_config[0].token
    cluster_ca_certificate = base64decode(
      data.digitalocean_kubernetes_cluster.primary.kube_config[0].cluster_ca_certificate
    )
  }
}