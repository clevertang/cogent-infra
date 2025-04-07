# Thumbnail Generator Infrastructure (Kubernetes)

This repository provides the Kubernetes deployment structure for the Thumbnail Generator API application, along with required services like MongoDB and MinIO. The structure is modular and designed to scale with multiple environments and applications.

---

## 📁 Project Structure

```
infra/
├── apps/
│   └── thumbnail-generator/
│       ├── base/                  # Base Kubernetes manifests (Deployment, Service, ConfigMap)
│       └── overlays/
│           └── local/             # Local dev overlay using Kustomize
├── third-party/
│   ├── minio/                     # MinIO deployment and service
│   ├── mongodb/                   # MongoDB deployment and service
│   └── prometheus-grafana/       # Placeholder for observability stack
├── cluster/
│   ├── base/                      # Placeholder for namespace, RBAC
│   └── overlays/
│       ├── dev/                   # Future environment-specific configurations
│       └── prod/
```

---

## 🚀 How to Run (Using Minikube)

### 1. Start a local cluster
```bash
minikube start
```

### 2. Deploy dependencies (MongoDB & MinIO)
```bash
kubectl apply -f third-party/minio/minio.yaml
kubectl apply -f third-party/mongodb/mongodb.yaml
```

### 3. Deploy the application using Kustomize
```bash
kubectl apply -k apps/thumbnail-generator/overlays/local
```

### 4. Check services and pods
```bash
kubectl get pods
kubectl get svc
```

---

## 💡 Notes

- You can extend the overlays (`dev`, `prod`) for real-world use.
- MinIO credentials are defined in the ConfigMap: `minio:minio123`
- MongoDB runs without authentication for simplicity (dev only).
- Placeholder `README.md` files are added to guide future additions (RBAC, monitoring, etc).

---

## 📬 Submission

Make sure to submit the repo with the `.git` history as a ZIP file per the assignment instructions.

---

