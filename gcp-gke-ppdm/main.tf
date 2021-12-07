
resource "google_container_cluster" "gcp-gke-cluster" {
  name                     = var.gke_name
  location                 = var.gcp_zone
  network                  = var.gke_network
  subnetwork               = var.gke_subnetwork
  remove_default_node_pool = false
  initial_node_count       = 1

  private_cluster_config {
    enable_private_endpoint = false
    enable_private_nodes    = false
  }
  node_config {
    machine_type = "e2-standard-2"
  }
  cluster_autoscaling {
    enabled = false
  }
  ip_allocation_policy {
    cluster_ipv4_cidr_block  = "/17"
    services_ipv4_cidr_block = "/22"
  }
  release_channel {
    channel = "REGULAR"
  }
}

resource "local_file" "tf_ansible_vars_file" {
  content  = <<-DOC
    tf_gke_cluster_name: ${google_container_cluster.gcp-gke-cluster.name}
    tf_gke_cluster_endpoint: ${google_container_cluster.gcp-gke-cluster.endpoint}
    tf_gke_cluster_location: ${google_container_cluster.gcp-gke-cluster.location}
    DOC
  filename = "./gcp_tf_k8s_ansible_vars_file.yaml"
}

data "google_container_cluster" "gcp-gke-cluster" {
  project  = var.gcp_project
  name     = var.gke_name
  location = var.gcp_zone
}

resource "null_resource" "prepare-gke-cluster" {
  depends_on = [google_container_cluster.gcp-gke-cluster, local_file.tf_ansible_vars_file]
  provisioner "local-exec" {
    command = <<-EOT
      ## needs gcloud sdk config setup to connect to right account/project
      gcloud config configurations activate powerprotect
      gcloud container clusters get-credentials ${google_container_cluster.gcp-gke-cluster.name} --region ${google_container_cluster.gcp-gke-cluster.location};
      kubectl apply -f ./gke-snapshotclass.yaml;
      kubectl create namespace demo-namespace;
      kubectl apply -f ./gke-demo-pvc.yaml -n demo-namespace;
      kubectl apply -f ./gke-demo-pod.yaml -n demo-namespace;
      ## terraform serviceaccount/principal needs Kubernetes Engine Admin and Cluster Admin role
      kubectl create serviceaccount backupadmin -n kube-system;
      kubectl create clusterrolebinding backupadmin --clusterrole=cluster-admin --serviceaccount=kube-system:backupadmin;
      TOK=`kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | (grep backupadmin || echo "$_") | awk '{print $1}') | grep token: | awk '{print $2}'`;
      echo "gke_demonamespace_name: demo-namespace" >> ./gcp_tf_k8s_ansible_vars_file.yaml
      echo "gke_backupadmin_name: backupadmin" >> ./gcp_tf_k8s_ansible_vars_file.yaml
      echo "gke_backupadmin_token: $TOK" >> ./gcp_tf_k8s_ansible_vars_file.yaml
    EOT
  }
}

resource "null_resource" "run_ansible_playbook" {
  provisioner "local-exec" {
    command = "ansible-playbook ./gke.yaml"
  }

  depends_on = [google_container_cluster.gcp-gke-cluster, local_file.tf_ansible_vars_file, null_resource.prepare-gke-cluster]
}
