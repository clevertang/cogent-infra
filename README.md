# Cogent Labs Platform Infra Assignment

This repository contains the infrastructure implementation for the Cogent Labs Platform Infrastructure Assignment (Ops Focus).

---

## 🌐 Overview

This setup provisions a Kubernetes-based development environment using Minikube, deploying a thumbnail-generation API service with full observability via Prometheus and Grafana.

- Kubernetes: Provisioned locally with Minikube
- App: Node.js thumbnail generator (`thumbnail-api`) and background task processor (`task`)
- Ingress: Exposed via ingress-nginx controller
- Monitoring: Prometheus + Grafana + Alerting + Dashboards
- Autoscaling: Enabled via HorizontalPodAutoscaler (HPA)

---

## 🛠️ Prerequisites
- [Minikube](https://minikube.sigs.k8s.io/docs/start/) (v1.30.0+)
- [Helm](https://helm.sh/docs/intro/install/) (v3.12.0+)
- [Make](https://www.gnu.org/software/make/) (v4.3+)
- [Docker](https://docs.docker.com/get-docker/) (v20.10.0+)


## 🚀 Deployment Steps

```bash
make reset          # Resets Minikube environment
make infra          # Installs ingress-nginx + kube-prometheus-stack + monitoring
make app            # Deploys application components
make port-forward   # Opens Grafana and API access locally
```

---

## 🔧 Components

- [`apps/thumbnail-generator`](./apps/thumbnail-generator/README.md): App deployments and autoscaling
- [`third-party/ingress-nginx`](./third-party/ingress-nginx/README.md): Ingress controller with monitoring
- [`third-party/prometheus-grafana`](./third-party/prometheus-grafana/README.md): Observability stack

---

## 📜 Documentation
- [Design Document](./design-related/platform-design.md): High-level architecture and design decisions

## 📊 Observability

### Dashboards
- Grafana: auto-imports the NGINX Ingress dashboard (9614)
- Dashboards load from ConfigMap with label `grafana_dashboard=1`

### Alerts
- Triggered on:
  - 5xx error ratio > 5%
  - Ingress API is unreachable

---

## 🧪 SLI & SLO

### SLIs
- Request success rate (`nginx_ingress_controller_requests{status!~"5.."}`)
- API availability (`up == 1`)
- Latency buckets (via `histogram_quantile`)

### Potential SLOs
- 99.5% success rate over 5 minutes
- 95% of requests complete in < 200ms

---

## 🔁 Disaster Recovery

- Reset environment: `make reset`
- Recreate everything: `make infra && make app`
- All manifests are managed via Git and Kustomize

---

## 📦 Future Improvements

- Add production cluster support (e.g., EKS / GKE)
- Integrate CI/CD pipeline for deployment
- Enable cost monitoring (e.g., via Kubecost or Prometheus metrics)
- Secure API using NetworkPolicy + TLS certs
- Use sealed-secrets / IRSA for better secret management

---

## 👷 Author Notes

This system was built with forward-thinking architecture and observability-first practices in mind. It can be extended to production readiness by layering on CI/CD, multi-env configs, and secure credential management.
