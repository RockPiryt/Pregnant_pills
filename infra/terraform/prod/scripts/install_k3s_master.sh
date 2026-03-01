#!/bin/bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

apt-get update -y
apt-get install -y curl unzip
apt-get install -y amazon-ssm-agent
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

# Install K3s master (control-plane)
curl -sfL https://get.k3s.io | \
  INSTALL_K3S_EXEC="server --write-kubeconfig-mode 644 --tls-san ${MASTER_TLS_SAN}" \
  K3S_TOKEN="${K3S_TOKEN}" \
  sh -

until k3s kubectl get node &>/dev/null; do
  echo "Waiting for K3s master..."
  sleep 5
done

echo "K3s master is ready."