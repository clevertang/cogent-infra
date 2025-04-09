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
- Helm installed
- Access via NodePort or Ingress (`/etc/hosts`)

---

### 🚀 One-click install (Minikube)

```bash
chmod +x reset-and-redeploy.sh
./reset-and-redeploy.sh
```

> 💡 After the ingress addon is enabled, run the following **in a separate terminal**:
>
> ```bash
> minikube tunnel
> ```
>
> Also make sure to update `/etc/hosts`:
>
> ```bash
> 127.0.0.1 grafana.local prometheus.local thumbnail.local
> ```

---

## 🔍 Ingress-NGINX Monitoring Notes

This setup uses Helm to install `ingress-nginx` with metrics enabled.

Prometheus automatically scrapes metrics via a generated `ServiceMonitor`.

You do **not** need to manually define a `servicemonitor-ingress-nginx.yaml` file.

You can safely delete it if using the Helm-managed approach (which is recommended).

Refer to Grafana Dashboard ID: **9614** for NGINX monitoring.

---
