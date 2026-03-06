#!/bin/bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

ACM_CERT_ARN="${ACM_CERT_ARN}"
RDS_ENDPOINT="${RDS_ENDPOINT}"

apt-get update -y
apt-get install -y curl unzip git amazon-ssm-agent

systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

# Install K3s master
curl -sfL https://get.k3s.io | \
  INSTALL_K3S_EXEC="server --write-kubeconfig-mode 644 --tls-san ${MASTER_TLS_SAN}" \
  K3S_TOKEN="${K3S_TOKEN}" \
  sh -

# Wait for cluster
until k3s kubectl get node &>/dev/null; do
  echo "Waiting for K3s master..."
  sleep 5
done

echo "K3s master is ready."

# Install kubectl alias
ln -s /usr/local/bin/k3s /usr/local/bin/kubectl || true

# Clone repo
cd /opt
git clone https://github.com/RockPiryt/Pregnant_pills.git

# Deploy manifests
cd Pregnant_pills/Pregnant_app/infra/kubernetes/k8s-preg/overlays/prod

kubectl apply -k .

echo "Application deployed."