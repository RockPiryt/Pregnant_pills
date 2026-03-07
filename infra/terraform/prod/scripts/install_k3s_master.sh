#!/bin/bash
set -euo pipefail

exec > >(tee /var/log/install_k3s_master.log | logger -t user-data -s 2>/dev/console) 2>&1

export DEBIAN_FRONTEND=noninteractive

apt-get update -y
apt-get install -y curl unzip git ca-certificates netcat-openbsd


snap list amazon-ssm-agent || true
sudo snap start amazon-ssm-agent || true
sudo snap services amazon-ssm-agent || true

# Install K3s master
curl -sfL https://get.k3s.io | \
  INSTALL_K3S_EXEC="server --write-kubeconfig-mode 644 --tls-san ${MASTER_TLS_SAN}" \
  K3S_TOKEN="${K3S_TOKEN}" \
  sh -

until k3s kubectl get node >/dev/null 2>&1; do
  echo "Waiting for K3s master..."
  sleep 5
done

echo "K3s master is ready."

# Install kubectl alias
ln -sf /usr/local/bin/k3s /usr/local/bin/kubectl || true

echo "=== Preparing repo ==="
mkdir -p /opt
cd /opt

if [ ! -d /opt/Pregnant_pills ]; then
  git clone https://github.com/RockPiryt/Pregnant_pills.git
fi

APP_DIR="/opt/Pregnant_pills/infra/kubernetes/k8s-preg/overlays/prod"

if [ ! -d "${APP_DIR}" ]; then
  echo "ERROR: Directory ${APP_DIR} does not exist"
  exit 1
fi

echo "=== Waiting for RDS ==="
until nc -z "${RDS_ENDPOINT}" "${DB_PORT}"; do
  echo "Waiting for RDS at ${RDS_ENDPOINT}:${DB_PORT} ..."
  sleep 5
done

echo "RDS is reachable."

echo "=== Creating .env ==="
cat > "${APP_DIR}/.env" <<EOF
SECRET_KEY=${SECRET_KEY}
DATABASE_URL=postgresql://${DB_USER}:${DB_PASSWORD}@${RDS_ENDPOINT}:${DB_PORT}/${DB_NAME}?sslmode=require
EOF

chmod 600 "${APP_DIR}/.env"
ls -la "${APP_DIR}"

echo "=== Deploying manifests ==="
cd "${APP_DIR}"
k3s kubectl apply -k .

echo "Application deployed."