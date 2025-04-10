# ingress-nginx Controller

This directory contains the Helm configuration for deploying ingress-nginx.

## Features

- Metrics enabled on port 10254
- ServiceMonitor included for Prometheus
- LoadBalancer service with NLB annotations
- Configurable via `values.base.yaml`

## Apply

```bash
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  -f third-party/ingress-nginx/helm/values.base.yaml
```
