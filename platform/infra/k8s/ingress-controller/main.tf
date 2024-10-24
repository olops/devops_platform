
resource "helm_release" "nginx-ingress-controller" {
  name       = "nginx"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "nginx-ingress-controller"
  version    = "9.9.2"
  namespace   = "nginx"
  create_namespace = true
  values = [
    "${file("${path.module}/charts/values.yaml")}"
  ]
}
