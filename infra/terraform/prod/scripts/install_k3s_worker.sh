#!/bin/bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

apt-get update -y
apt-get install -y curl unzip

# Install K3s worker
curl -sfL https://get.k3s.io | \
  K3S_URL="https://${MASTER_IP}:6443" \
  K3S_TOKEN="${K3S_TOKEN}" \
  sh -

echo "K3s worker joined the cluster."