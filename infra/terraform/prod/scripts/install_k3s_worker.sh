#!/bin/bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive # no questions

apt-get update -y
apt-get install -y curl unzip
apt-get install -y amazon-ssm-agent

systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

# Install K3s worker
curl -sfL https://get.k3s.io | \
  K3S_URL="https://${MASTER_IP}:6443" \
  K3S_TOKEN="${K3S_TOKEN}" \
  sh -

# Adding worker label
NODE_NAME=$(hostname)
until kubectl get node "$${NODE_NAME}" >/dev/null 2>&1; do
  sleep 5
done

kubectl label node "$${NODE_NAME}" node-role.kubernetes.io/worker=true --overwrite