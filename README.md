# Jenkins Multi-Stage Pipeline — Python Flask App

A declarative Jenkins **Pipeline** that runs Build → Test → Deploy → Run → Test for a
small Flask app, pulled from Git via *Pipeline script from SCM*.

## Repo contents
```
.
├── app.py             # Flask app: GET / → "Hello, Jenkins Multi-Stage Pipeline!"
├── requirements.txt   # flask (pinned) + Werkzeug pin
├── test_app.py        # unittest: checks / returns 200 + the expected body
├── Jenkinsfile        # declarative pipeline (5 stages + post actions)
└── README.md
```

## Pipeline stages
| Stage | What it does |
|---|---|
| **Build** | Placeholder for dependency install (echo). |
| **Test** | `python3 -m unittest discover -s .` |
| **Deploy** | Copies `app.py` into `python-app-deploy/` in the workspace. |
| **Run Application** | Starts the app with `nohup ... &`, records PID. |
| **Test Application** | Runs `test_app.py` directly. |
| **post** | Prints success/failure. |

---

## Step 1 — Jenkins prerequisites
Jenkins running (e.g. Docker) with the **Pipeline** plugin installed.

## Step 2–3 — Push this repo to Git
```bash
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/<your-username>/<repo>.git
git branch -M main
git push -u origin main
```
(Use a fine-grained PAT as the password when prompted.)

## Step 4–6 — Create the pipeline job
- **New Item** → name `Python-MultiStage-Pipeline` → **Pipeline** → OK.
- **Pipeline → Definition:** *Pipeline script from SCM*.
- **SCM:** Git, enter your repo URL, add credentials if private, set the branch.
- Save.

## Step 7 — Run
**Build Now**, then watch the stage view and **Console Output**.

---

## ⚠️ Step 8 — The build *will* fail first: no Python in the Jenkins image

The stock `jenkins/jenkins:lts` image has **no python3/pip**, so the `sh 'python3 ...'`
steps fail until Python is available. Two ways to fix it:

### Option A — Install Python inside the Jenkins container (quick, matches the handout)
```bash
docker ps -a                                   # find the jenkins container id
docker exec -it -u root <container-id> bash
# inside the container:
apt-get update
apt-get install -y python3 python3-pip python3-venv python3-flask
exit
```
Then re-run the build. (Downside: not reproducible — lost if the container is recreated.)

### Option B — Run the stages on a Python Docker agent (recommended, reproducible)
Install the **Docker Pipeline** plugin and change the top of the `Jenkinsfile` to:
```groovy
agent { docker { image 'python:3.11-slim' } }
```
and make the **Build** stage actually install deps:
```groovy
stage('Build') {
    steps {
        sh 'pip install --no-cache-dir -r requirements.txt'
    }
}
```
Now every run gets a clean Python 3.11 with Flask — no manual container surgery.

> This repo keeps the **Jenkinsfile faithful to the exercise** (Build is just an echo)
> so its console output matches the handout. Apply Option B if you want it to pass
> without the manual `apt-get` step.

---

## Expected outcome (success)
```
+ python3 -m unittest discover -s .
Ran 1 test in 0.004s
OK
...
Deploying application...   → app.py copied to python-app-deploy/
Running application...      → app started via nohup, PID recorded
Testing application...      → test_app.py passes
Pipeline completed successfully!
Finished: SUCCESS
```

## Additional enhancements
- **Code quality** stage:
  ```groovy
  stage('Code Quality') {
      steps {
          echo 'Running code quality checks...'
          sh 'flake8 .'
      }
  }
  ```
- Deploy the app to a **Docker container** instead of a workspace folder.

### Note on pins
`Werkzeug==2.1.2` is pinned alongside `flask==2.1.2` because newer Werkzeug releases
break Flask 2.1.x imports. Keeps `pip install -r requirements.txt` reproducible.
