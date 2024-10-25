
resource "kubernetes_namespace" "cert-manager" {
  metadata {
    name = "cert-manager"
  }
}

resource "helm_release" "cert-manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "1.16.1"
  namespace   = kubernetes_namespace.cert-manager.metadata[0].name
  wait_for_jobs = true
  values = [
    "${file("${path.module}/charts/values.yaml")}"
  ]
}

resource "kubectl_manifest" "clusterissuer" {
  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: clusterissuer-letsencrypt-dev
spec:
  acme:
    email: nbongalos@hotmail.com
    privateKeySecretRef:
      name: letsencrypt-dev
    server: https://acme-v02.api.letsencrypt.org/directory
    solvers:
    - http01:
        ingress:
          class: nginx
YAML

  depends_on = [
    helm_release.cert-manager
  ]
}
