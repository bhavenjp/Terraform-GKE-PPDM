variable "gcp_project" {
  default = ""
}

variable "gcp_region" {
  default = "asia-southeast1"
}

variable "gcp_zone" {
  default = "asia-southeast1-a"
}

variable "gke_name" {
  default = "gcp-gke01"
}

variable "gke_network" {
  default = ""
}

variable "gke_subnetwork" {
  default = ""
}

variable "gke_master_ipv4_cidr_range" {
  default = "172.16.0.0/28"
}
