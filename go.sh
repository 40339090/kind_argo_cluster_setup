set -e

kind create cluster --config cluster.conf
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

# Argo setup
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl apply -n argocd -f patch-argo.yaml

sleep 15

kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s

kubectl apply -n argocd -f argo-ingress.yaml

kubectl wait --namespace argocd   --for=condition=ready pod   --selector=app.kubernetes.io/name=argocd-server   --timeout=90s

echo Admin password is 
kubectl get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" -n argocd| base64 --decode && echo
