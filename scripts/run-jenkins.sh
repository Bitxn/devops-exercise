#!/usr/bin/env bash
# Start a Jenkins LTS container with a persistent home volume.
# Web UI: http://localhost:8080   | Agent port: 50000
set -euo pipefail

NAME="jenkins"

# If a container with this name already exists, show its status and exit.
if docker ps -a --format '{{.Names}}' | grep -qx "$NAME"; then
  echo "A container named '$NAME' already exists:"
  docker ps -a --filter "name=^${NAME}$"
  echo "Start it with:  docker start $NAME"
  echo "Or remove it:   docker rm -f $NAME"
  exit 0
fi

docker run -d \
  --name "$NAME" \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  jenkins/jenkins:lts

echo "Jenkins starting. Open http://localhost:8080"
echo "Get the initial admin password with: ./scripts/get-admin-password.sh"
