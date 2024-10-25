
resource "kubernetes_namespace" "nginx" {
  metadata {
    name = "nginx"
  }
}

resource "helm_release" "nginx-ingress-controller" {
  name       = "nginx"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "nginx-ingress-controller"
  version    = "9.9.2"
  namespace   = kubernetes_namespace.nginx.metadata[0].name
  wait_for_jobs = true
  values = [
    "${file("${path.module}/charts/values.yaml")}"
  ]
}
