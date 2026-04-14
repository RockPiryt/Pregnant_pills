#!/bin/bash
set -euo pipefail

exec > >(tee /var/log/install_k3s_master.log | logger -t user-data -s 2>/dev/console) 2>&1

export DEBIAN_FRONTEND=noninteractive
AWS_REGION="${AWS_REGION}"
ECR_CREDENTIAL_PROVIDER_VER="${ECR_CREDENTIAL_PROVIDER_VER}"

apt-get update -y
apt-get install -y curl unzip git ca-certificates netcat-openbsd


snap list amazon-ssm-agent || true
sudo snap start amazon-ssm-agent || true
sudo snap services amazon-ssm-agent || true

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

  url="https://github.com/dntosas/ecr-credential-provider/releases/download/${ECR_CREDENTIAL_PROVIDER_VER}/ecr-credential-provider-linux-$${provider_arch}"

  curl -fsSL "$url" -o /usr/local/bin/ecr-credential-provider
  chmod 0755 /usr/local/bin/ecr-credential-provider

  CONFIG_SRC="/opt/Pregnant_pills/infra/kubernetes/k3s/bootstrap/credential-provider-config.yaml"
  CONFIG_DST="/etc/rancher/k3s/ecr-credential-provider-config.yaml"

  mkdir -p /etc/rancher/k3s
  cp "$CONFIG_SRC" "$CONFIG_DST"
  chmod 600 "$CONFIG_DST"
}

install_ecr_credential_provider

# Install K3s master with taint so regular workloads are not scheduled here
curl -sfL https://get.k3s.io | \
  INSTALL_K3S_EXEC="server \
    --write-kubeconfig-mode 644 \
    --tls-san ${MASTER_TLS_SAN} \
    --node-taint node-role.kubernetes.io/control-plane=true:NoSchedule \
    --kubelet-arg=image-credential-provider-config=/etc/rancher/k3s/ecr-credential-provider-config.yaml \
    --kubelet-arg=image-credential-provider-bin-dir=/usr/local/bin" \
  K3S_TOKEN="${K3S_TOKEN}" \
  sh -

until k3s kubectl get node >/dev/null 2>&1; do
  echo "Waiting for K3s master..."
  sleep 5
done

echo "K3s master is ready."

# Make kubeconfig available to kubectl/helm
mkdir -p /root/.kube
cp /etc/rancher/k3s/k3s.yaml /root/.kube/config
chmod 600 /root/.kube/config
export KUBECONFIG=/root/.kube/config

ln -sf /usr/local/bin/k3s /usr/local/bin/kubectl || true

echo " Waiting for nodes "
until [ "$(k3s kubectl get nodes --no-headers 2>/dev/null | grep -c ' Ready ')" -ge 3 ]; do
  k3s kubectl get nodes || true
  sleep 10
done

echo "Cluster is ready."

#--------------------Section to remove after using ArgoCD
echo "Running script with deployment"
chmod +x /opt/Pregnant_pills/infra/kubernetes/k3s/bootstrap/deploy_app.sh
APP_ENV="${APP_ENV}" \
SECRET_KEY="${SECRET_KEY}" \
DATABASE_URL="${DATABASE_URL}" \
RDS_ENDPOINT="${RDS_ENDPOINT}" \
DB_PORT="${DB_PORT}" \
KUBECONFIG="/root/.kube/config" \
/opt/Pregnant_pills/infra/kubernetes/k3s/bootstrap/deploy_app.sh