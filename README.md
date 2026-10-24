# Introduction to Continuous Integration (CI) & Jenkins

Notes and a hands-on Jenkins installation for getting started with CI.

## What is Continuous Integration?
CI is a practice where developers frequently integrate code into a shared repository.
Every integration is verified by an automated build and tests, so errors are caught
early — improving quality and speeding up delivery.

### Key features
1. **Frequent code integration** — commit to a shared repo multiple times a day.
2. **Automated builds** — every commit triggers a build to verify changes.
3. **Automated testing** — tests run on every build to protect functionality.
4. **Immediate feedback** — developers learn fast whether a change is good.

### Benefits
- **Early bug detection** — integration issues surface sooner and cost less to fix.
- **Better collaboration** — everyone works off the same integrated codebase.
- **Faster cycles** — automation removes manual build/test toil.
- **Higher quality** — continuous testing prevents regressions.

### How CI works
```
Developer pushes code ──► CI server detects change ──► Automated build
       ▲                                                     │
       │                                                     ▼
   Feedback (pass/fail)  ◄──────────────────────────  Automated tests
```
1. Developer pushes to version control (e.g. Git).
2. CI server (Jenkins, GitLab CI, …) detects the push and triggers a build.
3. Code is compiled, dependencies resolved, app built.
4. Unit/integration tests run.
5. Pass/fail results are reported back to the developers.

See [`docs/ci-tools-comparison.md`](docs/ci-tools-comparison.md) for a rundown of 10
popular CI/CD tools and when to use each.

---

## Introduction to Jenkins
**Jenkins** is an open-source automation server to build, test, and deploy software —
the engine behind many CI/CD setups.

**Why Jenkins:** automation, continuous integration, a huge plugin ecosystem, and
scalability via distributed (master/agent) builds.

### Core concepts
| Concept | Meaning |
|---|---|
| **Job / Project** | A task or process Jenkins runs. |
| **Build** | Compiling and packaging the code. |
| **Pipeline** | A series of steps to build, test, and deploy. |
| **Plugins** | Extend Jenkins (Git, Docker, Kubernetes, …). |
| **Nodes** | Machines that run jobs (master/agent). |

---

## Getting started — install Jenkins with Docker

**1. Start Jenkins** (web UI on 8080, agent port 50000):
```bash
docker run -d --name jenkins -p 8080:8080 -p 50000:50000 jenkins/jenkins:lts
```
Or use the helper script: [`scripts/run-jenkins.sh`](scripts/run-jenkins.sh)
(it adds a `-v jenkins_home:/var/jenkins_home` volume so your setup survives restarts).

**2. Confirm it's running:**
```bash
docker ps -a | grep jenkins
```

**3. Get the initial admin password:**
```bash
docker exec -it jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```
Or: [`scripts/get-admin-password.sh`](scripts/get-admin-password.sh)

**4. Open the UI** at http://localhost:8080 and paste the password to begin setup
(install suggested plugins → create admin user).

> Tip: the plain `docker run` above has **no volume**, so a `docker rm` wipes your
> Jenkins config. The helper script mounts the `jenkins_home` named volume to persist it.

### Cleanup
```bash
docker stop jenkins && docker rm jenkins
# to also wipe persisted data:
docker volume rm jenkins_home
```

---

## CI workflow (quick recap)
1. **Code change** — developer pushes to Git.
2. **Trigger build** — CI server detects the push.
3. **Run tests** — automated tests validate the code.
4. **Feedback** — developers see build/test results.
