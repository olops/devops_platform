
data "kubernetes_service_v1" "nginx" {
  metadata {
    namespace = "nginx"
    name = "nginx-nginx-ingress-controller"
  }
}

resource "google_dns_record_set" "sonarqube" {
  managed_zone = replace(var.domain, ".", "-")
  name         = "sonarqube.${var.domain}."
  type         = "A"
  rrdatas      = [data.kubernetes_service_v1.nginx.status.0.load_balancer.0.ingress.0.ip]
  ttl          = 300
}

resource "helm_release" "sonarqube" {
  name       = "sonarqube"
  repository = "https://SonarSource.github.io/helm-chart-sonarqube"
  chart      = "sonarqube"
  version    = "10.6.1+3163"
  namespace   = "sonarqube"
  create_namespace = true
  timeout = 600
  values = [
    "${file("${path.module}/charts/values.yaml")}"
  ]

  set {
    name = "ingress.hosts[0].name"
    value = "sonarqube.${var.domain}"
  }

  set {
    name = "ingress.tls[0].hosts[0]"
    value = "sonarqube.${var.domain}"
  }

  set {
    name = "ingress.annotations.cert-manager\\.io/cluster-issuer"
    value = var.cert_cluster_issuer
  }

  depends_on = [
    google_dns_record_set.sonarqube
  ]
}
