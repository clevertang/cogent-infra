# 🧩 Cogent Infra Deployment Guide

This repository defines the GitOps-based Kubernetes infrastructure, including:

- Cluster-level configurations (IngressClass, Namespaces, RBAC)
- Third-party dependencies (MinIO, MongoDB, Prometheus + Grafana)
- Application deployment (thumbnail-generator)

---

## 📁 Project Structure

```
cluster/               ← Cluster-scoped infrastructure
third-party/           ← Core infrastructure services
apps/                  ← Kustomized application environments
```

Use ArgoCD to register each `apps/.../overlays/...` path as a GitOps target.

---

## 🧭 Local Deployment (Minikube)

This project assumes **local Kubernetes development is done via [Minikube](https://minikube.sigs.k8s.io/)**.

### ✅ Requirements

- Minikube >= 1.30
- Enabled addon: `ingress`
- Access via NodePort or Ingress (`/etc/hosts`)

### Start Minikube:

```bash
minikube start --cpus=2 --memory=4g --addons=ingress
```

> 💡 After the ingress addon is enabled, run the following **in a separate terminal**:

```bash
minikube tunnel
```

This exposes Ingress endpoints on `127.0.0.1`, allowing access to routes like:

- http://grafana.local/
- http://thumbnail.local/

Also make sure to update `/etc/hosts`:

```bash
127.0.0.1 grafana.local thumbnail.local
```

---

### One-click local install:

```bash
chmod +x reset-and-redeploy.sh
./reset-and-redeploy.sh
```

If you're using Docker Desktop or Kind, adjust:
- IngressClass
- NodePort/LoadBalancer service types
- Persistent volumes

---

## 📋 Recommended Manual Deployment Order

```bash
# 1. Cluster Bootstrap
kubectl apply -k cluster/base

# 2. Monitoring (Prometheus + Grafana)
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
kubectl create namespace monitoring
helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  -n monitoring \
  -f third-party/prometheus-grafana/helm/values.base.yaml

# 3. Middleware Components
kubectl apply -k third-party/minio/base
kubectl apply -k third-party/mongodb/base
kubectl apply -k third-party/prometheus-grafana/base

# 4. Application Deployment
kubectl apply -k apps/thumbnail-generator/base

# 5. Verify
kubectl get pods -A
```

---

## 📊 Observability (Prometheus + Grafana)

- Default Grafana login: `admin / prom-operator`
- Service type: `ClusterIP` (use Ingress or port-forward)
- Dashboards:
  - Pods: `6417`
  - Nodes: `1860`
  - kube-state-metrics: `13332`

### Access Grafana:

```bash
# Option 1: via ingress
http://grafana.local/

# Option 2: port forward
kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80
```

---

## ⚠️ Helm + CRD Caution

`ServiceMonitor` and other Prometheus CRDs **must be installed first**, via Helm:

```bash
helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  -n monitoring \
  -f third-party/prometheus-grafana/helm/values.base.yaml
```

Only then apply:

```bash
kubectl apply -k third-party/prometheus-grafana/base
```

Check CRDs with:

```bash
kubectl get crd | grep servicemonitor
```

---

## 🔁 Environment Overlays (Cloud/Prod)

```bash
third-party/<service>/overlays/<provider>/<stage>/
```

Examples:

- Use MongoDB Atlas:
  ```bash
  kubectl apply -k third-party/mongodb/overlays/aws/prod
  ```
- Switch to S3:
  ```bash
  kubectl apply -k third-party/minio/overlays/aws/prod
  ```

---
