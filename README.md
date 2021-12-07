# Terraform-GKE-PPDM

**Objective**: Provision GKE cluster and configure it for PPDM backup
(currently, GKE and PPDM assumed to be in same network. Otherwise, VPC network peering is required to be added in.)

**Prerequisite**: This is setup and tested on a CentOS VM with following installed
1. GCP SDK
2. Terraform
3. Ansible


**Steps**:
- terraform init
- terraform plan
- terraform apply


**Outcome**: 
1. GKE cluster provisioning
2. PPDM configuration to backup this GKE cluster (using existing PPDM and DDVE)


