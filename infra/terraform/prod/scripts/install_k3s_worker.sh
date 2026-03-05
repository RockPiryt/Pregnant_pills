#!/bin/bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive # no questions
TF_DIR=infra
export ACM_CERT_ARN=$(terraform -chdir=$TF_DIR output -raw preg_cert_arn)
export RDS_ENDPOINT=$(terraform -chdir=$TF_DIR output -raw rds_endpoint)


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

echo "K3s worker joined the cluster."