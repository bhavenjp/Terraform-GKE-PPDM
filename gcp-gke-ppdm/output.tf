
output "gke_cluster_name" { value = google_container_cluster.gcp-gke-cluster.name }
output "gke_cluster_endpoint" { value = google_container_cluster.gcp-gke-cluster.endpoint }
output "gke_cluster_location" { value = google_container_cluster.gcp-gke-cluster.location }
