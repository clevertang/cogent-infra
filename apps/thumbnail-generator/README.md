# Thumbnail Generator App

This directory contains Kubernetes manifests for deploying the thumbnail-generation service.

## Components

- `deployment-api.yaml`: Deploys the API server.
- `deployment-task.yaml`: Deploys the background task processor.
- `service-api.yaml`: Exposes the API server via ClusterIP.
- `ingress.yaml`: Routes HTTP traffic to the API.
- `hpa-thumbnail-api.yaml`: Enables horizontal pod autoscaling for the API.
- `configmap.yaml`: Application environment variables.

## Apply

```bash
kubectl apply -k apps/thumbnail-generator/base
```
