
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

resource "kubernetes_manifest" "clusterissuer_letsencrypt" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind" = "ClusterIssuer"
    "metadata" = {
      "name" = "clusterissuer-letsencrypt-${terraform.workspace}"
    }
    "spec" = {
      "acme" = {
        "email" = var.cert_issuer_email
        "privateKeySecretRef" = {
          "name" = "letsencrypt-${terraform.workspace}"
        }
        "server" = "https://acme-v02.api.letsencrypt.org/directory"
        "solvers" = [
          {
            "http01" = {
              "ingress" = {
                "class" = var.ingress_classname
              }
            }
          },
        ]
      }
    }
  }

  depends_on = [
    helm_release.cert-manager
  ]
}
