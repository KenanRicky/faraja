# Faraja Monitoring

Prometheus and Grafana for the Faraja backend, using the kube-prometheus-stack Helm chart.

## Install

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
kubectl create namespace monitoring

helm install monitoring prometheus-community/kube-prometheus-stack -n monitoring \
  --set grafana.adminPassword='<choose-a-password>' \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false \
  --set prometheus.prometheusSpec.ruleSelectorNilUsesHelmValues=false

kubectl get pods -n monitoring -w     # wait until all are Running

kubectl apply -f monitoring/servicemonitor.yaml
kubectl apply -f monitoring/alert-rules.yaml
```

## Access

```bash
kubectl port-forward -n monitoring svc/monitoring-kube-prometheus-prometheus 9090:9090
kubectl port-forward -n monitoring svc/monitoring-grafana 3000:80
```

- Prometheus: http://localhost:9090 (Status → Targets, Alerts)
- Grafana: http://localhost:3000, user `admin`
- Dashboard: Dashboards → New → Import → upload `dashboards/faraja-overview.json`

## Metrics

| Metric | Type | Meaning |
|---|---|---|
| `http_requests_total` | Counter | Requests by method, route and status code |
| `http_request_duration_seconds` | Histogram | Request latency |
| `faraja_projects_total` | Gauge | Projects in the database |
| `faraja_milestones_total` | Gauge | Milestones in the database |

## Alerts

| Alert | Fires when | Severity |
|---|---|---|
| FarajaApiDown | Backend not reachable for 1m | critical |
| FarajaLowReplicaCount | Fewer than 2 backend replicas for 2m | warning |
| FarajaHighErrorRate | More than 5% of requests return 5xx for 5m | critical |
