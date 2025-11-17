#!/usr/bin/env bash

# Helper script to get a shell on the APL development container

CONTAINER_NAME="apl-dev-environment"

# Check if container is running
if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "Container '${CONTAINER_NAME}' is not running."
    echo "Start it with: docker-compose up -d"
    exit 1
fi

# Execute bash with full terminal support
docker exec -it "${CONTAINER_NAME}" bash
