# Docker Networking with Multiple Containers

**Objective:** Understand Docker networking by wiring up a multi-container app on a
user-defined **bridge** network, where containers reach each other **by name**.

## Scenario
- **Flask web server** (container 1) — a small REST API (`flask-api` image)
- **MySQL database** (container 2) — `mysql:latest`
- **Redis cache** (container 3) — `redis:latest`

All three join one bridge network (`my-bridge-net`) so they can talk to each other
using container names as hostnames.

## Repo contents
```
.
├── app.py             # Flask REST API, GET /about, listens on 0.0.0.0:5001
├── requirements.txt   # Flask (pinned, + Werkzeug pin so the old Flask installs)
├── Dockerfile         # python:3.9-slim, builds the flask-api image
└── README.md
```

---

## ⚠️ Two fixes vs the handout (so it actually runs)
| File | Handout | Here | Why |
|---|---|---|---|
| `app.py` | `app.run(debug=True, port=5001)` | `app.run(host='0.0.0.0', debug=True, port=5001)` | Flask defaults to `127.0.0.1`, which is only reachable *inside* the container. Without `0.0.0.0`, `-p 5001:5001` won't reach the app from your host. |
| `requirements.txt` | `Flask==2.0.1` | `Flask==2.0.1` + `Werkzeug==2.0.3` | Flask 2.0.1 breaks with newer Werkzeug (`cannot import name ...`). Pinning Werkzeug keeps the old Flask installable. |

---

## Task 1 — Create a bridge network
```bash
docker network create --driver bridge my-bridge-net
```

## Task 2 — Verify the network
```bash
docker network ls
# NETWORK ID     NAME            DRIVER    SCOPE
# 87c23b491f59   my-bridge-net   bridge    local
```

## Task 3 — Inspect the network
```bash
docker network inspect my-bridge-net
```
Look for the `IPAM.Config` subnet/gateway (e.g. `172.18.0.0/16`, gateway `172.18.0.1`)
and the (initially empty) `Containers` map.

## Task 4 — Build the Flask image and launch all containers
```bash
# Build the Flask API image
docker build -t flask-api .

# Launch the three containers on the same network (-d = detached/background)
docker run -d --name mysql --net=my-bridge-net -e MYSQL_ROOT_PASSWORD=secret mysql:latest
docker run -d --name redis --net=my-bridge-net redis:latest
docker run -d --name flask --net=my-bridge-net -p 5001:5001 flask-api

docker ps   # all three should be Up
```
> Note: `mysql:latest` won't start without a root password — `MYSQL_ROOT_PASSWORD`
> (or `MYSQL_ALLOW_EMPTY_PASSWORD=yes`) is required. The handout omitted it.

Test the API from your host:
```bash
curl http://localhost:5001/about
```

## Task 5 — Test connectivity (name-based DNS on the bridge)
```bash
docker exec -it flask bash

# inside the flask container:
apt-get update && apt-get install -y iputils-ping   # ping isn't in the slim image
ping -c 3 mysql     # resolves to the mysql container's IP (e.g. 172.18.0.2)
ping -c 3 redis     # resolves to the redis container's IP (e.g. 172.18.0.3)
exit
```
> On a **user-defined** bridge, Docker's embedded DNS lets containers resolve each
> other by name. (The default `bridge` network does *not* give you name resolution —
> that's why we created `my-bridge-net`.)

## Task 6 — Clean up
```bash
docker stop mysql redis flask && docker rm mysql redis flask
docker network rm my-bridge-net
```

---

## Questions & Answers
**1. Purpose of the `--net` flag in `docker run`?**
It connects the container to a specified network (here, `my-bridge-net`).

**2. How do containers communicate on the same network?**
By container **name** (via Docker's embedded DNS on a user-defined bridge) or by IP.

**3. Bridge vs host network?**
- **Bridge** — containers get their own isolated network namespace and talk through a
  virtual bridge (private room, talking through a door).
- **Host** — the container shares the host's network stack directly, no isolation
  (same room as the host). No port mapping needed, but no isolation either.

**4. How to expose a container's port to the host?**
Use `-p host:container`, e.g. `-p 5001:5001`.
