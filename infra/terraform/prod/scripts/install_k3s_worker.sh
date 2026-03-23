#!/bin/bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive# no questions

apt-get update -y
apt-get install -y curl unzip amazon-ssm-agent

systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

# Install K3s worker with worker label already set
curl -sfL https://get.k3s.io | \
  INSTALL_K3S_EXEC="agent --node-label node-role.kubernetes.io/worker=true" \
  K3S_URL="https://${MASTER_IP}:6443" \
  K3S_TOKEN="${K3S_TOKEN}" \
  sh -