
## How to run :
* copy terraform.tfvars.template to terraform.tfvars and fill with variables
`cp terraform.tfvars.template terraform.tfvars`
* `terraform init`
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.14.0 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | >= 4.14.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.4.1 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.8.0 |

## Providers
```
  provider "google" {
  project      = var.project
  region       = var.region
  access_token = var.GOOGLECLOUD_TOKEN
  scopes = [
    # Default scopes
    "https://www.googleapis.com/auth/compute",
    "https://www.googleapis.com/auth/cloud-platform",
    "https://www.googleapis.com/auth/ndev.clouddns.readwrite",
    "https://www.googleapis.com/auth/devstorage.full_control",

    # Required for google_client_openid_userinfo
    "https://www.googleapis.com/auth/userinfo.email",
  ]
}

provider "google-beta" {
  project      = var.project
  region       = var.region
  access_token = var.GOOGLECLOUD_TOKEN
  scopes = [
    # Default scopes
    "https://www.googleapis.com/auth/compute",
    "https://www.googleapis.com/auth/cloud-platform",
    "https://www.googleapis.com/auth/ndev.clouddns.readwrite",
    "https://www.googleapis.com/auth/devstorage.full_control",

    # Required for google_client_openid_userinfo
    "https://www.googleapis.com/auth/userinfo.email",
  ]
}


provider "kubernetes" {
  load_config_file       = false
  cluster_ca_certificate = module.gke_manage.cluster_ca_certificate
  host                   = module.gke_manage.host
  token                  = module.gke_manage.token
}

provider "helm" {
  load_config_file       = false
  cluster_ca_certificate = module.gke_manage.cluster_ca_certificate
  host                   = module.gke_manage.host
  token                  = module.gke_manage.token
}
```
## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_gke_create"></a> [gke\_create](#module\_gke\_create) | ./modules/gke_create | n/a |
| <a name="module_gke_create_node_pool"></a> [gke\_create\node_poole](#module\_gke\_create\_node_pool) | ./modules/gke_create_node_pool | n/a |
| <a name="module_gke_manage"></a> [gke\_manage](#module\_gke\_manage) | ./modules/gke_manage | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_GOOGLECLOUD_TOKEN"></a> [GOOGLECLOUD\_TOKEN](#input\_GOOGLECLOUD\_TOKEN) | n/a | `any` | n/a | yes |
| <a name="input_activate_apis"></a> [activate\_apis](#input\_activate\_apis) | n/a | `list` | <pre>[<br>  "compute.googleapis.com",<br>  "container.googleapis.com"<br>]</pre> | no |
| <a name="input_auto_create_subnetworks"></a> [auto\_create\_subnetworks](#input\_auto\_create\_subnetworks) | n/a | `string` | `"false"` | no |
| <a name="input_auto_repair"></a> [auto\_repair](#input\_auto\_repair) | cos\_containerd: Container-Optimized OS with containerd. cos: Container-Optimized OS with Docker ubuntu\_containerd: Ubuntu with containerd ubuntu: Ubuntu with Docker. | `string` | n/a | yes |
| <a name="input_auto_scale"></a> [auto\_scale](#input\_auto\_scale) | n/a | `bool` | `false` | no |
| <a name="input_auto_upgrade"></a> [auto\_upgrade](#input\_auto\_upgrade) | auto updgrade nodes os | `string` | n/a | yes |
| <a name="input_billing_account"></a> [billing\_account](#input\_billing\_account) | n/a | `any` | n/a | yes |
| <a name="input_cluster_zones"></a> [cluster\_zones](#input\_cluster\_zones) | n/a | `list` | <pre>[<br>  "northamerica-northeast1-a",<br>  "northamerica-northeast1-b",<br>  "northamerica-northeast1-c"<br>]</pre> | no |
| <a name="input_consumer_quotas"></a> [consumer\_quotas](#input\_consumer\_quotas) | n/a | `list` | n/a | yes |
| <a name="input_delete_default_internet_gateway_routes"></a> [delete\_default\_internet\_gateway\_routes](#input\_delete\_default\_internet\_gateway\_routes) | n/a | `string` | `"true"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | n/a | `string` | `"dev"` | no |
| <a name="input_gke_node_pool_oauth_scopes"></a> [gke\_node\_pool\_oauth\_scopes](#input\_gke\_node\_pool\_oauth\_scopes) | (Optional) Scopes that are used by NAP when creating node pools. Use the https://www.googleapis.com/auth/cloud-platform scope to grant access to all APIs. It is recommended that you set | `list` | n/a | yes |
| <a name="input_gke_node_pool_tags"></a> [gke\_node\_pool\_tags](#input\_gke\_node\_pool\_tags) | (Optional) The list of instance tags applied to all nodes. Tags are used to identify valid sources or targets for network firewalls. | `list` | n/a | yes |
| <a name="input_ip_range_nodes"></a> [ip\_range\_nodes](#input\_ip\_range\_nodes) | n/a | `string` | `"10.10.10.0/24"` | no |
| <a name="input_ip_range_nodes_sec"></a> [ip\_range\_nodes\_sec](#input\_ip\_range\_nodes\_sec) | n/a | `string` | `"192.168.64.0/24"` | no |
| <a name="input_ip_range_pods"></a> [ip\_range\_pods](#input\_ip\_range\_pods) | n/a | `string` | `"10.10.20.0/16"` | no |
| <a name="input_ip_range_pods_sec"></a> [ip\_range\_pods\_sec](#input\_ip\_range\_pods\_sec) | n/a | `string` | `"192.168.65.0/16"` | no |
| <a name="input_ip_range_services"></a> [ip\_range\_services](#input\_ip\_range\_services) | n/a | `string` | `"10.10.30.0/24"` | no |
| <a name="input_ip_range_services_sec"></a> [ip\_range\_services\_sec](#input\_ip\_range\_services\_sec) | n/a | `string` | `"192.168.66.0/16"` | no |
| <a name="input_max_nodes"></a> [max\_nodes](#input\_max\_nodes) | release 1.18, GKE supports up to 15,000 nodes in a single cluster | `number` | `4` | no |
| <a name="input_min_nodes"></a> [min\_nodes](#input\_min\_nodes) | minimum number of nudes in cluster, if no autoscale this number will be initial\_node\_count of your cluster | `number` | `3` | no |
| <a name="input_node_image_type"></a> [node\_image\_type](#input\_node\_image\_type) | (Optional) The default image type used by NAP once a new node pool is being created. Please note that according to the official documentation the value must be one of the [COS\_CONTAINERD, COS, UBUNTU\_CONTAINERD, UBUNTU]. | `string` | n/a | yes |
| <a name="input_organization_id"></a> [organization\_id](#input\_organization\_id) | n/a | `string` | n/a | yes |
| <a name="input_preemptible"></a> [preemptible](#input\_preemptible) | (Optional) A boolean that represents whether or not the underlying node VMs are preemptible. See the official documentation for more information. Defaults to false. | `bool` | `false` | no |
| <a name="input_project_folder"></a> [project\_folder](#input\_project\_folder) | n/a | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | n/a | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | `"northamerica-northeast1"` | no |
| <a name="input_shared_vpc_host"></a> [shared\_vpc\_host](#input\_shared\_vpc\_host) | n/a | `string` | `"false"` | no |
| <a name="input_use_private_endpoint"></a> [use\_private\_endpoint](#input\_use\_private\_endpoint) | n/a | `bool` | `"false"` | no |
| <a name="input_worker_size"></a> [worker\_size](#input\_worker\_size) | machine\_type , if no value provided defaults | `string` | `"t2d-standard-1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | n/a |
| <a name="output_kubeconfig_path"></a> [kubeconfig\_path](#output\_kubeconfig\_path) | n/a |
