#!/bin/bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

apt-get update -y
apt-get install -y curl unzip git

snap list amazon-ssm-agent
sudo snap start amazon-ssm-agent || true
sudo snap services amazon-ssm-agent || true

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

cd /opt
if [ ! -d /opt/Pregnant_pills ]; then
  git clone https://github.com/RockPiryt/Pregnant_pills.git
fi

cat > /opt/Pregnant_pills/infra/kubernetes/k8s-preg/overlays/prod/.env <<EOF
SECRET_KEY=${SECRET_KEY}
DATABASE_URL=postgresql://${DB_USER}:${DB_PASSWORD}@${RDS_ENDPOINT}:${DB_PORT}/${DB_NAME}?sslmode=require
EOF

chmod 600 /opt/Pregnant_pills/infra/kubernetes/k8s-preg/overlays/prod/.env
# Deploy manifests
cd /opt/Pregnant_pills/infra/kubernetes/k8s-preg/overlays/prod
sudo k3s kubectl apply -k .

echo "Application deployed."