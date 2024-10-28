
resource "google_container_cluster" "default" {
  name               = "gke-cluster1-${terraform.workspace}"
  location           = local.location
  initial_node_count = 2

  node_config {
    machine_type = "e2-standard-2"
  }

  addons_config {
    http_load_balancing {
      disabled = false
    }
  }

  deletion_protection = false
}
