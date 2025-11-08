#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive

apt-get update -y
apt-get install -y curl unzip

# Instalacja K3s
curl -sfL https://get.k3s.io | sh -

until k3s kubectl get node &>/dev/null; do
  echo "Czekam na uruchomienie K3s..."
  sleep 5
done

mkdir -p /opt/k3s

# Terraform wstrzyknie tu pliki YAML
%{ for m in manifests ~}
echo "Tworzę plik /opt/k3s/${m.name}"
cat <<EOF > /opt/k3s/${m.name}
${m.content}
EOF
%{ endfor ~}


echo "Wdrażanie aplikacji..."
for f in /opt/k3s/*.yaml; do
  [ -e "$f" ] || continue
  k3s kubectl apply -f "$f"
done

echo "✅ K3s i aplikacja wdrożone."
