#!/bin/bash
set -euo pipefail

exec > >(tee /var/log/install_k3s_worker.log | logger -t user-data -s 2>/dev/console) 2>&1

export DEBIAN_FRONTEND=noninteractive
AWS_REGION="${AWS_REGION}"
ECR_CREDENTIAL_PROVIDER_VER="${ECR_CREDENTIAL_PROVIDER_VER}"

apt-get update -y
apt-get install -y curl unzip git ca-certificates

# SSM (optional)
snap start amazon-ssm-agent || true

# Prepare repo
mkdir -p /opt
cd /opt

if [ ! -d /opt/Pregnant_pills ]; then
  git clone https://github.com/RockPiryt/Pregnant_pills.git
fi

install_ecr_credential_provider() {
  local arch provider_arch url

  arch="$(dpkg --print-architecture)"
  case "$arch" in
    amd64) provider_arch="amd64" ;;
    arm64) provider_arch="arm64" ;;
    *)
      echo "Unsupported architecture: $arch"
      exit 1
      ;;
  esac

  url="https://github.com/dntosas/ecr-credential-provider/releases/download/${ECR_CREDENTIAL_PROVIDER_VER}/ecr-credential-provider-linux-${provider_arch}"

  curl -fsSL "$url" -o /usr/local/bin/ecr-credential-provider
  chmod 0755 /usr/local/bin/ecr-credential-provider

  CONFIG_SRC="/opt/Pregnant_pills/infra/kubernetes/k3s/bootstrap/credential-provider-config.yaml"
  CONFIG_DST="/etc/rancher/k3s/ecr-credential-provider-config.yaml"

  mkdir -p /etc/rancher/k3s
  cp "$CONFIG_SRC" "$CONFIG_DST"
  chmod 600 "$CONFIG_DST"
}

install_ecr_credential_provider

# Install K3s worker with worker label already set
curl -sfL https://get.k3s.io | \
  INSTALL_K3S_EXEC="agent \
    --node-label node-role=worker \
    --kubelet-arg=image-credential-provider-config=/etc/rancher/k3s/ecr-credential-provider-config.yaml \
    --kubelet-arg=image-credential-provider-bin-dir=/usr/local/bin" \
  K3S_URL="https://${MASTER_IP}:6443" \
  K3S_TOKEN="${K3S_TOKEN}" \
  sh -