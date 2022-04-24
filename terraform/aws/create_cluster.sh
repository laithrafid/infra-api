#!/bin/bash
#### COLORS
RED='\033[0;31m' 
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'      
CYAN='\033[0;36m'
####RESET###
NC='\033[0;0m'
#####BOLD#####
BRED='\033[1;31m'
BGREEN='\033[1;32m'
BYELLOW='\033[1;33m'
BBLUE='\033[1;34m'
BPURPLE='\033[1;35m'      
BCYAN='\033[1;36m'
BWHITE='\033[1;37m'   
###UNDERLINE####
URED='\033[4;31m' 
UGREEN='\033[4;32m' 
UYELLOW='\033[4;33m'
UBLUE='\033[4;34m' 
UPURPLE='\033[4;35m'
UCYAN='\033[4;36m'
UWHITE='\033[4;37m'
## VARS AND CONST
DNS_ZONE=kps.bayt.cloud
REGION=$(aws configure get region)
AWS_ACCESS_KEY_ID=$(aws configure get aws_access_key_id)
AWS_SECRET_ACCESS_KEY=$(aws configure get aws_secret_access_key)
NAME="api.${DNS_ZONE}"
STAGE=$1
KOPS-STATE-S3="kops-$STAGE"



cd $PWD/modules/create/

# Logic

case $STAGE in
        dev)
          cat << EOF > dev.tfvars
access_key_id=${AWS_ACCESS_KEY_ID}
secret_access_key=${AWS_SECRET_ACCESS_KEY}
stage=${STAGE}
region=${REGION}
kops-state-s3=${KOPS-STATE-S3}
EOF
run_create_module($STAGE)
create_ssh_key()
create_terraform_manifest()
deploying_cluster_to_aws($STAGE)
        ;;
        stg)
         cat << EOF > stg.tfvars
access_key_id=${AWS_ACCESS_KEY_ID}
secret_access_key=${AWS_SECRET_ACCESS_KEY}
stage=${STAGE}
region=${REGION}
kops-state-s3=${KOPS-STATE-S3}
EOF 
run_create_module($STAGE)
create_ssh_key()
create_terraform_manifest()
deploying_cluster_to_aws($STAGE)
        ;;
        prd)
          cat << EOF > stg.tfvars
access_key_id=${AWS_ACCESS_KEY_ID}
secret_access_key=${AWS_SECRET_ACCESS_KEY}
stage=${STAGE}
region=${REGION}
kops-state-s3=${KOPS-STATE-S3}
EOF 
run_create_module($STAGE)
create_ssh_key()
create_terraform_manifest()
deploying_cluster_to_aws($STAGE)

        ;;
        *)
            echo $"Usage: $0 {dev|stg|prd}"
            exit 1
esac




### Functions 

run_create_module(){
echo -e "${BLUE}==== Applying Pre-requisite Terraform ====${NC}"
terraform init
terraform plan 
terraform apply -auto-approve -input=false --var-file="$STAGE".tfvars
echo "AWS_KOPS_ACCESS_KEY_ID=$(terraform state show aws_iam_access_key.kops | grep "id" | cut -d= -f2 | awk '{$1=$1};1')" >> "$STAGE".tfvars
echo "AWS_KOPS_SECRET_ACCESS_KEY=$(terraform state show aws_iam_access_key.kops | grep "secret" | cut -d= -f2 | awk '{$1=$1};1')" >> "$STAGE".tfvars
echo -e "${GREEN}==== Done Deploying Pre-requisite Terraform ====${NC}"
echo ''
}


create_ssh_key(){
echo -e "${BLUE}==== Creating Keypair ====${NC}"
ssh-keygen -A -t rsa -C ${NAME} -f ${NAME}.pem
PUBKEY=$(pwd)/modules/create/${NANE}.pem.pub
aws ec2 import-key-pair --key-name ${NAME} --public-key-material file://${PUBKEY}
echo -e "${GREEN}==== Done Creating Keypair ====${NC}"
echo ''
}

create_terraform_manifest(){
echo -e "${BLUE}==== Creating Cluster Terraform ====${NC}"
cd ../
mkdir -p cluster
kops create cluster --cloud aws --state=s3://${KOPS-STATE-S3} --node-count 3 --zones ${REGION}a,${REGION}b,${REGION}d \
--master-zones ${REGION}a,${REGION}b,${REGION}d --dns-zone ${DNS_ZONE} --node-size t3.medium --master-size t3.medium \
--topology private --networking calico --ssh-public-key=${PUBKEY} --bastion --authorization RBAC --out=cluster --target=terraform ${NAME}

echo -e "${GREEN}==== Done Creating Cluster Terraform ====${NC}"
echo ''
}

deploying_cluster_to_aws(){
echo -e "${BLUE}==== Deploying Cluster Terraform ====${NC}"
cd cluster
cat << EOF > providers.tf
terraform {
  cloud {
     organization = "bayt"
     hostname = "app.terraform.io"
     workspaces {
      name = "infra-api-aws"
    }
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.11.0"
    }
  }
}
provider "aws" {
  region      = var.region
  access_key  = var.AWS_KOPS_ACCESS_KEY_ID
  secret_key  = var.KOPS_SECRET_ACCESS_KEY
}
}
EOF
cat << EOF > variables.tf
 variable "AWS_KOPS_ACCESS_KEY_ID" {
  type = string
  description = "which stage is this cluster should run vaiables from var file .tfvars"
  sensitive = true 
}
 variable "KOPS_SECRET_ACCESS_KEY" {
  type = string
  description = "which stage is this cluster should run vaiables from var file .tfvars"
  sensitive = true 
}
variable "region" {
  type = string
  description = "region of cluster"
  default = "ca-central-1"
}
EOF
terraform init
terraform plan
terraform apply -auto-approve -input=false  --var-file=../create/"$STAGE".tfvars
echo -e "${GREEN}==== Done Deploying Cluster Terraform ====${NC}"
echo ''
}






