# Prometheus + Grafana Monitoring

This directory contains Helm values and Kustomize manifests for deploying kube-prometheus-stack.

## Features

- PrometheusRule alerts (5xx error rate, NGINX down)
- Grafana dashboard auto-loaded from ConfigMap
- ServiceMonitor for ingress-nginx controller
- Supports alert expansion and cost observability

## Grafana Dashboards
- Default Username: `admin`
- Default Password: `prom-operator`

## Apply

```bash
helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  -n monitoring \
  -f third-party/prometheus-grafana/helm/values.base.yaml

# Create Grafana dashboards and alerts
kubectl apply -k third-party/prometheus-grafana/base
```
