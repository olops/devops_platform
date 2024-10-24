
provider "google" {
  project = "nemil-bongalos"
}

resource "google_container_cluster" "default" {
  name               = "gke-standard-regional-cluster"
  location           = "us-central1"
  initial_node_count = 1

  addons_config {
    http_load_balancing {
      disabled = false
    }
  }

  deletion_protection = false
}
