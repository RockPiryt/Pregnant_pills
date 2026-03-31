#!/bin/bash

echo "Updating kubeconfig"
aws eks update-kubeconfig --region eu-west-1 --name ekspreg

echo "Installing Helm"
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

helm repo add eks https://aws.github.io/eks-charts
helm repo update

echo "Deploying manifests"
kubectl apply -k core/
kubectl apply -k ingress-class/
kubectl apply -k ingress/