#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive

apt-get update -y
apt-get install -y curl unzip

# Install K3s
curl -sfL https://get.k3s.io | sh -

until k3s kubectl get node &>/dev/null; do
  echo "Wainting for K3s..."
  sleep 5
done

# Allow non-root to read kubeconfig
chmod 644 /etc/rancher/k3s/k3s.yaml

echo "K3s is ready."
