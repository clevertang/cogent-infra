.PHONY: all reset infra app monitoring port-forward

# === Pre-requirements ===
# - minikube >= v1.30
# - helm >= v3.10
# - kubectl configured for Minikube
# - run `minikube tunnel` in separate terminal for ingress
# - add to /etc/hosts: 127.0.0.1 grafana.local prometheus.local thumbnail.local

all: reset infra app port-forward

reset:
	@echo "🔁 Resetting Minikube..."
	minikube delete || true
	minikube start --cpus=2 --memory=4g

infra:
	@echo "⚙️ Installing Prometheus Stack (CRDs first)..."
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts || true
	helm repo update
	helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
	  -n monitoring \
	  --create-namespace \
	  -f third-party/prometheus-grafana/helm/values.base.yaml
	kubectl apply -k third-party/prometheus-grafana/base

	@echo "⏳ Waiting for Prometheus CRDs to be ready..."
	sleep 30

	@echo "⚙️ Installing Ingress NGINX..."
	helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx || true
	helm repo update
	helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
	  --namespace ingress-nginx \
	  --create-namespace \
	  -f third-party/ingress-nginx/helm/values.base.yaml

	@echo "⏳ Waiting for ingress-nginx controller to be ready..."
	kubectl wait --namespace ingress-nginx \
	  --for=condition=ready pod \
	  --selector=app.kubernetes.io/component=controller \
	  --timeout=120s

	@echo "📦 Deploying storage and DB components (MinIO, MongoDB)..."
	kubectl apply -k third-party/minio/base
	kubectl apply -k third-party/mongodb/base

app:
	@echo "🚀 Deploying application..."
	kubectl apply -k apps/thumbnail-generator/base

monitoring:
	@echo "📊 (Re)Applying dashboards and alerts..."
	kubectl apply -k third-party/prometheus-grafana/base

port-forward:
	@echo "🌐 To access services via Ingress, follow these steps:"
	@echo ""
	@echo "1️⃣ Run the Minikube tunnel (in a separate terminal):"
	@echo "   minikube tunnel"
	@echo ""
	@echo "2️⃣ Add these lines to your /etc/hosts file:"
	@echo "   127.0.0.1 grafana.local prometheus.local thumbnail.local"
	@echo ""
	@echo "3️⃣ Then open your browser:"
	@echo "   http://grafana.local"
	@echo "   http://prometheus.local"
	@echo "   http://thumbnail.local"
	@echo ""
	@echo "💡 You can verify Ingress status with:"
	@echo "   kubectl get ingress -A"
