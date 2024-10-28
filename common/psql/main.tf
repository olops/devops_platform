
locals {
  repository = "https://charts.bitnami.com/bitnami"
  chart = "postgresql"
  version = "13.1.5"
}

resource "helm_release" "postgresql" {
  name       = "psql"
  repository = local.repository
  chart      = local.chart
  version    = local.version
  namespace   = var.namespace
  timeout    = 600
  values = [
    "${file("${path.module}/charts/values.yaml")}"
  ]

  set {
    name  = "global.postgresql.auth.username"
    value = var.user
  }

  set {
    name  = "global.postgresql.auth.password"
    value = var.password
  }


  set {
    name  = "global.postgresql.auth.database"
    value = var.db
  }
}

data "kubernetes_service_v1" "postgresql" {
  metadata {
    namespace = var.namespace
    name = "psql-postgresql"
  }

  depends_on = [ helm_release.postgresql ]
}
