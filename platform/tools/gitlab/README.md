
kubectl get secret -n gitlab gitlab-gitlab-initial-root-password -ojsonpath='{.data.password}' | base64 --decode

glagent-Hxv5GMKjk22sxs5Ek4savzR2mvk2MMJvCdKtiN3RNrGLwgtyVQ

helm repo add gitlab https://charts.gitlab.io
helm repo update
helm upgrade --install default gitlab/gitlab-agent \
    --namespace gitlab-agent-default \
    --create-namespace \
    --set image.tag=v17.2.1 \
    --set config.token=glagent-kLMpUQ-dtLSJnMjskYxsRYmrVmGiCY6NjMe19wz4dK79D4gxzQ \
    --set config.kasAddress=wss://kas.gaudiy-bongalos.com \
    --set replicas=1
