# Jenkins "Hello World" Freestyle Job

A minimal shell script (`hello-world.sh`) pulled from Git and run by a Jenkins
**Freestyle** job — your first end-to-end Jenkins build.

## Repo contents
```
.
├── hello-world.sh   # prints "Hello, Jenkins!"
└── README.md
```

---

## Part A — Put the script in a Git repo

### 1. Create the script locally
```bash
touch hello-world.sh
# add these two lines:
#   #!/bin/bash
#   echo "Hello, Jenkins!"
chmod +x hello-world.sh
```
(Already done in this repo — the executable bit is committed.)

### 2. Initialize Git and configure identity (first time only)
```bash
git config --global user.name  "Your Name"
git config --global user.email "your-email@example.com"
git init
```

### 3. Stage, check, and commit
```bash
git add hello-world.sh
git status                       # shows hello-world.sh ready to commit
git commit -m "Add hello-world.sh"
```

### 4. Create a GitHub repo and push
- On GitHub: **+ → New repository** → name e.g. `devops-sample-code`, Public, Create.
- Create a **fine-grained Personal Access Token (PAT)** for pushing:
  https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens
- Link and push (use the PAT as the password when prompted):
```bash
git remote add origin https://github.com/<your-username>/devops-sample-code.git
git branch -M main
git push -u origin main
```

> Verify the file shows up at `https://github.com/<your-username>/devops-sample-code`.

---

## Part B — Create the Jenkins job

**Prerequisite:** Jenkins is running (e.g. `http://localhost:8080`). See the Jenkins
install exercise for how to start it with Docker.

### Step 1 — Access Jenkins
Open `http://localhost:8080` and log in.

### Step 2 — New job
- **New Item** → name it `HelloWorld` → **Freestyle project** → **OK**.

### Step 3 — Configure
- **General:** description — `Hello World! Jenkins job.`
- **Source Code Management:** select **Git**, enter your repo URL:
  `https://github.com/<your-username>/devops-sample-code.git`
  - If it's private, add credentials (username + PAT) under **Credentials**.
  - Set the **Branch Specifier** to the branch you pushed (e.g. `*/main`).
- **Build Steps:** **Add build step → Execute shell**:
  ```bash
  sh hello-world.sh
  ```

### Step 4 — Save & run
**Save**, then **Build Now**.

### Step 5 — View output
**Build History** → click the build number (`#1`) → **Console Output**:
```
Started by user Admin
Building in workspace /var/jenkins_home/workspace/HelloWorld
[HelloWorld] $ /bin/sh -xe /tmp/jenkins....sh
+ echo 'Hello, Jenkins!'
Hello, Jenkins!
Finished: SUCCESS
```

---

### Notes
- Jenkins **clones your repo into its workspace** and runs `sh hello-world.sh` from
  there, so the script must exist on the branch you point the job at.
- `chmod +x` isn't strictly required when you invoke it as `sh hello-world.sh`
  (that runs it through `sh` explicitly), but the executable bit is committed anyway
  so `./hello-world.sh` also works.
