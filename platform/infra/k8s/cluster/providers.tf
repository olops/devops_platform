
terraform {
  required_version = ">= 1.9"
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "6.8.0"
    }
  }

  backend "gcs" {
    bucket  = "tf-state-gaudiy-test1"
    prefix  = "terraform/platform-infra-k8s-cluster"
  }
}

provider "google" {
  project = var.project
}

locals {
    location = "asia-northeast1"
}
