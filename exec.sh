#!/usr/bin/env bash

# Helper script to execute one-off commands in the APL development container
# Usage: ./exec.sh <command> [args...]

CONTAINER_NAME="apl-dev-environment"

# Check if container is running
if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "Container '${CONTAINER_NAME}' is not running."
    echo "Start it with: docker-compose up -d"
    exit 1
fi

# Check if command was provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <command> [args...]"
    echo "Example: $0 dotnet --version"
    echo "Example: $0 ls -la /workspace"
    exit 1
fi

# Get current working directory and convert to container path
HOST_CWD="$(pwd)"
HOST_HOME="$HOME"

# Convert host path to container path
# If we're somewhere in the home directory, map it to /home/host
if [[ "$HOST_CWD" == "$HOST_HOME"* ]]; then
    CONTAINER_CWD="/home/host${HOST_CWD#$HOST_HOME}"
else
    # Fallback to /workspace if outside home directory
    CONTAINER_CWD="/workspace"
fi

# Execute the command in the container with proper working directory
docker exec -it -w "$CONTAINER_CWD" "${CONTAINER_NAME}" "$@"
