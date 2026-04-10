#!/bin/bash
set -euo pipefail

APP_ENV="${APP_ENV:?APP_ENV is required}"
SECRET_KEY="${SECRET_KEY:?SECRET_KEY is required}"

DATABASE_URL="${DATABASE_URL:-}"
RDS_ENDPOINT="${RDS_ENDPOINT:-}"
DB_PORT="${DB_PORT:-5432}"

echo "APP_ENV=${APP_ENV}"
echo "DATABASE_URL is set: $([ -n "$DATABASE_URL" ] && echo yes || echo no)"

export KUBECONFIG="${KUBECONFIG:-/root/.kube/config}"

# health-check DB before deploy app
if [ -n "${RDS_ENDPOINT}" ]; then
  until nc -z "${RDS_ENDPOINT}" "${DB_PORT}"; do
    echo "Waiting for DB at ${RDS_ENDPOINT}:${DB_PORT} ..."
    sleep 5
  done
  echo "Database is reachable."
fi

#map production->prod
case "${APP_ENV}" in
  development) OVERLAY_ENV="dev" ;;
  testing) OVERLAY_ENV="test" ;;
  production) OVERLAY_ENV="prod" ;;
  *)
    echo "Unsupported APP_ENV: ${APP_ENV}"
    exit 1
    ;;
esac

BASE_DIR="/opt/Pregnant_pills/infra/kubernetes/k3s/overlays/${OVERLAY_ENV}"
#TODO: core and ingress folder only in prod overlay
CORE_DIR="${BASE_DIR}/core"
INGRESS_DIR="${BASE_DIR}/ingress"

[ -d "$CORE_DIR" ] || { echo "Missing directory: $CORE_DIR"; exit 1; }
[ -d "$INGRESS_DIR" ] || { echo "Missing directory: $INGRESS_DIR"; exit 1; }

echo "=== Creating .env for ${APP_ENV} ==="
cat > "${CORE_DIR}/.env" <<EOF
APP_ENV=${APP_ENV}
SECRET_KEY=${SECRET_KEY}
DATABASE_URL=${DATABASE_URL}
EOF

chmod 600 "${CORE_DIR}/.env"

echo "=== Deploying ==="
kubectl apply -k "$CORE_DIR"
sleep 10
kubectl apply -k "$INGRESS_DIR"
echo "Application deployed."