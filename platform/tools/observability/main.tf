
locals {
  subdomain_suffix = ""
  domain = var.domain
  grafanadb_user = "grafana"
  grafanadb_password = "grafana"
  grafanadb = "grafana"
  namespace = "monitor"
}

resource "kubernetes_namespace" "ns" {
  metadata {
    name = local.namespace
  }
}

module "postgresql" {
  source = "../../../common/psql"
  namespace = kubernetes_namespace.ns.metadata[0].name
  db = local.grafanadb
  user = local.grafanadb_user
  password = local.grafanadb_password
}

resource "helm_release" "loki" {
  name       = "monitor-loki"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki"
  version    = "5.36.3"
  namespace   = local.namespace
  timeout    = 600

  values = [
    "${file("${path.module}/charts/loki/values.yaml")}"
  ]
}

resource "helm_release" "promtail" {
  name       = "monitor-promtail"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "promtail"
  version    = "6.15.3"
  namespace   = local.namespace
  timeout    = 600
  values = [
    "${file("${path.module}/charts/promtail/values.yaml")}"
  ]
}

resource "helm_release" "prometheus_stack" {
  name       = "monitor-prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "51.2.0"
  namespace   = local.namespace
  timeout    = 600
  values = [
    "${file("${path.module}/charts/prometheus-stack/values.yaml")}"
  ]

  set_list {
    name  = "prometheus.ingress.hosts"
    value = ["prometheus${local.subdomain_suffix}.${local.domain}"]
  }

  set_list {
    name  = "prometheus.ingress.tls\\[0\\].hosts"
    value = ["prometheus${local.subdomain_suffix}.${local.domain}"]
  }

  set_list {
    name  = "alertmanager.ingress.hosts"
    value = ["alertmanager${local.subdomain_suffix}.${local.domain}"]
  }

  set_list {
    name  = "alertmanager.ingress.tls\\[0\\].hosts"
    value = ["alertmanager${local.subdomain_suffix}.${local.domain}"]
  }

  set_list {
    name  = "grafana.ingress.hosts"
    value = ["grafana${local.subdomain_suffix}.${local.domain}"]
  }

  set_list {
    name  = "grafana.ingress.tls\\[0\\].hosts"
    value = ["grafana${local.subdomain_suffix}.${local.domain}"]
  }

  set {
    name  = "grafana.grafana\\.ini.server.root_url"
    value = "https://grafana${local.subdomain_suffix}.${local.domain}"
  }

  set {
    name  = "grafana.grafana\\.ini.database.password"
    value = local.grafanadb_password
  }

  set {
    name  = "grafana.grafana\\.ini.database.user"
    value = local.grafanadb_user
  }

  set {
    name  = "grafana.grafana\\.ini.database.name"
    value = local.grafanadb
  }

  set {
    name  = "grafana.grafana\\.ini.database.host"
    value = "${module.postgresql.service}:${module.postgresql.service_port}"
  }
}

# -----------------------------------------------------------------------------

data "kubernetes_service_v1" "nginx" {
  metadata {
    namespace = "nginx"
    name = "nginx-nginx-ingress-controller"
  }
}

resource "google_dns_record_set" "prometheus" {
  managed_zone = replace(var.domain, ".", "-")
  name         = "prometheus.${var.domain}."
  type         = "A"
  rrdatas      = [data.kubernetes_service_v1.nginx.status.0.load_balancer.0.ingress.0.ip]
  ttl          = 300
}

resource "google_dns_record_set" "alertmanager" {
  managed_zone = replace(var.domain, ".", "-")
  name         = "alertmanager.${var.domain}."
  type         = "A"
  rrdatas      = [data.kubernetes_service_v1.nginx.status.0.load_balancer.0.ingress.0.ip]
  ttl          = 300
}

resource "google_dns_record_set" "grafana" {
  managed_zone = replace(var.domain, ".", "-")
  name         = "grafana.${var.domain}."
  type         = "A"
  rrdatas      = [data.kubernetes_service_v1.nginx.status.0.load_balancer.0.ingress.0.ip]
  ttl          = 300
}
