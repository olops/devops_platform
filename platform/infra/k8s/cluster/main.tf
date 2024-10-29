
resource "google_container_cluster" "default" {
  name               = "gke-cluster1-${terraform.workspace}"
  location           = local.location

  initial_node_count = 2

  cluster_autoscaling {
    enabled = true
    autoscaling_profile = "OPTIMIZE_UTILIZATION"
    resource_limits {
      resource_type = "cpu"
      minimum = 12
      maximum = 24
    }
    resource_limits {
      resource_type = "memory"
      minimum = 36
      maximum = 72
    }
  }

  deletion_protection = false
}
