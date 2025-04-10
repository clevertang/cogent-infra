# Platform Design: Services and Responsibilities

This document outlines the responsibilities and service guarantees provided by the Platform Infrastructure team, and how application developers can onboard and operate effectively.

---

## 1. Platform Responsibilities

The platform is designed to be extensible across both cloud and on-prem environments. The goal is to provide a reusable, secure, and observable foundation for application teams.

### 1.1 Security 🔄
- Namespace-level RBAC policies
- Support for sealed-secrets or External Secrets
- PodSecurity (PSP/PSA) or OPA Gatekeeper integration
- TLS termination via ingress with cert-manager (optional)

### 1.2 Storage 🔄
- Support for PVCs via dynamic provisioning (e.g., hostPath in dev, EBS/GCE in cloud)
- MinIO / S3 for object storage abstraction
- Backup hooks for stateful components (e.g., MongoDB, volume snapshots)

### 1.3 Scalability ✅
- HorizontalPodAutoscaler support with built-in and custom metrics
- Potential for Cluster Autoscaler in cloud backends
- Compatibility with service mesh / traffic splitting (future)

### 1.4 Observability ✅
- Prometheus + Grafana stack included
- ServiceMonitor and PrometheusRule support
- Dashboard auto-import via ConfigMap
- Alerts routed via Alertmanager (integration optional)

### 1.5 GitOps-ready CD 🔄
- Compatible with Argo CD or Flux
- Declarative structure using Helm + Kustomize
- Allows multiple environments with overlay structure

---

## 2. Application Developer Workflow

Application teams can plug into the platform through standard interfaces and automation provided by CI.

### 2.1 Automated Deployment Flow 🔄

1. Developer pushes app image or code
2. GitHub Action (or equivalent) bumps version in manifest repo
3. Argo CD syncs manifests to cluster
4. Monitoring & alerting automatically applied via selectors

### 2.2 Resilience and Disaster Recovery ✅

- Built-in restart policies and readiness/liveness probes
- App team defines their own config and backup logic
- Optionally back up volumes or databases using pre-integrated solutions

### 2.3 Service-level Indicators and Alerts ✅

- Platform provides generic SLIs (uptime, error rate, latency buckets)
- Application teams can define app-specific PrometheusRules in `apps/<name>/monitoring/`
- Dashboards can be added via ConfigMap or sidecar directory

---

## Appendix: What App Teams Need to Provide

| Item | Description |
|------|-------------|
| Docker Image | Built and hosted in registry |
| Deployment YAML | Standard K8s manifest or Helm values |
| ConfigMap/Secrets | Provided separately or via sealed-secrets |
| Ingress Path | Required if public/external access is needed |
| Health Probes | Readiness and liveness defined for auto-recovery |
| Resource Requests | CPU/Memory request/limit estimates |
| Optional HPA | If app should auto-scale |
| Alerts/Dashboards | If application has custom SLOs |



---

## 3. Multi-Tenant and Environment Overlay Support

To support teams working in different environments (e.g., dev, staging, prod) and with different security requirements, the platform supports:

### 3.1 Namespaced Isolation 🔄
- Each team/project is deployed to its own namespace
- RBAC and network policies ensure team-level boundaries
- Monitoring, dashboards, and alerting are label/namespace aware

### 3.2 Kustomize Overlays 🔄
- Base manifests shared across environments
- Environment-specific overlays define config differences:
  - Image tags
  - Resource requests/limits
  - Number of replicas
  - Ingress paths and domains

Example folder structure:

```
apps/
└── thumbnail-generator/
    ├── base/
    │   ├── deployment.yaml
    │   └── service.yaml
    ├── overlays/
    │   ├── dev/
    │   │   └── kustomization.yaml
    │   ├── staging/
    │   └── prod/
```

### 3.3 GitOps + Argo CD Integration 🔄
- Each overlay can be mapped to a separate Argo CD `Application`
- Allows per-env promotion and rollback
- Argo CD Projects can isolate RBAC and source control scopes

---

## Diagram: Multi-Environment Platform Flow


---

## 4. Implementation Status

To help reviewers distinguish between current capabilities and future vision, below is a categorized implementation matrix:

| Capability                      | Status       | Notes |
|--------------------------------|--------------|-------|
| Cluster provisioning (Minikube)| ✅ Implemented | Fully automated with script |
| Ingress-nginx setup            | ✅ Implemented | Via Helm with metrics and ServiceMonitor |
| Prometheus + Grafana monitoring| ✅ Implemented | Full observability stack installed |
| Ingress metrics + dashboard    | ✅ Implemented | Dashboard auto-loaded via ConfigMap |
| PrometheusRule alerting        | ✅ Implemented | Includes 5xx and up/down alerts |
| Application deployments        | ✅ Implemented | API + task service with HPA |
| GitOps via Argo CD             | 🔄 Planned    | Architecture designed, not yet wired |
| GitHub Actions CI integration  | 🔄 Planned    | Version bump and manifest sync to be added |
| Multi-tenant namespaces        | 🔄 Planned    | Design supports namespace separation |
| Kustomize overlays per env     | 🔄 Planned    | Directory structure outlined |
| Cluster autoscaler             | ❌ Not implemented | Not supported in local dev |
| Secret management (SealedSec)  | ❌ Not implemented | Would be added for production |
| OPA / network policies         | ❌ Not implemented | Documented as future enhancement |

Legend:
- ✅ Implemented
- 🔄 Planned/Designed
- ❌ Not implemented yet



---

## 5. Trade-offs and Design Decisions

| Area | Chosen Approach | Alternatives | Trade-offs |
|------|------------------|--------------|------------|
| Cluster Setup | Minikube | Kind, K3s, cloud provider (EKS, GKE) | Minikube is local-friendly, but lacks multi-node testing and real cloud networking |
| Ingress | ingress-nginx + tunnel | LoadBalancer in cloud, Traefik, Istio ingress | ingress-nginx is simplest and dev-friendly, but `minikube tunnel` is manual |
| Monitoring | kube-prometheus-stack | Custom Prometheus/Grafana, cloud-native (CloudWatch, GCP Monitoring) | Rich ecosystem, but heavier in resource usage, more complex to configure |
| Dashboard Management | ConfigMap via sidecar | Manual UI creation, Grafana API, DB persistence | GitOps-friendly, but hard to edit live dashboards without reapplying |
| Alerting | PrometheusRule | Cloud-native alert systems, centralized tools | Standardized and customizable, but requires Prometheus literacy |
| HPA | CPU-based autoscaling | Custom metrics via Prometheus Adapter | Simple to start with, but not latency-aware or workload queue-aware |
| GitOps Plan | Argo CD + GitHub Actions | FluxCD, manual CI scripts | Scalable and declarative, but requires syncing two repos and workflow discipline |
| Storage | hostPath (dev) + S3/Minio abstraction | PersistentVolume + external cloud storage | Flexible and portable, but some operational burden on app teams |
| Security | Basic RBAC, future SealedSecret and OPA | Vault, IRSA, Gatekeeper, full policy suites | Basic by default, allows opt-in hardening but not pre-enforced |

These trade-offs are intended to keep the platform flexible and ready for production adaptation with incremental improvements.
