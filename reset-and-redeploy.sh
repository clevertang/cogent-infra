#!/bin/bash

# 🚨 Minikube-only reset script for Cogent Infra local deployment

set -e

echo "🚀 Checking Minikube..."

if ! command -v minikube &> /dev/null; then
  echo "❌ Minikube is not installed. Please install Minikube first."
  exit 1
fi

echo "⚠️ Always restart Minikube."
minikube delete || true
minikube start --cpus=2 --memory=4g

echo "🔁 Re-applying manifests..."

# Cluster Bootstrap
kubectl apply -k cluster/base

# Monitoring Stack
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts || true
helm repo update
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  -n monitoring \
  -f third-party/prometheus-grafana/helm/values.base.yaml

# Wait for CRDs before applying ServiceMonitor
echo "⏳ Waiting for Prometheus CRDs to be established..."
sleep 30

# 📦 Install ingress-nginx via Helm
echo "📦 Installing ingress-nginx..."
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx || true
helm repo update
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  -f third-party/ingress-nginx/helm/values.base.yaml

# ✅ Wait for ingress-nginx controller to be ready
echo "⏳ Waiting for ingress-nginx controller to be ready..."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s || {
    echo "❌ ingress-nginx controller not ready in time"
    exit 1
  }


# Apply third-party components
kubectl apply -k third-party/minio/base
kubectl apply -k third-party/mongodb/base

# Apply custom resources
kubectl apply -k apps/thumbnail-generator/base


echo "✅ Deployment complete. You may run 'kubectl get pods -A' to verify."
echo "ℹ️ Tip: run 'minikube tunnel' in a separate terminal to enable ingress access via http://grafana.local/"
