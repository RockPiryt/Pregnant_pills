#!/bin/bash
set -euo pipefail

if ! command -v helm >/dev/null 2>&1; then
  curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi

export KUBECONFIG=/root/.kube/config

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm repo update

kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

echo "Ensuring Grafana admin secret exists "
: "${GRAFANA_ADMIN_PASSWORD:?GRAFANA_ADMIN_PASSWORD is required}"

kubectl create secret generic grafana-admin-secret -n monitoring \
  --from-literal=admin-user=admin \
  --from-literal=admin-password="${GRAFANA_ADMIN_PASSWORD}"\
  --dry-run=client -o yaml | kubectl apply -f -

if ! kubectl -n kube-system get deployment metrics-server >/dev/null 2>&1; then
  echo "Installing metrics-server..."
  helm upgrade --install metrics-server metrics-server/metrics-server \
    -n kube-system \
    -f /opt/Pregnant_pills/infra/kubernetes/k3s/platform/metrics-server/values.yaml \
    --wait \
    --timeout 5m
else
  echo "k3s bundled metrics-server already exists."
fi

echo "Installing kube-prometheus-stack "
helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  -n monitoring \
  -f /opt/Pregnant_pills/infra/kubernetes/k3s/platform/monitoring/kube-prometheus-stack/values.yaml \
  --wait \
  --timeout 15m

echo "Monitoring stack installed "