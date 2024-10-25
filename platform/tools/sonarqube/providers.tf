
terraform {
  required_version = ">= 1.9"
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "6.8.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.33.0"
    }
    helm = {
      source = "hashicorp/helm"
      version = "2.16.1"
    }
  }

  backend "gcs" {
    bucket  = "tf-state-gaudiy-test1"
    prefix  = "terraform/platform-tools-sonar"
  }
}

provider "google" {
  project = var.project
}

locals {
    location = "asia-northeast1"
}

data "google_container_cluster" "default" {
  name     = "gke-cluster1-${terraform.workspace}"
  location = local.location
}

data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${data.google_container_cluster.default.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(data.google_container_cluster.default.master_auth[0].cluster_ca_certificate)

  ignore_annotations = [
    "^autopilot\\.gke\\.io\\/.*",
    "^cloud\\.google\\.com\\/.*"
  ]
}

provider "helm" {
  kubernetes {
    host                   = "https://${data.google_container_cluster.default.endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(data.google_container_cluster.default.master_auth[0].cluster_ca_certificate)
  }
}
