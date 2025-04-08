# 📦 Prometheus-Grafana Installation (Helm)

This directory contains the configuration for deploying `kube-prometheus-stack` using Helm.

## 🔧 Installation steps

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

kubectl create ns monitoring

helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  -n monitoring -f values.yaml
```

## 🔐 Default Credentials (Grafana)
- **Username:** `admin`
- **Password:** `prom-operator`

## 📊 Recommended Dashboards
| Name                 | ID   |
|----------------------|------|
| Kubernetes / Pods    | 6417 |
| Node Exporter        | 1860 |
| kube-state-metrics   | 13332 |
