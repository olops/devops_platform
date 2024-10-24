
resource "google_container_cluster" "default" {
  name               = "gke-cluster1-${terraform.workspace}"
  location           = local.location
  initial_node_count = 1

  addons_config {
    http_load_balancing {
      disabled = false
    }
  }

  deletion_protection = false
}
