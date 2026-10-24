#!/usr/bin/env bash
# Print the Jenkins initial admin password (needed for first-time setup).
set -euo pipefail

NAME="jenkins"

if ! docker ps --format '{{.Names}}' | grep -qx "$NAME"; then
  echo "Jenkins container '$NAME' is not running. Start it with ./scripts/run-jenkins.sh"
  exit 1
fi

docker exec -it "$NAME" cat /var/jenkins_home/secrets/initialAdminPassword
