GOOGLECLOUD_TOKEN = ""
billing_account = "01F6E0-CAEE0D-ECCF35"
project_folder = "terraform"
project_name = ""
organization_id = "27775405036"
region = "northamerica-northeast1"
cluster_zones = [
        "northamerica-northeast1-a",
        "northamerica-northeast1-b",
        "northamerica-northeast1-c"
        ]
auto_create_subnetworks = "false"
delete_default_internet_gateway_route = "true"
shared_vpc_host = "false"
ip_range_nodes = "10.10.10.0/24"
ip_range_nodes_sec = "192.168.64.0/24"
ip_range_pods = "10.10.20.0/16"
ip_range_pods_sec = "192.168.65.0/16"
ip_range_services = "10.10.30.0/24"
ip_range_services_sec = "192.168.66.0/16"
worker_size = "t2d-standard-1"
use_private_endpoint = "true"
auto_scale = "false"
min_nodes  = "3"
max_nodes  = "4"