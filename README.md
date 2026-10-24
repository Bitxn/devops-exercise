# Real-Time Delivery Monitoring & Alerting

**Scenario (ZAPPTTO):** a DevOps engineer needs real-time insight into a delivery
service. We simulate delivery metrics in Python, expose them to **Prometheus**,
visualize on **Grafana**, add **alerting rules**, and automate the stack with a
**Jenkins** pipeline.

```
Python (metrics :8000/metrics)  ──scrape──►  Prometheus (:9090)  ──datasource──►  Grafana (:3000)
                                                   │
                                                   └── alert_rules.yml  ──►  alerts
                                      Jenkins (:8080) builds & runs it all
```

## Repo contents
```
.
├── delivery_metrics.py   # Python app: simulates metrics, serves /metrics on :8000
├── requirements.txt      # prometheus-client
├── Dockerfile            # containerizes the metrics app
├── prometheus.yml        # Prometheus scrape + rule_files config
├── alert_rules.yml       # alerting rules (pending > 10, avg time > 30s)
├── Jenkinsfile           # pipeline: pre-check → build → run app → run Prom+Grafana
└── README.md
```

## Metric types (reference)
- **Counter** — monotonically increasing count.
- **Gauge** — value that goes up/down (used for the delivery counts here).
- **Histogram** — bucketed distributions.
- **Summary** — quantiles (used for `average_delivery_time`).

---

## 1. Run the metrics app
```bash
pip3 install prometheus-client
python3 delivery_metrics.py
# metrics exposed at:
curl http://localhost:8000/metrics
```
`start_http_server(8000)` from `prometheus_client` auto-creates the `/metrics`
endpoint. Each metric has a name, description, and type.

## 2. Prometheus
`prometheus.yml` scrapes itself (`localhost:9090`) and the delivery app. The target
host depends on your platform:

| Platform | Scrape target for the app |
|---|---|
| Linux / WSL | `172.17.0.1:8000` (the `docker0` host IP — check with `ip addr show docker0`) |
| Docker Desktop (Windows/macOS) | `host.docker.internal:8000` |

Run Prometheus (mount both config files):
```bash
docker run -d --name prometheus --network=host \
  -v "$(pwd)/prometheus.yml:/etc/prometheus/prometheus.yml" \
  -v "$(pwd)/alert_rules.yml:/etc/prometheus/alert_rules.yml" \
  prom/prometheus
```
> `--network=host` is Linux-only. On **Docker Desktop (Windows/macOS)** host
> networking differs — use `-p 9090:9090` instead and set the target to
> `host.docker.internal:8000`.

- UI: http://localhost:9090
- Check **Status → Targets** (delivery_service should be `UP`) and **Status → Rules**.

## 3. Grafana
```bash
docker run -d --name grafana -p 3000:3000 grafana/grafana
```
- Open http://localhost:3000, log in `admin` / `admin` (skip the password change).
- **Connections → Data sources → Prometheus**, URL `http://172.17.0.1:9090`
  (or `http://host.docker.internal:9090` on Docker Desktop) → **Save & Test**.
- Build a dashboard with panels:
  1. `total_deliveries`
  2. `pending_deliveries`
  3. `on_the_way_deliveries`
  4. `average_delivery_time_sum / average_delivery_time_count`

## 4. Jenkins pipeline
```bash
docker run -d -p 8080:8080 -p 50000:50000 --name jenkins \
  -v jenkins_home:/var/jenkins_home jenkins/jenkins:lts
```
Get the initial admin password:
```bash
docker exec -it jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```
Open http://localhost:8080, finish setup, then **New Item → Pipeline** and either
point it at this repo's `Jenkinsfile` or paste its contents into the Pipeline Script.

> ⚠️ In `Jenkinsfile`, the **Setup Workspace** stage copies files from
> `/path/to/your/local/files` — replace that with your real path, or (better) use
> *Pipeline from SCM* so Jenkins checks out this repo and the copy stage can be dropped.

## 5. Simulate an alert
Raise the pending range so it clears the threshold, then restart the app:
```python
pending = random.randint(50, 100)  # exceeds the alert threshold
```
Watch the alert fire in **Prometheus → Alerts** (and in Grafana).

---

## Expected outputs
- Metrics: `http://localhost:8000/metrics`
- Prometheus: graphs for `total_deliveries`, `pending_deliveries`, `average_delivery_time`
- Grafana: delivery dashboards
- Jenkins: successful pipeline build logs
- Alerts: `HighPendingDeliveries` (warning), `HighAverageDeliveryTime` (critical)

## Cleanup
```bash
docker stop prometheus grafana jenkins delivery_metrics 2>/dev/null
docker rm   prometheus grafana jenkins delivery_metrics 2>/dev/null
```

---

### Notes / small fixes vs the handout
- Config file is `prometheus.yml` (handout twice typo'd `prometheus.ym` and labeled
  two steps "Step 2a"). `rule_files` → `alert_rules.yml` matches the filename.
- Added `for: 15s` to the `HighAverageDeliveryTime` rule so its description ("for the
  last 15 seconds") actually holds.
- Added a `requirements.txt` + `Dockerfile` so the Jenkins `docker build -t delivery_metrics .`
  stage has something to build.
