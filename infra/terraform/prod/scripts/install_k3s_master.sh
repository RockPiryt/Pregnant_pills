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

# Install kubectl alias
ln -sf /usr/local/bin/k3s /usr/local/bin/kubectl || true

echo "=== Installing Helm ==="
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

helm repo add eks https://aws.github.io/eks-charts
helm repo update

echo "=== Installing AWS Load Balancer Controller ==="
kubectl create namespace kube-system --dry-run=client -o yaml | kubectl apply -f -

helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=preg-k3s-prod \
  --set serviceAccount.create=true \
  --set region="${AWS_REGION}" \
  --set vpcId="${VPC_ID}"

echo "=== Waiting for AWS Load Balancer Controller ==="
kubectl rollout status deployment/aws-load-balancer-controller -n kube-system --timeout=180s


echo "=== Preparing repo ==="
mkdir -p /opt
cd /opt

if [ ! -d /opt/Pregnant_pills ]; then
  git clone https://github.com/RockPiryt/Pregnant_pills.git
fi

APP_DIR="/opt/Pregnant_pills/infra/kubernetes/k8s-preg/overlays/prod"

if [ ! -d "$APP_DIR" ]; then
  echo "ERROR: Directory $APP_DIR does not exist"
  exit 1
fi

echo "=== Waiting for RDS ==="
until nc -z "${RDS_ENDPOINT}" "${DB_PORT}"; do
  echo "Waiting for RDS at ${RDS_ENDPOINT}:${DB_PORT} ..."
  sleep 5
done

echo "RDS is reachable."

echo "=== Creating .env ==="
cat > "$APP_DIR/.env" <<EOF
SECRET_KEY=${SECRET_KEY}
DATABASE_URL=postgresql://${DB_USER}:${DB_PASSWORD}@${RDS_ENDPOINT}:${DB_PORT}/${DB_NAME}?sslmode=require
EOF

chmod 600 "$APP_DIR/.env"
ls -la "$APP_DIR"

echo "=== Deploying manifests ==="
cd "$APP_DIR"
k3s kubectl apply -k .

echo "Application deployed."