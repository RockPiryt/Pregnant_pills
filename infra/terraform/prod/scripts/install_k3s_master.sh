#!/bin/bash
set -euo pipefail

exec > >(tee /var/log/install_k3s_master.log | logger -t user-data -s 2>/dev/console) 2>&1

export DEBIAN_FRONTEND=noninteractive

apt-get update -y
apt-get install -y curl unzip git ca-certificates netcat-openbsd


snap list amazon-ssm-agent || true
sudo snap start amazon-ssm-agent || true
sudo snap services amazon-ssm-agent || true

# Install K3s master with taint so regular workloads are not scheduled here
curl -sfL https://get.k3s.io | \
  INSTALL_K3S_EXEC="server \
    --write-kubeconfig-mode 644 \
    --tls-san ${MASTER_TLS_SAN} \
    --node-taint node-role.kubernetes.io/control-plane=true:NoSchedule" \
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

echo "=== Preparing repo ==="
mkdir -p /opt
cd /opt

if [ ! -d /opt/Pregnant_pills ]; then
  git clone https://github.com/RockPiryt/Pregnant_pills.git
fi

CORE_DIR="/opt/Pregnant_pills/infra/kubernetes/k8s-preg/overlays/prod/core"
INGRESS_DIR="/opt/Pregnant_pills/infra/kubernetes/k8s-preg/overlays/prod/ingress"

[ -d "$CORE_DIR" ] || { echo "Missing directory: $CORE_DIR"; exit 1; }
[ -d "$INGRESS_DIR" ] || { echo "Missing directory: $INGRESS_DIR"; exit 1; }

echo "=== Waiting for RDS ==="
until nc -z "${RDS_ENDPOINT}" "${DB_PORT}"; do
  echo "Waiting for RDS at ${RDS_ENDPOINT}:${DB_PORT} ..."
  sleep 5
done

echo "RDS is reachable."

echo "=== Creating .env ==="
cat > "$CORE_DIR/.env" <<EOF
SECRET_KEY=${SECRET_KEY}
DATABASE_URL=postgresql://${DB_USER}:${DB_PASSWORD}@${RDS_ENDPOINT}:${DB_PORT}/${DB_NAME}?sslmode=require
EOF

chmod 600 "$CORE_DIR/.env"
ls -la "$CORE_DIR"

echo "=== Deploying manifests ==="
k3s kubectl apply -k "$CORE_DIR"
sleep 10
k3s kubectl apply -k "$INGRESS_DIR"


echo "Application deployed."