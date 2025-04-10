.PHONY: all reset infra app monitoring port-forward

all: reset infra app port-forward

reset:
	@echo "🔁 Resetting Minikube..."
	minikube delete || true
	minikube start --cpus=2 --memory=4g

infra:
	@echo "⚙️ Installing Ingress NGINX and Prometheus Stack..."
	helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx || true
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts || true
	helm repo update
	helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
	  --namespace ingress-nginx \
	  --create-namespace \
	  -f third-party/ingress-nginx/helm/values.base.yaml
	helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
	  -n monitoring \
	  --create-namespace \
	  -f third-party/prometheus-grafana/helm/values.base.yaml
	kubectl apply -k third-party/prometheus-grafana/base

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
	@echo "2️⃣ Edit your /etc/hosts file (or Windows equivalent) to add:"
	@echo "   127.0.0.1 grafana.local prometheus.local thumbnail.local"
	@echo ""
	@echo "3️⃣ Then access services in your browser:"
	@echo "   http://grafana.local"
	@echo "   http://prometheus.local"
	@echo "   http://thumbnail.local"
	@echo ""
	@echo "💡 You can verify Ingress is working by:"
	@echo "   kubectl get ingress"
