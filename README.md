
## DevOps Tools

this provisions infra and tools to GCP:
- GKE cluster
- Certificate Manager
- Nginx Ingress Controller
- Gitlab Community Edition
- SonarQube Community Edition
- Grafana
- Prometheus
- Loki/Promtail

### Steps

pending: `some steps below can be automated.`

1. login

```
gcloud auth application-default login --no-launch-browser
```

2. define Terraform variables file (terraform.tfvars)

- platform/infra/k8s/cluster/terraform.tfvars
- platform/infra/k8s/ingress-controller/terraform.tfvars
```
project  = <GCP Project>
```

- platform/infra/k8s/cert-manager/terraform.tfvars
```
project  = <GCP Project>
cert_issuer_email = <certificate issuance email contact>
ingress_classname = "nginx"
```

- platform/tools/gitlab/terraform.tfvars
```
project  = <GCP Project>
domain = <base domain>
host_suffix = "-test"
cert_issuer_email = <certificate issuance email contact>
cert_cluster_issuer = "clusterissuer-letsencrypt-dev"
```

- platform/tools/observability/terraform.tfvars
```
project  = <GCP Project>
domain = <base domain>
```

- platform/tools/sonarqube/terraform.tfvars
```
project  = <GCP Project>
domain = <base domain>
cert_cluster_issuer = "clusterissuer-letsencrypt-dev"
```

3. provision all
```
./common/scripts/up.bash -w dev -a
```

4. update local kube config
```
gcloud container clusters get-credentials gke-cluster1-dev --region asia-northeast1 --project <GCP Project>
```

5. retrieve Gitlab root user password.
- url: https://gitlab-test.<base domain>
- user: root
- password:
```
kubectl get secret -n gitlab gitlab-gitlab-initial-root-password -ojsonpath='{.data.password}' | base64 --decode
```

6. create "demo" group in Gitlab

7. create user token in SonarQube. then define CI/CD variable.
- url: https://sonarqube.<base domain>
define Gitlab CI/CD variable "SONAR_URL"
- user: admin
- password: admin (please update)
- create user token and define Gitlab CI/CD variable "SONAR_TOKEN"

8. connect Gitlab to deployment target Kubernetes cluster
- under Operate -> Kuberentes Clusters, click on "Connect a cluster"
- set name to "default" the register
- will be provided with commands below. please execute
```
helm repo add gitlab https://charts.gitlab.io
helm repo update
helm upgrade --install default gitlab/gitlab-agent \
    --namespace gitlab-agent-default \
    --create-namespace \
    --set image.tag=v17.2.1 \
    --set config.token=<token> \
    --set config.kasAddress=wss://kas-test.<base domain> \
    --set replicas=1
```
