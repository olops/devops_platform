
./common/scripts/up.bash -w dev -a

./common/scripts/down.bash -w dev -a

###

sudo nano /etc/resolv.conf
8.8.8.8

gcloud auth application-default login --no-launch-browser

./common/scripts/up.bash -w dev -a

gcloud container clusters get-credentials gke-cluster1-dev --region asia-northeast1 --project nemil-bongalos

kubectl get secret -n gitlab gitlab-gitlab-initial-root-password -ojsonpath='{.data.password}' | base64 --decode
root
change password

group: demo
project: three-tier-architecture-demo

sonarqube: admin/admin
change password
generate token
add gitlab variable SONAR_TOKEN

set variable:
SONAR_URL
https://sonarqube.gaudiy-bongalos.com

oras pull ghcr.io/aquasecurity/trivy-db:2
oras push registry-test.gaudiy-bongalos.com/demo/three-tier-architecture-demo/trivy-db:2 db.tar.gz:application/vnd.aquasec.trivy.db.layer.v1.tar+gzip --artifact-type application/vnd.aquasec.trivy.config.v1+json

# create registry project AT
# username: three-tier-architecture-demo

connect to cluster (create: default)

helm repo add gitlab https://charts.gitlab.io
helm repo update
helm upgrade --install default gitlab/gitlab-agent \
    --namespace gitlab-agent-default \
    --create-namespace \
    --set image.tag=v17.2.1 \
    --set config.token=glagent-6XtfpbXQZe4YEnSKPVBsWLCxzzRcwz3xT-pwm9q7GjP-PGt3EQ \
    --set config.kasAddress=wss://kas-test.gaudiy-bongalos.com \
    --set replicas=1

push: three-tier-architecture-demo