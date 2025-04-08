# Observability & Reliability

## 🔍 Probes

`livenessProbe` and `readinessProbe` are added to the API and Task deployments on path `/`, port `3000`.

## 📊 Key Reliability Indicators (KRIs)

| Indicator             | Description                                       |
|-----------------------|---------------------------------------------------|
| Request Success Rate  | Ratio of HTTP 2xx responses to total requests     |
| API 99% Latency       | 99th percentile of response times (ms)           |
| Task Error Rate       | Task failures vs total processed tasks           |
| Pod Availability      | Read from Kubernetes probe and restart metrics   |

These metrics can be integrated with Prometheus, Grafana, or any observability suite.
