#!/bin/bash
set -euo pipefail

exec > >(tee /var/log/install_k3s_worker.log | logger -t user-data -s 2>/dev/console) 2>&1

export DEBIAN_FRONTEND=noninteractive# no questions

apt-get update -y
apt-get install -y curl unzip ca-certificates

# SSM (optional)
snap start amazon-ssm-agent || true

# Install K3s worker with worker label already set
curl -sfL https://get.k3s.io | \
  INSTALL_K3S_EXEC="agent --node-label node-role.kubernetes.io/worker=true" \
  K3S_URL="https://${MASTER_IP}:6443" \
  K3S_TOKEN="${K3S_TOKEN}" \
  sh -