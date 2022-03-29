resource "random_id" "cluster_name" {
  byte_length = 5
}

locals {
  cluster_name = "tf-k8s-${random_id.cluster_name.hex}"
}

module "gke_create" {
    source = "./modules/gke_create"
    

}
module "gke_manage" {
  source               = "./modules/gke_manage"
  project_id           = module.gke_create.project_id
  cluster_name         = var.cluster_name
  location             = module.gke_create.location
  use_private_endpoint = var.use_private_endpoint
  depends_on = [
    module.gke_create
  ]
}


resource "null_resource" "default" {

  provisioner "local-exec" {
    command = "gcloud compute instance-groups set-named-ports ${google_container_cluster.default.instance_group_urls[0]} --named-ports=${var.port_name}:${var.node_port} --format=json"
  }
}

resource "kubernetes_service" "nginx-ping" {
  metadata {
    namespace = "default"
    name      = "nginx"
  }

  spec {
    selector = {
      run = "nginx"
    }

    session_affinity = "ClientIP"

    port {
      protocol    = "TCP"
      port        = 80
      target_port = 80
      node_port   = var.node_port
    }

    type = "NodePort"
  }
}

resource "kubernetes_replication_controller" "nginx" {
  metadata {
    name      = "nginx"
    namespace = "default"

    labels = {
      run = "nginx"
    }
  }

  spec {
    selector = {
      run = "nginx"
    }
    template {
      metadata {
        labels = {
          run = "nginx"
        }
      }
      spec {
        container {
          image = "nginx:latest"
          name  = "nginx"
          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }

            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }
        }
      }
    }
  }
  }