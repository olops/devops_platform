
./common/scripts/up.bash -w dev -a

./common/scripts/down.bash -w dev -a

###

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

connect to cluster (create: default)

helm repo add gitlab https://charts.gitlab.io
helm repo update
helm upgrade --install default gitlab/gitlab-agent \
    --namespace gitlab-agent-default \
    --create-namespace \
    --set image.tag=v17.2.1 \
    --set config.token=glagent-i-sssjKQFuUFrhfXHsjVRcV8DX2wmGXWt1cDw2-Ux_PQzbcB5g \
    --set config.kasAddress=wss://kas.gaudiy-bongalos.com \
    --set replicas=1

push: three-tier-architecture-demo