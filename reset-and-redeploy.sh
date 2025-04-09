#!/bin/bash

# 🚨 Minikube-only reset script for Cogent Infra local deployment
# This script deletes the current cluster state and applies all manifests fresh.

set -e

echo "🚀 Checking Minikube..."

if ! command -v minikube &> /dev/null; then
  echo "❌ Minikube is not installed. Please install Minikube first."
  exit 1
fi

echo "⚠️ Always restart Minikube."
minikube start --cpus=2 --memory=4g --addons=ingress

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
echo "⏳ Waiting for CRDs to be established..."
sleep 30

# Apply third-party components
kubectl apply -k third-party/minio/base
kubectl apply -k third-party/mongodb/base
kubectl apply -k third-party/prometheus-grafana/base

# Deploy application
kubectl apply -k apps/thumbnail-generator/base

echo "✅ Deployment complete. You may run 'kubectl get pods -A' to verify."
echo "ℹ️ Tip: run 'minikube tunnel' in a separate terminal to enable ingress access via http://grafana.local/"
