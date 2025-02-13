
data "kubernetes_service_v1" "nginx" {
  metadata {
    namespace = "nginx"
    name = "nginx-nginx-ingress-controller"
  }
}

resource "google_dns_record_set" "gitlab" {
  managed_zone = replace(var.domain, ".", "-")
  name         = "gitlab${var.host_suffix}.${var.domain}."
  type         = "A"
  rrdatas      = [data.kubernetes_service_v1.nginx.status.0.load_balancer.0.ingress.0.ip]
  ttl          = 300
}

resource "google_dns_record_set" "registry" {
  managed_zone = replace(var.domain, ".", "-")
  name         = "registry${var.host_suffix}.${var.domain}."
  type         = "A"
  rrdatas      = [data.kubernetes_service_v1.nginx.status.0.load_balancer.0.ingress.0.ip]
  ttl          = 300
}

resource "google_dns_record_set" "minio" {
  managed_zone = replace(var.domain, ".", "-")
  name         = "minio${var.host_suffix}.${var.domain}."
  type         = "A"
  rrdatas      = [data.kubernetes_service_v1.nginx.status.0.load_balancer.0.ingress.0.ip]
  ttl          = 300
}

resource "google_dns_record_set" "kas" {
  managed_zone = replace(var.domain, ".", "-")
  name         = "kas${var.host_suffix}.${var.domain}."
  type         = "A"
  rrdatas      = [data.kubernetes_service_v1.nginx.status.0.load_balancer.0.ingress.0.ip]
  ttl          = 300
}

resource "google_dns_record_set" "robot-shop" {
  managed_zone = replace(var.domain, ".", "-")
  name         = "robot-shop.${var.domain}."
  type         = "A"
  rrdatas      = [data.kubernetes_service_v1.nginx.status.0.load_balancer.0.ingress.0.ip]
  ttl          = 300
}

resource "kubernetes_namespace" "gitlab" {
  metadata {
    name = "gitlab"
  }
}

resource "kubernetes_namespace" "runner" {
  metadata {
    name = "runner"
  }
}

resource "helm_release" "gitlab" {
  name       = "gitlab"
  repository = "https://charts.gitlab.io"
  chart      = "gitlab"
  version    = "8.2.1"
  namespace   = kubernetes_namespace.gitlab.metadata[0].name
  timeout = 600
  wait_for_jobs = true
  values = [
    "${file("${path.module}/charts/values.yaml")}"
  ]

  set {
    name = "global.hosts.domain"
    value = var.domain
  }

  set {
    name = "global.hosts.hostSuffix"
    value = trimprefix(var.host_suffix, "-")
  }

  set {
    name = "certmanager-issuer.email"
    value = var.cert_issuer_email
  }

  set {
    name = "global.ingress.annotations.cert-manager\\.io/cluster-issuer"
    value = var.cert_cluster_issuer
  }

  depends_on = [
    google_dns_record_set.gitlab,
    google_dns_record_set.registry
  ]
}
